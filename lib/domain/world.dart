import 'dart:math' as math;

import 'package:latlong2/latlong.dart' show LatLng;

import '../geo/hex_grid.dart';
import 'balance.dart';
import 'genetics.dart';
import 'models.dart';
import 'perks.dart';
import 'vault.dart';

class LogEntry {
  const LogEntry(this.ts, this.kind, this.message, {this.alert});
  final int ts;
  final String kind; // info | gain | loss | event | system
  final String message;

  /// Set on lines worth a notification: its title.
  final String? alert;
}

/// Entire mutable game state held in memory. The simulator and actions mutate
/// it; the repository persists whatever is marked dirty in batched writes.
class World {
  World({
    required this.grid,
    required this.player,
    required this.turfs,
    required this.installed,
    required this.stash,
    required this.events,
    required this.factions,
    required this.vaultRanks,
    Map<String, int>? perkRanks,
    Map<String, int>? jobRuns,
  })  : perkRanks = perkRanks ?? {},
        jobRuns = jobRuns ?? {} {
    reindex();
  }

  final HexGrid grid;
  final PlayerData player;

  /// Persisted turfs (yours + rival turfs that changed hands or expanded).
  final Map<String, Turf> turfs;
  final Map<String, List<Module>> installed;
  final List<Module> stash;
  final List<WorldEvent> events;
  final List<Faction> factions;
  final Map<String, int> vaultRanks;

  /// Street perk ranks (perks.dart) and job run counters (jobs.dart).
  final Map<String, int> perkRanks;
  final Map<String, int> jobRuns;

  // Persistence bookkeeping.
  final dirtyTurfs = <String>{};
  final deletedTurfs = <String>{};
  bool modulesDirty = false;
  bool eventsDirty = false;
  bool factionsDirty = false;
  bool vaultDirty = false;
  bool perksDirty = false;
  bool jobsDirty = false;
  final pendingLog = <LogEntry>[];

  /// Monotonic counter bumped on every structural change (UI repaint key).
  int revision = 0;

  late WorldIndex index;

  /// Persisted turfs bucketed by res-9 block for fast proximity queries.
  final _buckets = <String, List<Turf>>{};

  VaultEffects get vault => VaultEffects(vaultRanks);
  PerkEffects get perks => PerkEffects(perkRanks);

  void reindex() {
    _buckets.clear();
    for (final t in turfs.values) {
      (_buckets[t.block] ??= []).add(t);
    }
    index = WorldIndex.build(this);
    revision++;
  }

  void markTurf(Turf t) {
    dirtyTurfs.add(t.id);
    deletedTurfs.remove(t.id);
  }

  /// Stores a new turf and makes it visible to proximity queries at once.
  void addTurf(Turf t) {
    turfs[t.id] = t;
    (_buckets[t.block] ??= []).add(t);
    markTurf(t);
  }

  void deleteTurf(String id) {
    turfs.remove(id);
    dirtyTurfs.remove(id);
    deletedTurfs.add(id);
  }

  // ------------------------------------------------------------- razed spots

  /// Spots the player deleted for good. No rival crew moves back onto one and
  /// auto-plant leaves it alone; only a plant by hand reopens it. Kept in the
  /// player's settings so it travels with the save.
  List<RazedSpot>? _razed;
  Set<String>? _razedIds;

  List<RazedSpot> get razed => _razed ??= [
        for (final e in (player.settings[kRazedKey] as List? ?? const []))
          if (e is List && e.length >= 3) RazedSpot('${e[0]}', (e[1] as num).toDouble(), (e[2] as num).toDouble()),
      ];

  void _saveRazed() {
    _razedIds = null;
    player.settings[kRazedKey] = [
      for (final r in razed) [r.id, r.lat, r.lng],
    ];
  }

  void raze(Turf t) {
    final list = razed..removeWhere((r) => r.id == t.id);
    list.add(RazedSpot(t.id, t.lat, t.lng));
    if (list.length > kRazedMax) list.removeRange(0, list.length - kRazedMax);
    _saveRazed();
  }

  bool isRazed(String turfId) => (_razedIds ??= {for (final r in razed) r.id}).contains(turfId);

