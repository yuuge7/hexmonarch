import 'dart:math' as math;

import '../core/format.dart';
import '../core/rng.dart';
import '../geo/hex_grid.dart';
import 'balance.dart';
import 'loot.dart';
import 'jobs.dart';
import 'models.dart';
import 'perks.dart';
import 'simulation.dart';
import 'tiers.dart';
import 'vault.dart';
import 'world.dart';

enum Buzz { none, click, capture, warn, surge }

class Outcome {
  const Outcome(this.ok, this.message, [this.buzz = Buzz.none]);
  const Outcome.fail(String message) : this(false, message, Buzz.warn);
  final bool ok;
  final String message;
  final Buzz buzz;
}

/// Price + eligibility of an action for the UI. [blocker] is a hard reason the
/// action cannot run (wrong place / wrong owner); affordability is separate so
/// the button can show the price in red instead of hiding it.
class Quote {
  const Quote(this.cost, {this.blocker, this.affordable = true, this.note});
  const Quote.blocked(String reason, {String? note}) : this(const Cost(), blocker: reason, note: note);
  final Cost cost;
  final String? blocker;
  final bool affordable;
  final String? note;
  bool get allowed => blocker == null && affordable;
}

class PrestigeStatus {
  const PrestigeStatus({
    required this.owned,
    required this.districts,
    required this.capital,
    required this.keys,
  });
  final int owned;
  final int districts;
  final int capital;
  final int keys;
  bool get hexesMet => owned >= kPrestigeHexes;
  bool get districtsMet => districts >= kPrestigeDistricts;
  bool get capitalMet => capital >= kPrestigeCapitalLevel;
  bool get ready => hexesMet && districtsMet && capitalMet;
}

/// Player commands. Territory is physical, Turf Wars style: you plant, breach
/// and collect around the spot you stand on, and around every turf you hold.
class Commands {
  Commands(this.w);
  final World w;

  PlayerData get p => w.player;
  double get _discount => w.vault.discount;
  int get _tier => tierFor(p.level).index1;

  Quote _q(Cost c, {String? note}) => Quote(c, affordable: c.affordable(p), note: note);

  Rng _rng(int now, String salt) => Rng(seedOf([p.worldSeed, now, fnv1a64(salt)]));

  void _pay(Cost c) => c.pay(p);

  String uniqueName(String base, {String? exceptId}) {
    final taken = {
      for (final t in w.turfs.values)
        if (t.isPlayer && t.id != exceptId) t.name.toLowerCase(),
    };
    final clean = base.trim().isEmpty ? 'Turf' : base.trim();
    if (!taken.contains(clean.toLowerCase())) return clean;
    for (var i = 2;; i++) {
      final candidate = '$clean ${roman(i)}';
      if (!taken.contains(candidate.toLowerCase())) return candidate;
    }
  }

  /// One station turf per station: the bonus cannot be farmed by ringing a
  /// terminus with turfs.
  bool stationFree(String? stationName) {
    if (stationName == null) return true;
    final key = stationName.trim().toLowerCase();
    return !w.turfs.values.any((t) => t.isPlayer && t.isStation && t.name.toLowerCase().startsWith(key));
  }

  // ------------------------------------------------------------ reach

  /// Your nearest turf within [rangeM] of a point. Plants, breaches and
  /// pickups reach out from every turf you hold, not only from where you
  /// stand.
  Turf? reachTurf(double lat, double lng, double rangeM) {
    Turf? best;
    var bestM = double.infinity;
    for (final t in w.turfsNear(lat, lng, rangeM)) {
      if (!t.isPlayer) continue;
      final d = metersBetween(lat, lng, t.lat, t.lng);
      if (d < bestM) {
        bestM = d;
        best = t;
      }
    }
    return best;
  }

  /// How far a turf of yours reaches for breaches and pickups: the plant
  /// range, plus Deep Reach.
  double get turfStrikeRangeM => w.perks.plantRangeM + w.perks.reachM;

  // ------------------------------------------------------------ claim

  /// GPS wobble allowance when checking the plant range.
  static const kPlantSlackM = 15.0;

  /// The turf of yours a plant at this point would reach out from, when the
  /// player is not in range on foot.
  Turf? claimVia(double lat, double lng, {double? fromLat, double? fromLng}) {
    final range = w.perks.plantRangeM;
    if (fromLat != null && fromLng != null && metersBetween(fromLat, fromLng, lat, lng) <= range + kPlantSlackM) {
      return null;
    }
    return reachTurf(lat, lng, range);
  }

