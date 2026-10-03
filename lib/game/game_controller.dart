import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

import '../core/format.dart';
import '../core/theme.dart';
import '../data/database.dart';
import '../domain/actions.dart';
import '../domain/balance.dart';
import '../domain/models.dart';
import '../domain/perks.dart';
import '../domain/simulation.dart';
import '../domain/time_guard.dart';
import '../domain/vault.dart';
import '../domain/world.dart';
import '../geo/hex_grid.dart';
import '../platform/location_service.dart';
import '../platform/native_bridge.dart';
import '../platform/place_namer.dart';
import '../platform/tile_cache.dart';
import 'repository.dart';
import 'save_file.dart';

enum BootStage { starting, syncing, ready, failed }

/// When to plant turfs automatically as the player moves.
enum AutoClaim {
  off('off', 'Off'),
  stations('stations', 'Stations'),
  everywhere('all', 'Anywhere');

  const AutoClaim(this.key, this.label);
  final String key;
  final String label;
}

/// Owns the World, the game clock and every side effect (DB, GPS, haptics).
/// Notifies listeners on structural change; [tick] fires at 1 Hz for counters.
class GameController extends ChangeNotifier with WidgetsBindingObserver {
  GameController();

  final bridge = NativeBridge.instance;
  final location = LocationService();
  final tick = ValueNotifier<int>(0);
  final toasts = StreamController<Outcome>.broadcast();
  final cacheProgress = ValueNotifier<(int, int)?>(null);

  BootStage stage = BootStage.starting;
  String? bootError;

  late final HexDatabase _db;
  late final Repository _repo;
  late final HexGrid grid;
  late final TileCache tiles;
  late final PlaceNamer namer;
  late final vtr.Theme _darkTheme, _sunTheme;
  late World world;
  late Simulator _sim;
  late Commands actions;

  // Game clock: anchored game time + monotonic stopwatch.
  int _anchorGame = 0;
  final _watch = Stopwatch();
  int get now => _anchorGame + _watch.elapsedMilliseconds;
  int _simCursor = 0;

  Timer? _ticker;
  int _ticks = 0;
  bool _flushing = false;
  bool _paused = false;

  // Position.
  double? lat, lng, accuracy;
  bool fakeFix = false;

  /// Turf whose zone the player is standing in (yours or a rival's).
  String? hereZone;

  /// What this spot is called (nearest station / street), from offline tiles.
  /// Only valid for the point it was looked up at: a name fetched for where
  /// you were a moment ago must never label a turf planted where you are now.
  PlaceHit? get herePlace {
    final la = lat, ln = lng;
    if (_place == null || la == null || ln == null || _placeLat == null) return null;
    return metersBetween(la, ln, _placeLat!, _placeLng!) <= 60 ? _place : null;
  }

  PlaceHit? _place;
  double? _placeLat, _placeLng;
  bool _placeBusy = false;

  /// True when a new turf can be planted right here (no turf within spacing).
  bool plantable = false;

  /// Turfs whose no-plant gap reaches into the plant range (drawn on the map).
  List<Turf> blockers = const [];

  /// Turf tapped on the map.
  String? selected;

  /// Open ground tapped on the map: where a plant at a distance would go.
  double? pickLat, pickLng;
  PlaceHit? pickPlace;
  bool get hasPick => pickLat != null;

  /// Standing inside one of your own turfs: jobs pay the home-turf bonus.
  bool get atHome => hereZone != null && world.turfs[hereZone]?.isPlayer == true;

  /// Report from the last catch-up, consumed by the UI once.
  SimReport? pendingReport;

  final recentLog = <LogEntry>[];

  PlayerData get player => world.player;
  WorldIndex get index => world.index;

  /// Turf the console is about: the tapped one, else the one you stand in.
  Turf? get focusTurf {
    final id = selected ?? hereZone;
    return id == null ? null : world.turfById(id);
  }

  bool get patrolMode => player.settings['patrol'] == true;
  bool get hapticsOn => player.settings['haptics'] != false;

  /// White basemap with dark inks, for reading the screen in direct sunlight.
  bool get sunMap => player.settings['sunMap'] == true;
  vtr.Theme get mapTheme => sunMap ? _sunTheme : _darkTheme;
  MapInk get ink => sunMap ? MapInk.sun : MapInk.dark;