  bool razedNear(double lat, double lng, double radiusM) =>
      razed.any((r) => metersBetween(lat, lng, r.lat, r.lng) <= radiusM);

  /// Planting by hand reopens the ground around the new turf.
  void unrazeNear(double lat, double lng, double radiusM) {
    final before = razed.length;
    razed.removeWhere((r) => metersBetween(lat, lng, r.lat, r.lng) <= radiusM);
    if (razed.length != before) _saveRazed();
  }

  void clearRazed() {
    _razed = [];
    _razedIds = null;
    player.settings.remove(kRazedKey);
  }

  void log(int ts, String kind, String message, {String? alert}) =>
      pendingLog.add(LogEntry(ts, kind, message, alert: alert));

  // ------------------------------------------------------------- sieges

  /// When the player last had the game open. A save from before this existed
  /// counts its last sync.
  int get seenAt => (player.settings[kSeenKey] as num?)?.toInt() ?? player.lastSync;

  /// Call once the simulation has caught up to [now] with the game on screen.
  void markSeen(int now) => player.settings[kSeenKey] = now;

  Map<String, dynamic> _bag(String key) {
    final v = player.settings[key];
    if (v is Map<String, dynamic>) return v;
    return player.settings[key] = <String, dynamic>{if (v is Map) ...v.cast<String, dynamic>()};
  }

  /// Time of the first hit a turf took that has not been repaired since.
  int? siegeSince(String turfId) => ((player.settings[kSiegeKey] as Map?)?[turfId] as num?)?.toInt();

  void besiege(Turf t, int ts) => _bag(kSiegeKey).putIfAbsent(t.id, () => ts);

  void liftSiege(String turfId) => (player.settings[kSiegeKey] as Map?)?.remove(turfId);

  /// Rivals may only seize a turf the player has seen wounded: it took its
  /// first hit before the game was last opened. A turf can never be hit for
  /// the first time and lost within one absence.
  bool exposed(Turf t) {
    final since = siegeSince(t.id);
    return since != null && since < seenAt;
  }

  // ------------------------------------------------------------- bought sockets

  int extraSockets(String turfId) => ((player.settings[kSocketsKey] as Map?)?[turfId] as num?)?.toInt() ?? 0;

  int socketsOf(Turf t) => socketCount(t) + extraSockets(t.id);

  void addSocket(String turfId) => _bag(kSocketsKey)[turfId] = extraSockets(turfId) + 1;

  /// Forgets everything kept per turf outside the turf rows.
  void forgetTurf(String turfId) {
    liftSiege(turfId);
    (player.settings[kSocketsKey] as Map?)?.remove(turfId);
  }

  void clearTurfExtras() {
    player.settings.remove(kSiegeKey);
    player.settings.remove(kSocketsKey);
  }

  // ------------------------------------------------------------- exchange

  /// Credits' worth already traded on in-game day [day].
  double tradeUsed(int day) {
    final v = player.settings[kTradeKey];
    if (v is List && v.length >= 2 && (v[0] as num).toInt() == day) return (v[1] as num).toDouble();
    return 0;
  }

  void addTradeUsed(int day, double value) => player.settings[kTradeKey] = [day, tradeUsed(day) + value];

  /// Independent copy for dry runs (the alert forecast). Shares only the grid.
  World clone() => World(
        grid: grid,
        player: player.copy(),
        turfs: {for (final t in turfs.values) t.id: t.copy()},
        installed: {
          for (final e in installed.entries) e.key: [for (final m in e.value) m.copy()],
        },
        stash: [for (final m in stash) m.copy()],
        events: [for (final e in events) e.copy()],
        factions: [for (final f in factions) f.copy()],
        vaultRanks: Map.of(vaultRanks),
        perkRanks: Map.of(perkRanks),
        jobRuns: Map.of(jobRuns),
      );

  // ------------------------------------------------------------- genetics

  final _genomes = <String, Genome>{};
  final _presets = <String, Turf?>{};
  final _presetById = <String, Turf>{};

  Genome genome(String block) {
    final g = _genomes[block];
    if (g != null) return g;
    final made = genomeFor(block, grid.parent(block, 8), player.worldSeed);
    if (_genomes.length > 20000) _genomes.clear();
    return _genomes[block] = made;
  }