  /// Can a new turf be planted at this point? With no arguments the player is
  /// standing on it. A [remote] point (tapped on the map) must be inside the
  /// plant range of the player at [fromLat]/[fromLng] or of one of their turfs.
  Quote claimQuote(double lat, double lng, {double? fromLat, double? fromLng, bool remote = false}) {
    final fx = w.perks;
    if (remote || (fromLat != null && fromLng != null)) {
      final range = fx.plantRangeM;
      final away = fromLat == null || fromLng == null ? null : metersBetween(fromLat, fromLng, lat, lng);
      final onFoot = away != null && away <= range + kPlantSlackM;
      if (!onFoot && reachTurf(lat, lng, range) == null) {
        return Quote.blocked('Out of plant range',
            note: '${away == null ? '' : '${away.round()} m from you · '}no turf of yours within ${range.round()} m · '
                'Long Arm (Crew > Perks) reaches farther');
      }
    }
    final spacing = fx.spacingM;
    final near = w.nearest(lat, lng, withinM: spacing);
    if (near != null) {
      final (t, d) = near;
      final who = t.isPlayer ? t.name : (t.isHostile ? 'a rival turf' : 'a turf');
      return Quote.blocked('Too close to a turf', note: '${d.round()} m from $who · need ${spacing.round()} m');
    }
    return _q(claimCost(w.index.owned, discount: _discount));
  }

  Outcome claim(
    double lat,
    double lng,
    int now, {
    String? name,
    bool isStation = false,
    double? fromLat,
    double? fromLng,
    bool remote = false,
  }) {
    final q = claimQuote(lat, lng, fromLat: fromLat, fromLng: fromLng, remote: remote);
    if (q.blocker != null) return Outcome.fail(q.note ?? q.blocker!);
    if (!q.affordable) return const Outcome.fail('Not enough funds');
    final t = w.makeTurf(
      lat: lat,
      lng: lng,
      name: uniqueName(name ?? 'Turf ${w.index.owned + 1}'),
      owner: kPlayer,
      now: now,
      isStation: isStation && stationFree(name),
    )..capturedAt = now;
    if (w.turfs.containsKey(t.id)) return const Outcome.fail('Too close to a turf');
    _pay(q.cost);
    final first = w.index.owned == 0;
    w.addTurf(t);
    w.unrazeNear(lat, lng, w.perks.spacingM);
    w.reindex();
    grantXp(w, 15 + p.level + (t.isStation ? 25 : 0), now);
    w.log(now, 'gain', 'Turf planted: ${t.name}${t.isStation ? ' (station)' : ''} · ${t.biome.label}');
    if (first) {
      w.log(now, 'info', 'First turf. Upgrade it into an Anchor Hub to supply turfs around it.');
    }
    return Outcome(true, 'Turf planted · ${t.name}', Buzz.capture);
  }

  // ------------------------------------------------------------ breach

  /// Strike power at a rival turf: your level plus the strongest hub whose
  /// supply sphere reaches it.
  double localStrike(Turf target) {
    var hubDef = 0.0;
    for (final s in w.index.hubs.values) {
      if (w.kmBetween(target, s.hub) <= s.radiusKm) hubDef = math.max(hubDef, s.def);
    }
    return playerStrike(p.level, hubDef) * w.perks.strikeMult;
  }

  double breachOdds(Turf t) => breachChance(localStrike(t), w.enemyDefense(t));

  double breachRangeM(Turf t) => turfRadiusM(t) + kBreachSlackM + w.perks.reachM;

  bool _insideForBreach(Turf t, double? lat, double? lng) =>
      lat != null && lng != null && metersBetween(lat, lng, t.lat, t.lng) <= breachRangeM(t);

  /// The turf of yours a breach on [t] would be launched from, when the
  /// player is not standing inside [t].
  Turf? breachVia(Turf t, double? lat, double? lng) =>
      _insideForBreach(t, lat, lng) ? null : reachTurf(t.lat, t.lng, turfStrikeRangeM);

  Quote breachQuote(Turf t, double? lat, double? lng) {
    if (!t.isHostile) return const Quote.blocked('No hostile presence');
    if (!_insideForBreach(t, lat, lng) && reachTurf(t.lat, t.lng, turfStrikeRangeM) == null) {
      return Quote.blocked('Out of reach',
          note: 'Walk into it, or hold a turf within ${turfStrikeRangeM.round()} m of it');
    }
    final base = claimCost(w.index.owned, discount: _discount);
    return _q(Cost(credits: base.credits * 1.5, intel: 5.0 * _tier),
        note: '${(breachOdds(t) * 100).round()}% success');
  }