  /// Console folded away: the main screen is the map and nothing else.
  bool get mapOnly => player.settings['mapOnly'] == true;
  AutoClaim get autoClaim {
    final v = player.settings['autoClaim'];
    if (v == true) return AutoClaim.everywhere;
    return AutoClaim.values.firstWhere((m) => m.key == v, orElse: () => AutoClaim.off);
  }

  // ------------------------------------------------------------ boot

  Future<void> boot() async {
    try {
      stage = BootStage.starting;
      notifyListeners();
      _db = await HexDatabase.open();
      _repo = Repository(_db);
      grid = H3Grid();
      tiles = await TileCache.open();
      namer = PlaceNamer(tiles);
      _darkTheme = await loadTacticalTheme();
      _sunTheme = await loadTacticalTheme(light: true);
      unawaited(tiles.template());

      final sample = await bridge.clock();
      final seed = math.Random.secure().nextInt(1 << 32) ^ (sample.wall << 20);
      world = await _repo.load(grid, now: sample.wall, seed: seed, elapsed: sample.elapsed);
      actions = Commands(world);
      _sim = Simulator(world);
      bridge.hapticsEnabled = hapticsOn;

      final logRows = await _repo.recentLog();
      recentLog.addAll([for (final r in logRows) LogEntry(r.ts, r.kind, r.message)]);

      lat = player.lastLat;
      lng = player.lastLng;
      _refreshZone();

      stage = BootStage.syncing;
      notifyListeners();
      await _resumeFrom(sample, firstBoot: player.createdAt == player.lastSync);

      stage = BootStage.ready;
      notifyListeners();
      WidgetsBinding.instance.addObserver(this);
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
      unawaited(_startLocation());
      if (lat != null) unawaited(_refreshPlace(force: true));
    } catch (e, st) {
      debugPrint('boot failed: $e\n$st');
      bootError = '$e';
      stage = BootStage.failed;
      notifyListeners();
    }
  }

  /// Anti-tamper check + deterministic catch-up from the last sync point.
  Future<void> _resumeFrom(ClockSample sample, {bool firstBoot = false}) async {
    final p = player;
    final verdict = evaluateClock(
      SyncAnchor(
        gameTime: p.lastSync,
        wallAtSync: p.wallAtSync,
        elapsedAtSync: p.monotonic,
        bootCount: p.bootCount,
      ),
      sample,
    );
    _anchorGame = verdict.gameNow;
    _watch
      ..reset()
      ..start();

    if (verdict.tampered && !firstBoot) {
      p.tamperStrikes++;
      if (p.tamperStrikes > 1) {
        final seized = p.credits * 0.15;
        p.credits -= seized;
        world.log(now, 'loss', 'Clock anomaly: ${verdict.tamperReason}. Auditors seized ${fmtNum(seized)} credits.');
      } else {
        world.log(now, 'loss', 'Clock anomaly: ${verdict.tamperReason}. Time credited from the hardware timer only.');
      }
    }

    final from = p.lastSync;
    final to = verdict.gameNow;
    if (to - from > 0) {
      final report = SimReport(from, to);
      var t = from;
      const chunk = 7 * kDay;
      while (t < to) {
        final e = math.min(t + chunk, to);
        _sim.run(t, e, offline: true, into: report);
        t = e;
        await Future<void>.delayed(Duration.zero);
      }
      if (to - from >= 5 * 60 * 1000 && !firstBoot && report.eventful) pendingReport = report;
    }
    _simCursor = to;
    await _flush(sample);
  }

  Future<void> _flush([ClockSample? sample]) async {
    if (_flushing) return;
    _flushing = true;
    try {
      final s = sample ?? await bridge.clock();
      final p = player;
      p.lastSync = now;
      p.monotonic = s.elapsed;
      p.wallAtSync = s.wall;
      p.bootCount = s.bootCount;
      _drainLog();
      final writing = _repo.flush(world); // clears pendingLog synchronously
      _drained = 0;
      await writing;
    } catch (e) {
      debugPrint('flush failed: $e');
    } finally {
      _flushing = false;
    }
  }