  void clearGenomeCache() {
    _genomes.clear();
    _presets.clear();
    _presetById.clear();
  }

  /// Builds (does not store) a turf at an exact point.
  Turf makeTurf({
    required double lat,
    required double lng,
    required String name,
    required String owner,
    required int now,
    bool isStation = false,
  }) {
    final block = grid.cellAt(lat, lng, kPlayRes);
    final g = genome(block);
    return Turf(
      id: grid.cellAt(lat, lng, kTurfKeyRes),
      block: block,
      district: grid.parent(block, kDistrictRes),
      lat: lat,
      lng: lng,
      name: name,
      biome: g.biome,
      anomaly: g.anomaly,
      owner: owner,
      lastTick: now,
      isStation: isStation,
    );
  }

  /// A rival crew's day-one turf in [block], unless that spot has been
  /// persisted (taken over) or razed since.
  Turf? presetRival(String block) {
    if (_presets.containsKey(block)) {
      final t = _presets[block];
      return (t == null || turfs.containsKey(t.id) || isRazed(t.id)) ? null : t;
    }
    Turf? t;
    final spawn = rivalSpawnFor(block, player.worldSeed);
    final f = spawn == null ? null : factionByArchetype(spawn.faction);
    if (spawn != null && f != null) {
      final p = offsetLatLng(grid.center(block), spawn.bearing, spawn.distanceM);
      t = makeTurf(lat: p.latitude, lng: p.longitude, name: 'Crew post', owner: factionOwner(f.id), now: 0)
        ..integrity = 100;
      _presetById[t.id] = t;
    }
    if (_presets.length > 30000) {
      _presets.clear();
      _presetById.clear();
    }
    _presets[block] = t;
    return (t == null || turfs.containsKey(t.id) || isRazed(t.id)) ? null : t;
  }

  Turf? turfById(String id) => turfs[id] ?? (isRazed(id) ? null : _presetById[id]);

  /// Every turf (persisted + day-one rivals) within [radiusM] of a point.
  List<Turf> turfsNear(double lat, double lng, double radiusM) {
    final k = (radiusM / 300).ceil() + 1;
    final center = grid.cellAt(lat, lng, kPlayRes);
    final out = <Turf>[];
    for (final block in grid.disk(center, k)) {
      final list = _buckets[block];
      if (list != null) {
        for (final t in list) {
          if (metersBetween(lat, lng, t.lat, t.lng) <= radiusM) out.add(t);
        }
      }
      final p = presetRival(block);
      if (p != null && metersBetween(lat, lng, p.lat, p.lng) <= radiusM) out.add(p);
    }
    return out;
  }

  /// Nearest turf to a point (any owner) and its distance in meters.
  (Turf, double)? nearest(double lat, double lng, {double withinM = 400}) {
    (Turf, double)? best;
    for (final t in turfsNear(lat, lng, withinM)) {
      final d = metersBetween(lat, lng, t.lat, t.lng);
      if (best == null || d < best.$2) best = (t, d);
    }
    return best;
  }

  /// The turf whose zone contains the point, if any.
  Turf? zoneAt(double lat, double lng) {
    final n = nearest(lat, lng, withinM: 200);
    if (n == null) return null;
    return n.$2 <= turfRadiusM(n.$1) ? n.$1 : null;
  }

  Iterable<Turf> get playerTurfs => turfs.values.where((t) => t.isPlayer);

  List<Module> modulesOn(String turfId) => installed[turfId] ?? const [];

  Faction? factionByArchetype(int idx) {
    for (final f in factions) {
      if (f.archetype == idx) return f;
    }
    return factions.isEmpty ? null : factions.first;
  }

  Faction? factionById(String id) {
    for (final f in factions) {
      if (f.id == id) return f;
    }
    return null;
  }

  double threatOf(Faction f) => threatPower(
        maxHubLevel: index.maxHubLevel,
        playerLevel: player.level,
        liquidations: player.liquidations,
        aggression: f.aggression,
        nemesisRank: f.nemesisRank,
      );