  Outcome breach(String turfId, double? lat, double? lng, int now, {String? name, bool isStation = false}) {
    final t = w.turfById(turfId);
    if (t == null) return const Outcome.fail('Turf is gone');
    final q = breachQuote(t, lat, lng);
    if (q.blocker != null) return Outcome.fail(q.blocker!);
    if (!q.affordable) return const Outcome.fail('Not enough funds');
    _pay(q.cost);
    final f = w.factionById(factionIdOf(t.owner));
    final rng = _rng(now, 'breach$turfId');
    final odds = breachOdds(t);
    final fname = f == null ? 'Rivals' : factionName(f, p.level);
    if (!rng.chance(odds)) {
      f?.wins++;
      w.factionsDirty = true;
      w.log(now, 'loss', 'Breach on ${t.name} failed against $fname');
      return Outcome(false, 'Breach failed · $fname held', Buzz.warn);
    }
    f?.losses++;
    w.factionsDirty = true;
    // Day-one rival turfs are generated, not stored: never mutate the cached
    // preset, persist a fresh turf on the same spot instead.
    final persisted = w.turfs[t.id];
    final station = isStation && stationFree(name);
    final Turf mine;
    if (persisted == null) {
      mine = w.makeTurf(
        lat: t.lat,
        lng: t.lng,
        name: uniqueName(name ?? 'Turf ${w.index.owned + 1}'),
        owner: kPlayer,
        now: now,
        isStation: station,
      );
      w.addTurf(mine);
    } else {
      mine = persisted;
      if (mine.capturedAt == null) {
        mine
          ..name = uniqueName(name ?? 'Turf ${w.index.owned + 1}')
          ..isStation = station;
      }
      mine.owner = kPlayer;
      w.markTurf(mine);
    }
    mine
      ..integrity = 70
      ..capturedAt = now
      ..lastTick = now;
    w.liftSiege(mine.id);
    var loot = '';
    if (rng.chance(0.6)) {
      final m = dropModule(w, rng, now, minRarity: Rarity.uncommon);
      loot = ' · looted ${m.name}';
    }
    w.reindex();
    grantXp(w, 40 + 2 * p.level, now);
    final restored = mine.isHub ? ' Hub back online.' : '';
    w.log(now, 'gain', 'Took ${mine.name} from $fname$loot.$restored');
    return Outcome(true, 'Turf seized · ${mine.name}$loot', Buzz.capture);
  }

  // ------------------------------------------------------------ garrison

  Quote garrisonQuote(String id) {
    final t = w.turfs[id];
    if (t == null || !t.isPlayer) return const Quote.blocked('Not your turf');
    return _q(garrisonCost(t.garrison, discount: _discount));
  }

  Outcome upgradeGarrison(String id, int now) {
    final q = garrisonQuote(id);
    if (!q.allowed) return Outcome.fail(q.blocker ?? 'Not enough funds');
    _pay(q.cost);
    final t = w.turfs[id]!..garrison += 1;
    w.markTurf(t);
    w.reindex();
    grantXp(w, 5 + t.garrison, now);
    return Outcome(true, '${t.name} garrison L${t.garrison}', Buzz.click);
  }

  Quote repairQuote(String id) {
    final t = w.turfs[id];
    if (t == null || !t.isPlayer) return const Quote.blocked('Not your turf');
    if (t.integrity >= 99.5) return const Quote.blocked('Fully intact');
    return _q(repairCost(t));
  }

  Outcome repair(String id, int now) {
    final q = repairQuote(id);
    if (!q.allowed) return Outcome.fail(q.blocker ?? 'Not enough materials');
    _pay(q.cost);
    final t = w.turfs[id]!..integrity = 100;
    w.liftSiege(id);
    w.markTurf(t);
    w.reindex();
    return const Outcome(true, 'Structure restored', Buzz.click);
  }

  Outcome rename(String id, String name, int now) {
    final t = w.turfs[id];
    if (t == null || !t.isPlayer) return const Outcome.fail('Not your turf');
    final clean = name.trim();
    if (clean.isEmpty) return const Outcome.fail('Name cannot be empty');
    t.name = uniqueName(clean.length > 28 ? clean.substring(0, 28) : clean, exceptId: id);
    w.markTurf(t);
    w.revision++;
    return Outcome(true, 'Renamed to ${t.name}', Buzz.click);
  }

  // ------------------------------------------------------------ hubs

  int get hubCount => w.index.hubs.length;