  /// Mirrors not-yet-shown pending log lines into the in-memory feed. The
  /// pending list itself is only cleared by the repository on flush.
  int _drained = 0;
  void _drainLog() {
    final pending = world.pendingLog;
    if (_drained > pending.length) _drained = 0;
    for (var i = _drained; i < pending.length; i++) {
      recentLog.insert(0, pending[i]);
    }
    _drained = pending.length;
    if (recentLog.length > 200) recentLog.removeRange(200, recentLog.length);
  }

  void _onTick() {
    if (_paused || stage != BootStage.ready) return;
    final t = now;
    final rev = world.revision;
    _sim.run(_simCursor, t, offline: false);
    _simCursor = t;
    _drainLog();
    tick.value = ++_ticks;
    if (world.revision != rev) {
      _refreshZone();
      notifyListeners();
    }
    if (_ticks % 15 == 0) unawaited(_flush());
  }

  // ------------------------------------------------------------ lifecycle

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        if (_paused) return;
        _paused = true;
        _sim.run(_simCursor, now, offline: false);
        _simCursor = now;
        unawaited(_flush());
        if (!patrolMode) location.stop();
      case AppLifecycleState.resumed:
        if (!_paused) return;
        _paused = false;
        unawaited(_onResume());
      default:
        break;
    }
  }

  Future<void> _onResume() async {
    final sample = await bridge.clock();
    await _resumeFrom(sample);
    _refreshZone();
    notifyListeners();
    unawaited(_startLocation());
  }

  // ------------------------------------------------------------ location

  Future<void> _startLocation() async {
    final st = await location.ensurePermission();
    notifyListeners();
    if (st != LocStatus.searching) return;
    if (lat == null) {
      final last = await location.lastKnown();
      if (last != null) _onFix(last);
    }
    location.start(
      patrol: patrolMode,
      onFix: _onFix,
      onError: (_) => notifyListeners(),
    );
  }

  Future<void> retryLocation() => _startLocation();

  void _onFix(Position pos) {
    if (fakeFix) return;
    _applyFix(pos.latitude, pos.longitude, pos.accuracy);
  }

  void _applyFix(double la, double ln, double acc) {
    lat = la;
    lng = ln;
    accuracy = acc;
    player.lastLat = la;
    player.lastLng = ln;
    final before = hereZone;
    _refreshZone();
    // Crisp tick whenever you cross a turf border, in or out.
    if (hereZone != before) unawaited(bridge.borderTick());
    notifyListeners();
    unawaited(_refreshPlace());
  }

  void _refreshZone() {
    if (lat == null) return;
    hereZone = world.zoneAt(lat!, lng!)?.id;
    final fx = world.perks;
    plantable = world.nearest(lat!, lng!, withinM: fx.spacingM) == null;
    blockers = world.turfsNear(lat!, lng!, fx.plantRangeM + fx.spacingM);
    if (selected != null && selected == hereZone) selected = null;
    if (selected != null && world.turfById(selected!) == null) selected = null;
  }

  /// Looks up what this spot is called; re-runs after ~25 m of movement.
  Future<void> _refreshPlace({bool force = false}) async {
    final la = lat, ln = lng;
    if (la == null || ln == null || _placeBusy) return;
    if (!force && _placeLat != null && metersBetween(la, ln, _placeLat!, _placeLng!) < 25) return;
    _placeBusy = true;
    try {
      final hit = await namer.lookup(la, ln);
      _placeLat = la;
      _placeLng = ln;
      _place = hit;
      notifyListeners();
      _maybeAutoClaim();
    } catch (e) {
      debugPrint('place lookup failed: $e');
    } finally {
      _placeBusy = false;
    }
    // Moved while the lookup was running (fast train, or a stale first fix):
    // look again for where we are now.
    if (lat != null && metersBetween(lat!, lng!, la, ln) >= 25) unawaited(_refreshPlace());
  }

  void _maybeAutoClaim() {
    final mode = autoClaim;
    if (mode == AutoClaim.off || lat == null) return;
    if (mode == AutoClaim.stations && herePlace?.isStation != true) return;
    // A turf deleted for good stays gone until it is planted again by hand.
    if (world.razedNear(lat!, lng!, world.perks.spacingM)) return;
    if (!actions.claimQuote(lat!, lng!).allowed) return;
    claimHere();
  }

  /// Debug-only: drop the agent anywhere by long-pressing the map.
  void teleport(double la, double ln) {
    if (!kDebugMode) return;
    fakeFix = true;
    _applyFix(la, ln, 5);
  }

  void releaseFakeFix() {
    fakeFix = false;
    notifyListeners();
  }

  // ------------------------------------------------------------ interaction

  void select(String? turfId) {
    selected = (turfId == hereZone) ? null : turfId;
    pickLat = pickLng = null;
    pickPlace = null;
    notifyListeners();
  }

  /// Marks a spot of open ground as the plant target and looks up its name.
  void pickGround(double la, double ln) {
    selected = null;
    pickLat = la;
    pickLng = ln;
    pickPlace = null;
    notifyListeners();
    unawaited(_lookupPick(la, ln));
  }

  Future<void> _lookupPick(double la, double ln) async {
    try {
      final hit = await namer.lookup(la, ln);
      if (pickLat == la && pickLng == ln) {
        pickPlace = hit;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('pick lookup failed: $e');
    }
  }

  /// Plants at the picked spot (must be inside your plant range).
  Outcome claimPick() {
    final la = pickLat, ln = pickLng;
    if (la == null || ln == null) return const Outcome.fail('Tap a spot on the map first');
    final (name, station) = turfIdentity(pickPlace);
    final out = run((a, t) => a.claim(la, ln, t, name: name, isStation: station, fromLat: lat, fromLng: lng));
    if (out.ok) {
      final planted = world.zoneAt(la, ln);
      select(planted?.id);
    }
    return out;
  }

  Outcome runJob(String jobId) => run((a, t) => a.runJob(jobId, t, atHome: atHome));

  Outcome buyPerk(StreetPerk perk) => run((a, t) => a.buyPerk(perk, t));

  /// Runs a domain action, then haptics + toast + persist.
  Outcome run(Outcome Function(Commands a, int now) op) {
    final t = now;
    _sim.run(_simCursor, t, offline: false);
    _simCursor = t;
    final out = op(actions, t);
    _refreshZone();
    _drainLog();
    unawaited(bridge.haptic(out.buzz));
    toasts.add(out);
    notifyListeners();
    tick.value = ++_ticks;
    unawaited(_flush());
    return out;
  }

  /// Name + station flag a turf planted at [place] would get. A station that
  /// already has its station turf lends neither: the spot is named locally.
  (String?, bool) turfIdentity(PlaceHit? place) {
    if (place == null) return (null, false);
    if (place.isStation && !actions.stationFree(place.name)) return (place.localName ?? place.name, false);
    return (place.name, place.isStation);
  }

  /// Plants a turf exactly where the player stands, named after the spot.
  Outcome claimHere() {
    final la = lat, ln = lng;
    if (la == null || ln == null) return const Outcome.fail('No GPS fix');
    final (name, station) = turfIdentity(herePlace);
    return run((a, t) => a.claim(la, ln, t, name: name, isStation: station));
  }

  /// Breaches a rival turf; if it falls it is named after its own location.
  Future<Outcome> breach(String turfId) async {
    final target = world.turfById(turfId);
    PlaceHit? place;
    if (target != null) {
      try {
        place = await namer.lookup(target.lat, target.lng);
      } catch (_) {}
    }
    final (name, station) = turfIdentity(place);
    return run((a, t) => a.breach(turfId, lat, lng, t, name: name, isStation: station));
  }

  Future<void> setSetting(String key, Object value) async {
    player.settings[key] = value;
    bridge.hapticsEnabled = hapticsOn;
    if (key == 'patrol' && location.running) {
      location.stop();
      await _startLocation();
    }
    notifyListeners();
    if (key == 'autoClaim') _maybeAutoClaim();
    await _flush();
  }

  Future<void> cacheMapArea() async {
    if (lat == null || cacheProgress.value != null) return;
    cacheProgress.value = (0, 1);
    final ok = await tiles.precache(lat!, lng!, 5.0, (d, t) => cacheProgress.value = (d, t));
    cacheProgress.value = null;
    toasts.add(Outcome(ok > 0, ok > 0 ? 'Cached $ok vector tiles (5 km) for offline ops' : 'No connection — map cache unchanged'));
  }

  Outcome liquidate() {
    final seed = math.Random.secure().nextInt(1 << 32) ^ (now << 16);
    final out = run((a, t) => a.liquidate(t, seed));
    if (out.ok) selected = null;
    return out;
  }

  Outcome buyVault(VaultUpgrade u) => run((a, t) => a.buyVault(u, t));

  // ------------------------------------------------------------ save transfer

  /// Writes the whole empire to a file the player picks (Drive, Downloads,
  /// USB...). Carry that file to the new phone and import it there.
  Future<void> exportSave() async {
    try {
      while (_flushing) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      await _flush();
      final sample = await bridge.clock();
      final bytes = SaveFile.encode(
        tables: await _repo.exportTables(),
        schemaVersion: _db.schemaVersion,
        exportedAt: sample.wall,
      );
      final ok = await bridge.exportFile(SaveFile.fileName(sample.wall), bytes);
      if (ok) {
        toasts.add(Outcome(true, 'Save exported · ${(bytes.length / 1024).toStringAsFixed(1)} KB', Buzz.click));
      }
    } on PlatformException catch (e) {
      toasts.add(Outcome.fail('Export failed: ${e.message ?? e.code}'));
    } catch (e) {
      toasts.add(Outcome.fail('Export failed: $e'));
    }
  }

  /// Replaces the current empire with a save file. Returns false when the
  /// player cancels or the file is rejected (nothing is changed in that case).
  Future<bool> importSave() async {
    try {
      final bytes = await bridge.importFile();
      if (bytes == null) return false;
      final tables = SaveFile.decode(bytes, schemaVersion: _db.schemaVersion);

      _paused = true;
      while (_flushing) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      await _repo.importTables(tables);

      final sample = await bridge.clock();
      world = await _repo.load(grid, now: sample.wall, seed: world.player.worldSeed, elapsed: sample.elapsed);
      final p = world.player;
      final anchor = reanchorForImport(
        SyncAnchor(gameTime: p.lastSync, wallAtSync: p.wallAtSync, elapsedAtSync: p.monotonic, bootCount: p.bootCount),
        sample,
      );
      p
        ..wallAtSync = anchor.wallAtSync
        ..monotonic = anchor.elapsedAtSync
        ..bootCount = anchor.bootCount;
      actions = Commands(world);
      _sim = Simulator(world);
      _drained = 0;
      bridge.hapticsEnabled = hapticsOn;
      recentLog
        ..clear()
        ..addAll([for (final r in await _repo.recentLog()) LogEntry(r.ts, r.kind, r.message)]);
      selected = null;
      pickLat = pickLng = null;
      pickPlace = null;
      // Keep standing where this phone is, not where the old one was.
      if (lat != null) {
        world.player.lastLat = lat;
        world.player.lastLng = lng;
      } else {
        lat = world.player.lastLat;
        lng = world.player.lastLng;
      }
      await _resumeFrom(sample);
      _paused = false;
      _refreshZone();
      notifyListeners();
      toasts.add(Outcome(true, 'Save imported · ${world.index.owned} turfs restored', Buzz.surge));
      return true;
    } on FormatException catch (e) {
      _paused = false;
      toasts.add(Outcome.fail(e.message));
      return false;
    } on PlatformException catch (e) {
      _paused = false;
      toasts.add(Outcome.fail('Import failed: ${e.message ?? e.code}'));
      return false;
    } catch (e) {
      _paused = false;
      toasts.add(Outcome.fail('Import failed: $e'));
      return false;
    }
  }

  /// Debug-only: fast-forward the game clock to exercise the catch-up engine.
  Future<void> debugWarp(Duration d) async {
    if (!kDebugMode) return;
    final from = now;
    _anchorGame += d.inMilliseconds;
    final report = SimReport(from, now);
    _sim.run(_simCursor, now, offline: true, into: report);
    _simCursor = now;
    pendingReport = report;
    _refreshZone();
    _drainLog();
    notifyListeners();
    await _flush();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    location.stop();
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_flush());
    unawaited(toasts.close());
    super.dispose();
  }
}