  /// Defense of a rival turf when the player tries to breach it.
  double enemyDefense(Turf t) {
    if (!t.isHostile) return 0;
    final f = factionById(factionIdOf(t.owner));
    if (f == null) return 0;
    final persisted = turfs.containsKey(t.id);
    return threatOf(f) * (persisted ? 1.2 : 0.8) * anomalyDefMult(t.anomaly) * (0.5 + t.integrity / 200);
  }

  double kmBetween(Turf a, Turf b) => haversineKm(LatLng(a.lat, a.lng), LatLng(b.lat, b.lng));
}

/// A deleted turf's spot (see [World.razed]).
class RazedSpot {
  const RazedSpot(this.id, this.lat, this.lng);
  final String id;
  final double lat;
  final double lng;
}

const kRazedKey = 'razed';
const kRazedMax = 400;

/// Keys in the player's settings: small state that travels with the save.
const kSeenKey = 'seen';
const kSiegeKey = 'siege';
const kSocketsKey = 'sockets';
const kTradeKey = 'trade';

/// Why a turf pays what it pays: its base output and every multiplier on it.
class TurfYield {
  const TurfYield({
    required this.base,
    required this.garrison,
    required this.modules,
    required this.level,
    required this.hub,
    required this.trade,
    required this.aura,
    required this.supply,
    required this.lockdown,
    required this.surge,
    required this.station,
    required this.market,
    required this.vaultCredits,
    required this.vaultLogistics,
    required this.flat,
  });

  /// Neighbourhood type times anomaly, per hour, before any multiplier.
  final Resources base;
  final double garrison;
  final double modules;
  final double level;
  final double hub;

  /// Network trade multiplier (1 without a hub).
  final double trade;

  /// Yield modules on the supplying hub.
  final double aura;

  /// 1 when a hub supplies it, else the hub-less share.
  final double supply;

  /// 1, the rerouted trickle, or 0 while the district is locked down.
  final double lockdown;
  final double surge;

  /// Credits only: station bonus and the street market.
  final double station;
  final double market;
  final double vaultCredits;
  final double vaultLogistics;

  /// Flat output of forge and siphon modules.
  final Resources flat;

  double get _k => garrison * modules * level * hub * trade * aura * supply * lockdown;

  Resources get total => Resources(
        credits: base.credits * _k * surge * station * vaultCredits * market,
        materials: base.materials * _k * surge * vaultLogistics + flat.materials,
        intel: base.intel * _k * surge * vaultLogistics + flat.intel,
      );
}

class HubStats {
  HubStats(this.hub);
  final Turf hub;
  double radiusKm = 1;
  double relayKm = 0;
  double def = 0;
  double cashAura = 0;
  double bulwark = 0;
  int network = -1;
  bool get canRelay => hub.anomaly != Anomaly.deadZone;
}

class NetworkStats {
  NetworkStats(this.id);
  final int id;
  final hubs = <String>[];
  final districts = <String>{};
  final regions = <String>{};
  int relays = 0;
  double defPool = 0;
  double get trade => tradeMultiplier(districts.length, relays);
}

class _ModSum {
  double cash = 0;
  double def = 0;
  final perks = <Perk, double>{};
}

/// Derived, read-only view of the world: who supplies what, network
/// membership, per-turf yields and defense. Rebuilt after structural changes.
class WorldIndex {
  final supplier = <String, String>{};
  final hubs = <String, HubStats>{};
  final networks = <NetworkStats>[];
  final turfHourly = <String, Resources>{};
  final turfYield = <String, TurfYield>{};
  final turfDefense = <String, double>{};
  final lockedDistricts = <String>{};
  final raidTargets = <String>[];
  final raidCumulative = <double>[];

  int owned = 0;
  int supplied = 0;
  int stations = 0;
  int maxHubLevel = 0;
  int hubLevelSum = 0;
  int bestLinkedDistricts = 0;
  int bestLinkedRegions = 0;
  Resources hourly = const Resources();
  double creditMarket = 1;
  Biome? surgeBiome;

  double get suppliedRatio => owned == 0 ? 0 : supplied / owned;
  double get passiveXpPerHour => 0.3 * owned + 2.0 * hubLevelSum;

  NetworkStats? networkOfHub(String hubId) {
    final h = hubs[hubId];
    if (h == null || h.network < 0) return null;
    return networks[h.network];
  }