  Quote hubQuote(String id) {
    final t = w.turfs[id];
    if (t == null || !t.isPlayer) return const Quote.blocked('Not your turf');
    if (t.isHub) return const Quote.blocked('Already a hub');
    return _q(hubEstablishCost(hubCount, discount: _discount));
  }

  Outcome establishHub(String id, int now) {
    final q = hubQuote(id);
    if (!q.allowed) return Outcome.fail(q.blocker ?? 'Not enough funds');
    _pay(q.cost);
    final t = w.turfs[id]!;
    t
      ..isHub = true
      ..hubLevel = math.max(1, t.hubLevel)
      ..integrity = 100;
    w.markTurf(t);
    w.reindex();
    grantXp(w, 100, now);
    final s = w.index.hubs[id]!;
    final covered = w.index.supplier.values.where((h) => h == id).length - 1;
    w.log(now, 'gain',
        'Anchor Hub online at ${t.name} · supplies ${fmtKm(s.radiusKm)} around it ($covered turf${covered == 1 ? '' : 's'})');
    return Outcome(true, 'Hub online · ${fmtKm(s.radiusKm)} supply sphere', Buzz.capture);
  }

  Quote hubUpgradeQuote(String id) {
    final t = w.turfs[id];
    if (t == null || !t.isPlayer || !t.isHub) return const Quote.blocked('Not your hub');
    return _q(hubUpgradeCost(t.hubLevel, discount: _discount));
  }

  Outcome upgradeHub(String id, int now) {
    final q = hubUpgradeQuote(id);
    if (!q.allowed) return Outcome.fail(q.blocker ?? 'Not enough funds');
    _pay(q.cost);
    final t = w.turfs[id]!;
    final before = hubClass(t.hubLevel);
    t.hubLevel++;
    w.markTurf(t);
    w.reindex();
    grantXp(w, 20 * t.hubLevel, now);
    final after = hubClass(t.hubLevel);
    if (after != before) {
      w.log(now, 'gain', '${t.name} promoted to $after class');
      return Outcome(true, '${t.name} is now a $after', Buzz.surge);
    }
    return Outcome(true, '${t.name} hub level ${t.hubLevel}', Buzz.click);
  }

  // ------------------------------------------------------------ relays

  List<String> relayCandidates(String fromId) {
    final from = w.turfs[fromId];
    if (from == null || !w.index.hubs.containsKey(fromId)) return const [];
    return [
      for (final id in w.index.hubs.keys)
        if (id != fromId) id,
    ]..sort((a, b) => w.kmBetween(from, w.turfs[a]!).compareTo(w.kmBetween(from, w.turfs[b]!)));
  }

  Quote relayQuote(String fromId, String toId) {
    final a = w.index.hubs[fromId];
    final b = w.index.hubs[toId];
    if (a == null || b == null) return const Quote.blocked('Both ends must be your hubs');
    if (!a.canRelay || !b.canRelay) return const Quote.blocked('Dead Zone: relays cannot lock on');
    final km = w.kmBetween(a.hub, b.hub);
    if (km > a.relayKm) {
      return Quote.blocked('Out of range: ${fmtKm(km)} > ${fmtKm(a.relayKm)}',
          note: 'Upgrade this hub or buy Signal Boost (Crew > Perks)');
    }
    return _q(relayCost(km, discount: _discount), note: fmtKm(km));
  }

  Outcome buildRelay(String fromId, String toId, int now) {
    final q = relayQuote(fromId, toId);
    if (!q.allowed) return Outcome.fail(q.blocker ?? 'Not enough funds');
    _pay(q.cost);
    final a = w.turfs[fromId]!..relayTarget = toId;
    w.markTurf(a);
    w.reindex();
    grantXp(w, 150, now);
    final net = w.index.networkOfHub(fromId);
    final trade = net == null ? '' : ' · trade x${net.trade.toStringAsFixed(2)}';
    w.log(now, 'gain', 'Relay ${a.name} ⇄ ${w.turfs[toId]?.name}$trade');
    return Outcome(true, 'Relay locked$trade', Buzz.capture);
  }

  Outcome severRelay(String fromId, int now) {
    final a = w.turfs[fromId];
    if (a == null || a.relayTarget == null) return const Outcome.fail('No relay');
    a.relayTarget = null;
    w.markTurf(a);
    w.reindex();
    w.log(now, 'info', 'Relay from ${a.name} severed');
    return const Outcome(true, 'Relay severed', Buzz.click);
  }