  static WorldIndex build(World w) {
    final ix = WorldIndex();
    final vault = w.vault;
    final perkFx = w.perks;

    final mods = <String, _ModSum>{};
    w.installed.forEach((turfId, list) {
      final s = _ModSum();
      for (final m in list) {
        s.cash += m.cashMult;
        s.def += m.defMult;
        if (m.perk != null) s.perks[m.perk!] = (s.perks[m.perk!] ?? 0) + m.perkValue;
      }
      mods[turfId] = s;
    });

    final players = <Turf>[];
    for (final t in w.turfs.values) {
      if (!t.isPlayer) continue;
      players.add(t);
      if (t.isStation) ix.stations++;
      if (t.isHub) {
        ix.hubLevelSum += t.hubLevel;
        ix.maxHubLevel = math.max(ix.maxHubLevel, t.hubLevel);
      }
    }
    ix.owned = players.length;

    // Hubs ----------------------------------------------------------------
    for (final t in players) {
      if (!t.isHub) continue;
      final s = HubStats(t);
      final m = mods[t.id];
      s.radiusKm = hubRadiusKm(t.hubLevel) +
          (t.anomaly == Anomaly.tunnels ? 0.4 : 0) +
          0.3 * (m?.perks[Perk.supplyRadius] ?? 0);
      s.relayKm = relayRangeKm(t.hubLevel) *
          (t.anomaly == Anomaly.signalTower ? 1.5 : 1) *
          (t.isStation ? kStationRelayBonus : 1) *
          vault.relayMult *
          perkFx.relayMult *
          (1 + (m?.perks[Perk.relayRange] ?? 0));
      s.def = hubDef(t.hubLevel) * (1 + (m?.def ?? 0)) * vault.defenseMult;
      s.cashAura = 0.25 * (m?.cash ?? 0);
      s.bulwark = m?.perks[Perk.bulwark] ?? 0;
      ix.hubs[t.id] = s;
    }

    // Supply: nearest hub whose sphere covers the turf.
    for (final t in players) {
      String? best;
      var bestKm = double.infinity;
      for (final s in ix.hubs.values) {
        final km = w.kmBetween(t, s.hub);
        if (km <= s.radiusKm && km < bestKm) {
          bestKm = km;
          best = s.hub.id;
        }
      }
      if (best != null) {
        ix.supplier[t.id] = best;
        ix.supplied++;
      }
    }

    // Networks (union-find over relay edges) -------------------------------
    final parent = <String, String>{for (final id in ix.hubs.keys) id: id};
    String find(String x) {
      var r = x;
      while (parent[r] != r) {
        r = parent[r]!;
      }
      var c = x;
      while (parent[c] != r) {
        final n = parent[c]!;
        parent[c] = r;
        c = n;
      }
      return r;
    }

    final edges = <(String, String)>[];
    for (final s in ix.hubs.values) {
      final target = s.hub.relayTarget;
      if (target == null) continue;
      final ts = ix.hubs[target];
      if (ts == null || !s.canRelay || !ts.canRelay) continue;
      edges.add((s.hub.id, target));
      final a = find(s.hub.id), b = find(target);
      if (a != b) parent[a] = b;
    }
    final rootToNet = <String, int>{};
    for (final s in ix.hubs.values) {
      final root = find(s.hub.id);
      final id = rootToNet.putIfAbsent(root, () {
        ix.networks.add(NetworkStats(ix.networks.length));
        return ix.networks.length - 1;
      });
      s.network = id;
      final n = ix.networks[id];
      n.hubs.add(s.hub.id);
      n.districts.add(s.hub.district);
      n.regions.add(w.grid.parent(s.hub.district, kRegionRes));
      n.defPool += s.def * kNetworkDefShare;
    }
    for (final (a, _) in edges) {
      ix.networks[ix.hubs[a]!.network].relays++;
    }
    for (final n in ix.networks) {
      if (n.relays > 0) {
        ix.bestLinkedDistricts = math.max(ix.bestLinkedDistricts, n.districts.length);
        ix.bestLinkedRegions = math.max(ix.bestLinkedRegions, n.regions.length);
      }
    }

    // Event modifiers --------------------------------------------------------
    for (final e in w.events) {
      switch (e.type) {
        case EventType.lockdown:
          final d = e.district;
          if (d != null) ix.lockedDistricts.add(d);
        case EventType.surge:
          ix.surgeBiome = Biome.fromKey(e.payload['biome'] as String? ?? '');
        case EventType.market:
          ix.creditMarket *= (e.payload['mult'] as num?)?.toDouble() ?? 1;
        default:
          break;
      }
    }

    // Per-turf yield + defense ---------------------------------------------
    final lvlMult = levelYieldMult(w.player.level);
    var total = const Resources();
    for (final t in players) {
      final hubId = ix.supplier[t.id];
      final hubS = hubId == null ? null : ix.hubs[hubId];
      final supplied = hubS != null;
      final net = hubS == null ? null : ix.networks[hubS.network];
      final m = mods[t.id];

      final locked = ix.lockedDistricts.contains(t.district);
      final base = biomeYield(t.biome);
      final an = anomalyYieldMult(t.anomaly);
      final parts = TurfYield(
        base: Resources(
          credits: base.credits * an.credits,
          materials: base.materials * an.materials,
          intel: base.intel * an.intel,
        ),
        garrison: garrisonYieldMult(t.garrison),
        modules: 1 + (m?.cash ?? 0),
        level: lvlMult,
        hub: t.isHub ? hubYieldMult(t.hubLevel) : 1,
        trade: supplied ? net!.trade : 1,
        aura: supplied && hubS.hub.id != t.id ? 1 + hubS.cashAura : 1,
        supply: supplied ? 1 : (t.isStation ? kStationSoloYield : kUnsuppliedYield),
        lockdown: !locked ? 1 : ((net != null && net.districts.length > 1) ? kLockdownReroute : 0),
        surge: ix.surgeBiome == t.biome ? 2.0 : 1.0,
        station: t.isStation ? kStationCreditBonus : 1.0,
        market: ix.creditMarket,
        vaultCredits: vault.creditMult,
        vaultLogistics: vault.logisticsMult,
        flat: locked
            ? const Resources()
            : Resources(
                materials: m?.perks[Perk.materialForge] ?? 0,
                intel: m?.perks[Perk.intelSiphon] ?? 0,
              ),
      );
      final y = parts.total;
      ix.turfYield[t.id] = parts;
      ix.turfHourly[t.id] = y;
      total = total + y;

      var def = garrisonDef(t.garrison) *
          anomalyDefMult(t.anomaly) *
          (1 + (m?.def ?? 0)) *
          (1 + (t.isHub ? 0 : (m?.perks[Perk.bulwark] ?? 0)));
      if (t.isHub) {
        def += ix.hubs[t.id]!.def;
      } else if (supplied) {
        def += hubS.def * kHubDefShare * (1 + hubS.bulwark);
      }
      if (net != null) def += net.defPool;
      def *= math.max(0.25, t.integrity / 100) * vault.defenseMult * perkFx.defenseMult;
      ix.turfDefense[t.id] = def;

      if (t.anomaly != Anomaly.deadZone) {
        final weight = (supplied ? 1.0 : (t.isStation ? 2.0 : 4.0)) *
            (t.anomaly == Anomaly.blackMarket ? 1.5 : 1.0) *
            (t.isHub ? 0.5 : 1.0);
        ix.raidTargets.add(t.id);
        ix.raidCumulative.add((ix.raidCumulative.isEmpty ? 0 : ix.raidCumulative.last) + weight);
      }
    }
    ix.hourly = total;
    return ix;
  }

  String? pickRaidTarget(double unit) {
    if (raidTargets.isEmpty) return null;
    final x = unit * raidCumulative.last;
    var lo = 0, hi = raidCumulative.length - 1;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (raidCumulative[mid] > x) {
        hi = mid;
      } else {
        lo = mid + 1;
      }
    }
    return raidTargets[lo];
  }

  /// Base hourly credits of every player turf in [district] (lockdown pricing).
  double districtHourly(World w, String district) {
    var sum = 0.0;
    for (final t in w.turfs.values) {
      if (t.isPlayer && t.district == district) {
        sum += biomeYield(t.biome).credits * garrisonYieldMult(t.garrison);
      }
    }
    return sum;
  }
}