  Outcome abandon(String id, int now) {
    final t = w.turfs[id];
    if (t == null || !t.isPlayer) return const Outcome.fail('Not your turf');
    collapseTurf(w, t, now);
    w.reindex();
    w.log(now, 'info', 'Abandoned ${t.name} · modules moved to stash');
    return const Outcome(true, 'Turf abandoned', Buzz.warn);
  }

  /// Deletes a turf for good. Unlike [abandon], the spot stays empty: no rival
  /// crew moves back onto it and auto-plant will not put a turf there again.
  Outcome delete(String id, int now) {
    final t = w.turfs[id];
    if (t == null || !t.isPlayer) return const Outcome.fail('Not your turf');
    collapseTurf(w, t, now);
    w.raze(t);
    w.reindex();
    w.log(now, 'info', 'Deleted ${t.name} for good · modules moved to stash');
    return const Outcome(true, 'Turf deleted for good', Buzz.warn);
  }

  // ------------------------------------------------------------ modules

  int freeSocket(Turf t) {
    final used = {for (final m in w.modulesOn(t.id)) m.socket};
    for (var i = 0; i < w.socketsOf(t); i++) {
      if (!used.contains(i)) return i;
    }
    return -1;
  }

  /// One more module socket on a turf, bought outright. No ceiling: each one
  /// on the same turf costs double the last.
  Quote socketQuote(String id) {
    final t = w.turfs[id];
    if (t == null || !t.isPlayer) return const Quote.blocked('Not your turf');
    return _q(socketExpandCost(w.extraSockets(id), discount: _discount));
  }

  Outcome expandSocket(String id, int now) {
    final q = socketQuote(id);
    if (!q.allowed) return Outcome.fail(q.blocker ?? 'Not enough funds');
    _pay(q.cost);
    final t = w.turfs[id]!;
    w.addSocket(id);
    w.revision++;
    w.log(now, 'gain', 'Socket added at ${t.name} · ${w.socketsOf(t)} sockets');
    return Outcome(true, '${t.name} now has ${w.socketsOf(t)} sockets', Buzz.surge);
  }

  Outcome install(String moduleId, String turfId, int now) {
    final t = w.turfs[turfId];
    if (t == null || !t.isPlayer) return const Outcome.fail('Select one of your turfs first');
    final idx = w.stash.indexWhere((m) => m.id == moduleId);
    if (idx < 0) return const Outcome.fail('Module not in stash');
    final socket = freeSocket(t);
    if (socket < 0) return const Outcome.fail('No free socket: add one on the turf or in Crew > Trade');
    final m = w.stash.removeAt(idx)
      ..hexId = turfId
      ..socket = socket;
    (w.installed[turfId] ??= []).add(m);
    w.modulesDirty = true;
    w.reindex();
    return Outcome(true, 'Socketed into ${t.name}', Buzz.click);
  }

  Outcome uninstall(String moduleId, int now) {
    for (final entry in w.installed.entries) {
      final i = entry.value.indexWhere((m) => m.id == moduleId);
      if (i < 0) continue;
      final m = entry.value.removeAt(i)
        ..hexId = null
        ..socket = -1;
      if (entry.value.isEmpty) w.installed.remove(entry.key);
      w.stash.add(m);
      w.modulesDirty = true;
      w.reindex();
      return const Outcome(true, 'Module pulled to stash', Buzz.click);
    }
    return const Outcome.fail('Module not installed');
  }

  Outcome scrap(String moduleId, int now) {
    final idx = w.stash.indexWhere((m) => m.id == moduleId);
    if (idx < 0) return const Outcome.fail('Module not in stash');
    final m = w.stash.removeAt(idx);
    final value = LootTable.scrapValue(m);
    p.materials += value;
    w.modulesDirty = true;
    return Outcome(true, 'Scrapped for ${fmtNum(value)} materials', Buzz.click);
  }

  Quote craftQuote() {
    if (p.blueprints <= 0) return const Quote.blocked('No blueprints — intercept convoys');
    final il = p.level + w.index.maxHubLevel ~/ 2;
    return _q(Cost(materials: LootTable.craftMaterials(il)));
  }

  Outcome craft(int now) {
    final q = craftQuote();
    if (!q.allowed) return Outcome.fail(q.blocker ?? 'Not enough materials');
    _pay(q.cost);
    p.blueprints--;
    final m = dropModule(w, _rng(now, 'craft${p.blueprints}'), now,
        minRarity: Rarity.rare, levelBonus: 2, extraLuck: 0.5);
    w.log(now, 'gain', 'Blueprint decrypted: ${m.name}');
    return Outcome(true, '${m.rarity.label}: ${m.name}', Buzz.surge);
  }

  // ------------------------------------------------------------ events

  WorldEvent? _event(String id) {
    for (final e in w.events) {
      if (e.id == id) return e;
    }
    return null;
  }

  void _removeEvent(WorldEvent e) {
    w.events.remove(e);
    w.eventsDirty = true;
    w.reindex();
  }

  /// Distance in meters from a position to a field event, if it has a point.
  double? eventDistanceM(WorldEvent e, double? lat, double? lng) {
    if (lat == null || lng == null) return null;
    final elat = e.lat, elng = e.lng;
    if (elat != null && elng != null) return metersBetween(lat, lng, elat, elng);
    final t = w.turfs[e.target];
    return t == null ? null : metersBetween(lat, lng, t.lat, t.lng);
  }

  double eventRangeM(EventType type) =>
      (type == EventType.convoy ? kConvoyRangeM : kDropRangeM) + w.perks.reachM;

  /// The turf of yours a convoy or dead drop can be grabbed from, when the
  /// player is not close enough on foot.
  Turf? eventVia(WorldEvent e, double? lat, double? lng) {
    if (e.type != EventType.convoy && e.type != EventType.deadDrop) return null;
    final d = eventDistanceM(e, lat, lng);
    if (d != null && d <= eventRangeM(e.type)) return null;
    final elat = e.lat ?? w.turfs[e.target]?.lat, elng = e.lng ?? w.turfs[e.target]?.lng;
    return elat == null || elng == null ? null : reachTurf(elat, elng, turfStrikeRangeM);
  }

  Quote eventQuote(String eventId, double? lat, double? lng) {
    final e = _event(eventId);
    if (e == null) return const Quote.blocked('Event expired');
    switch (e.type) {
      case EventType.lockdown:
        if (lat == null || lng == null || w.grid.cellAt(lat, lng, kDistrictRes) != e.district) {
          return const Quote.blocked('Travel into the district');
        }
        final n = w.turfs.values.where((t) => t.isPlayer && t.district == e.district).length;
        return _q(lockdownCost(_tier, n, w.index.districtHourly(w, e.district!)));
      case EventType.convoy:
      case EventType.deadDrop:
        final range = eventRangeM(e.type);
        final d = eventDistanceM(e, lat, lng);
        if ((d == null || d > range) && eventVia(e, lat, lng) == null) {
          return Quote.blocked('Get within ${range.round()} m',
              note: 'or hold a turf within ${turfStrikeRangeM.round()} m of it');
        }
        return _q(e.type == EventType.convoy ? interceptCost(_tier) : const Cost());
      case EventType.offensive:
        if (e.payload['fortified'] == true) return const Quote.blocked('Already fortified');
        final hub = w.turfs[e.target];
        return _q(fortifyCost(hub?.hubLevel ?? 1));
      case EventType.surge:
      case EventType.market:
        return const Quote.blocked('Passive modifier');
    }
  }

  Outcome resolveEvent(String eventId, double? lat, double? lng, int now) {
    final e = _event(eventId);
    if (e == null) return const Outcome.fail('Event expired');
    final q = eventQuote(eventId, lat, lng);
    if (!q.allowed) return Outcome.fail(q.blocker ?? 'Not enough funds');
    _pay(q.cost);
    final lvl = p.level;
    final rng = _rng(now, e.id);
    switch (e.type) {
      case EventType.lockdown:
        _removeEvent(e);
        grantXp(w, 80 + 4 * lvl, now);
        w.log(now, 'gain', '${lockdownCopy(lvl).action}: district around ${e.payload['near'] ?? 'your turf'} back online');
        return const Outcome(true, 'District back online', Buzz.capture);
      case EventType.convoy:
        final credits = (e.payload['credits'] as num).toDouble();
        final bp = (e.payload['blueprints'] as num).toInt();
        p.credits += credits;
        p.lifetimeCredits += credits;
        p.blueprints += bp;
        final m = dropModule(w, rng, now, minRarity: Rarity.rare, levelBonus: 2);
        _removeEvent(e);
        grantXp(w, 120 + 5 * lvl, now);
        w.log(now, 'gain',
            '${convoyCopy(lvl).title} intercepted · ${fmtNum(credits)} cr, $bp blueprint${bp > 1 ? 's' : ''}, ${m.name}');
        return Outcome(true, 'Intercepted · +$bp blueprint · ${m.rarity.label} module', Buzz.surge);
      case EventType.deadDrop:
        final mat = (e.payload['materials'] as num).toDouble();
        final intel = (e.payload['intel'] as num).toDouble();
        p.materials += mat;
        p.intel += intel;
        var extra = '';
        if (e.payload['module'] == true) {
          final m = dropModule(w, rng, now, minRarity: Rarity.uncommon);
          extra = ' · ${m.name}';
        }
        _removeEvent(e);
        grantXp(w, 60 + 3 * lvl, now);
        w.log(now, 'gain', '${deadDropCopy(lvl).title} recovered · +${fmtNum(mat)} mat, +${fmtNum(intel)} intel$extra');
        return Outcome(true, 'Drop recovered$extra', Buzz.capture);
      case EventType.offensive:
        e.payload['fortified'] = true;
        w.eventsDirty = true;
        w.log(now, 'info', '${offensiveCopy(lvl).action}: defenses x2.5 for the assault');
        return const Outcome(true, 'Fortified · defense x2.5', Buzz.click);
      case EventType.surge:
      case EventType.market:
        return const Outcome.fail('Passive modifier');
    }
  }

  // ------------------------------------------------------------ exchange

  /// What the empire produces per hour, priced in credits.
  double get hourlyValue {
    final h = w.index.hourly;
    return h.credits + h.materials * goodValue(Good.materials) + h.intel * goodValue(Good.intel);
  }

  /// Credits' worth the exchange moves per day, and what is left of it today.
  double get tradeCap => tradeDailyCap(p.level, hourlyValue);
  double tradeLeft(int now) => math.max(0, tradeCap - w.tradeUsed(now ~/ kDay));

  /// Units of [to] received for one unit of [from], after the fence's cut.
  double tradeRate(Good from, Good to) => goodValue(from) / goodValue(to) * (1 - kTradeFee);

  /// The most of [from] that can be traded right now: what you hold, up to
  /// what is left of today's limit.
  double tradeMax(Good from, int now) => math.min(p.have(from), tradeLeft(now) / goodValue(from));

  Outcome trade(Good from, Good to, double amount, int now) {
    if (from == to) return const Outcome.fail('Pick two different goods');
    if (amount <= 0) return const Outcome.fail('Nothing to trade');
    if (p.have(from) + 1e-9 < amount) return Outcome.fail('Not enough ${from.label.toLowerCase()}');
    final value = amount * goodValue(from);
    if (value > tradeLeft(now) + 1e-6) {
      return const Outcome.fail("Over today's limit: it grows with your level and your hourly output");
    }
    final got = amount * tradeRate(from, to);
    p.add(from, -amount);
    p.add(to, got);
    w.addTradeUsed(now ~/ kDay, value);
    w.log(now, 'info', 'Traded ${fmtNum(amount)} ${from.unit} for ${fmtNum(got)} ${to.unit}');
    return Outcome(true, '+${fmtNum(got)} ${to.unit} for ${fmtNum(amount)} ${from.unit}', Buzz.click);
  }

  // ------------------------------------------------------------ perks

  Quote perkQuote(StreetPerk perk) {
    final rank = w.perkRanks[perk.key] ?? 0;
    if (perk.maxed(rank)) return const Quote.blocked('Maxed out');
    return _q(perk.costForRank(rank));
  }

  Outcome buyPerk(StreetPerk perk, int now) {
    final q = perkQuote(perk);
    if (!q.allowed) return Outcome.fail(q.blocker ?? 'Not enough funds');
    _pay(q.cost);
    final rank = (w.perkRanks[perk.key] ?? 0) + 1;
    w.perkRanks[perk.key] = rank;
    w.perksDirty = true;
    w.reindex();
    w.log(now, 'gain', 'Perk ${perk.title} rank $rank · ${w.perks.valueLabel(perk)}');
    return Outcome(true, '${perk.title} rank $rank · ${w.perks.valueLabel(perk)}', Buzz.surge);
  }

  // ------------------------------------------------------------ jobs

  /// Jobs the player can see: everything unlocked, plus the next locked one.
  List<JobDef> jobBoard() {
    final out = <JobDef>[];
    var teaser = false;
    for (final j in jobs) {
      if (j.unlockLevel <= p.level) {
        out.add(j);
      } else if (!teaser) {
        out.add(j);
        teaser = true;
      }
    }
    return out;
  }

  int jobRuns(JobDef j) => w.jobRuns[j.id] ?? 0;

  /// Credits a job pays right now (before the +-10% roll).
  double jobPayout(JobDef j, {required bool atHome}) =>
      j.energy *
      kJobCreditsPerEnergy *
      jobTierMult(j.tier) *
      (1 + 0.15 * (p.level - 1)) *
      (1 + kJobMasteryBonus * masteryRank(jobRuns(j))) *
      (atHome ? kHomeTurfBonus : 1);

  String? jobBlocker(JobDef j) {
    if (j.unlockLevel > p.level) return 'Unlocks at level ${j.unlockLevel}';
    if (p.energy + 1e-9 < j.energy) return 'Need ${j.energy} energy';
    return null;
  }

  Outcome runJob(String jobId, int now, {bool atHome = false}) {
    final j = jobById(jobId);
    if (j == null) return const Outcome.fail('Unknown job');
    final blocker = jobBlocker(j);
    if (blocker != null) return Outcome.fail(blocker);
    p.energy -= j.energy;
    final runs = jobRuns(j) + 1;
    w.jobRuns[j.id] = runs;
    w.jobsDirty = true;
    final rng = _rng(now, 'job${j.id}$runs');
    final tm = jobTierMult(j.tier);
    final credits = jobPayout(j, atHome: atHome) * rng.range(0.9, 1.1);
    p.credits += credits;
    p.lifetimeCredits += credits;
    p.intel += j.intel * j.energy * tm;
    p.materials += j.materials * j.energy * tm;
    var extra = '';
    if (rng.chance(0.02 + 0.004 * j.energy)) {
      final m = dropModule(w, rng, now);
      extra = ' · found ${m.name}';
      w.log(now, 'gain', '${j.title}: found ${m.name}');
    }
    if (runs % kJobMasteryRuns == 0) {
      extra = '$extra · mastery ${masteryRank(runs)}';
      w.log(now, 'gain', '${j.title}: mastery ${masteryRank(runs)} (+${(kJobMasteryBonus * 100).round()}% payout)');
    }
    grantXp(w, (j.energy * kJobXpPerEnergy * math.sqrt(tm)).round(), now);
    return Outcome(true, '+${fmtNum(credits)} cr$extra', Buzz.click);
  }

  // ------------------------------------------------------------ prestige

  PrestigeStatus prestigeStatus() {
    final ix = w.index;
    return PrestigeStatus(
      owned: ix.owned,
      districts: ix.bestLinkedRegions,
      capital: ix.maxHubLevel,
      keys: liquidationKeys(
        owned: math.max(ix.owned, kPrestigeHexes),
        districts: math.max(kPrestigeDistricts, ix.bestLinkedRegions),
        capitalLevel: math.max(ix.maxHubLevel, kPrestigeCapitalLevel),
        liquidations: p.liquidations,
      ),
    );
  }

  Outcome liquidate(int now, int newSeed) {
    final s = prestigeStatus();
    if (!s.ready) return const Outcome.fail('Empire too small to liquidate');
    final vault = w.vault;
    p.keys += s.keys;
    p.liquidations++;
    for (final id in w.turfs.keys.toList()) {
      w.deleteTurf(id);
    }
    w.installed.clear();
    w.stash.clear();
    w.events.clear();
    w.modulesDirty = true;
    w.eventsDirty = true;
    p
      ..credits = kStartCredits + vault.startCredits
      ..materials = kStartMaterials + vault.startMaterials
      ..intel = kStartIntel
      ..level = 1
      ..xp = 0
      ..blueprints = 0
      ..heat = 0
      ..worldSeed = newSeed;
    final rng = Rng(newSeed);
    for (final f in w.factions) {
      f
        ..wins = 0
        ..losses = 0
        ..nemesisRank = 0
        ..aggression = rng.range(0.75, 1.3);
    }
    w.factionsDirty = true;
    w.clearGenomeCache();
    w.clearRazed();
    w.clearTurfExtras();
    w.reindex();
    w.log(now, 'event', 'NETWORK LIQUIDATED · +${s.keys} Offshore Cryptokeys. New city, new genetics. Rebuild.');
    return Outcome(true, '+${s.keys} Cryptokeys secured offshore', Buzz.surge);
  }

  Outcome buyVault(VaultUpgrade u, int now) {
    final rank = w.vaultRanks[u.key] ?? 0;
    final cost = u.costForRank(rank);
    if (p.keys < cost) return const Outcome.fail('Not enough Cryptokeys');
    p.keys -= cost;
    w.vaultRanks[u.key] = rank + 1;
    w.vaultDirty = true;
    w.reindex();
    return Outcome(true, '${u.title} rank ${rank + 1}', Buzz.surge);
  }
}
