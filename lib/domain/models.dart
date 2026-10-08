// In-memory game model. Persistence rows (drift) map to/from these in
// game/repository.dart; the simulation mutates these directly.
//
// Territory is point-based (Turf Wars style): a Turf is a circle zone around
// the exact spot the player claimed. H3 stays underneath as the spatial key.

import 'dart:convert';

enum Biome {
  commercial('commercial', 'Commercial Transit', 'High cash throughput'),
  municipal('municipal', 'Municipal Records', 'Yields research & intel'),
  industrial('industrial', 'Industrial Yards', 'Yields construction materials');

  const Biome(this.key, this.label, this.blurb);
  final String key;
  final String label;
  final String blurb;

  static Biome fromKey(String k) =>
      Biome.values.firstWhere((b) => b.key == k, orElse: () => Biome.commercial);
}

enum Anomaly {
  bunker('bunker', 'Underground Bunker', '+50% defense'),
  deadZone('dead_zone', 'Dead Zone', 'Immune to remote raids · no relays'),
  dataVault('data_vault', 'Data Vault', '+100% intel yield'),
  blackMarket('black_market', 'Black Market', '+50% credits · draws raids'),
  signalTower('signal_tower', 'Signal Tower', '+50% relay range as hub'),
  tunnels('tunnels', 'Tunnel Network', '+0.4 km supply radius as hub'),
  scrapyard('scrapyard', 'Scrapyard', '+100% materials · -20% credits');

  const Anomaly(this.key, this.label, this.effect);
  final String key;
  final String label;
  final String effect;

  static Anomaly? fromKey(String? k) {
    if (k == null) return null;
    for (final a in Anomaly.values) {
      if (a.key == k) return a;
    }
    return null;
  }
}

enum Rarity {
  common('common', 'Common', 1.0),
  uncommon('uncommon', 'Uncommon', 1.35),
  rare('rare', 'Rare', 1.8),
  epic('epic', 'Epic', 2.5),
  legendary('legendary', 'Legendary', 3.6),
  mythic('mythic', 'Mythic', 5.5);

  const Rarity(this.key, this.label, this.mult);
  final String key;
  final String label;
  final double mult;

  static Rarity fromKey(String k) =>
      Rarity.values.firstWhere((r) => r.key == k, orElse: () => Rarity.common);
}

enum Perk {
  relayRange('relay_range', 'Relay range'),
  supplyRadius('supply_radius', 'Supply radius'),
  intelSiphon('intel_siphon', 'Intel siphon'),
  materialForge('material_forge', 'Material forge'),
  autoRepair('auto_repair', 'Auto-repair'),
  bulwark('bulwark', 'Sphere defense');

  const Perk(this.key, this.label);
  final String key;
  final String label;

  static Perk? fromKey(String? k) {
    if (k == null) return null;
    for (final p in Perk.values) {
      if (p.key == k) return p;
    }
    return null;
  }
}

enum EventType {
  lockdown('lockdown'),
  convoy('convoy'),
  deadDrop('dead_drop'),
  surge('surge'),
  market('market'),
  offensive('offensive');

  const EventType(this.key);
  final String key;

  static EventType? fromKey(String k) {
    for (final t in EventType.values) {
      if (t.key == k) return t;
    }
    return null;
  }
}

const kNeutral = 'neutral';
const kPlayer = 'player';
String factionOwner(String factionId) => 'f:$factionId';
bool isFactionOwner(String owner) => owner.startsWith('f:');
String factionIdOf(String owner) => owner.substring(2);

/// A point-anchored territory, planted where the player physically stood.
class Turf {
  Turf({
    required this.id,
    required this.block,
    required this.district,
    required this.lat,
    required this.lng,
    required this.name,
    required this.biome,
    required this.anomaly,
    required this.owner,
    required this.lastTick,
    this.isStation = false,
    this.garrison = 1,
    this.integrity = 100,
    this.isHub = false,
    this.hubLevel = 0,
    this.relayTarget,
    this.capturedAt,
  });

  /// Res-11 H3 cell of the center: unique key.
  final String id;

  /// Res-9 H3 block the turf sits in: source of its genetics.
  final String block;

  /// Res-6 H3 macro district.
  final String district;
  final double lat;
  final double lng;
  String name;
  final Biome biome;
  final Anomaly? anomaly;
  bool isStation;
  String owner;
  int garrison;
  double integrity;
  bool isHub;
  int hubLevel;
  String? relayTarget;
  int lastTick;
  int? capturedAt;

  bool get isPlayer => owner == kPlayer;
  bool get isHostile => isFactionOwner(owner);

  Turf copy() => Turf(
        id: id,
        block: block,
        district: district,
        lat: lat,
        lng: lng,
        name: name,
        biome: biome,
        anomaly: anomaly,
        owner: owner,
        lastTick: lastTick,
        isStation: isStation,
        garrison: garrison,
        integrity: integrity,
        isHub: isHub,
        hubLevel: hubLevel,
        relayTarget: relayTarget,
        capturedAt: capturedAt,
      );
}

class Module {
  Module({
    required this.id,
    required this.name,
    required this.rarity,
    required this.cashMult,
    required this.defMult,
    required this.itemLevel,
    this.perk,
    this.perkValue = 0,
    this.hexId,
    this.socket = -1,
    this.acquiredAt = 0,
  });

  final String id;
  final String name;
  final Rarity rarity;
  final double cashMult;
  final double defMult;
  final int itemLevel;
  final Perk? perk;
  final double perkValue;
  String? hexId; // turf id; null = in stash
  int socket;
  int acquiredAt;

  /// Single comparable number for sorting "which one is better".
  double get score =>
      cashMult + defMult + (perk == null ? 0 : 0.08 * rarity.mult) + itemLevel * 1e-4;

  Module copy() => Module(
        id: id,
        name: name,
        rarity: rarity,
        cashMult: cashMult,
        defMult: defMult,
        itemLevel: itemLevel,
        perk: perk,
        perkValue: perkValue,
        hexId: hexId,
        socket: socket,
        acquiredAt: acquiredAt,
      );
}

class WorldEvent {
  WorldEvent({
    required this.id,
    required this.type,
    required this.target,
    required this.expiresAt,
    required this.payload,
  });

  final String id;
  final EventType type;
  final String target; // h3 cell (district events store a member cell)
  int expiresAt;
  final Map<String, dynamic> payload;

  int get createdAt => (payload['created'] as num?)?.toInt() ?? 0;
  String? get district => payload['district'] as String?;

  /// Field events (convoy, dead drop) sit on an exact point.
  double? get lat => (payload['lat'] as num?)?.toDouble();
  double? get lng => (payload['lng'] as num?)?.toDouble();

  WorldEvent copy() =>
      WorldEvent(id: id, type: type, target: target, expiresAt: expiresAt, payload: Map.of(payload));
}

class Faction {
  Faction({
    required this.id,
    required this.archetype,
    required this.aggression,
    this.nemesisRank = 0,
    this.wins = 0,
    this.losses = 0,
  });

  final String id;
  final int archetype; // 0..2, name depends on current tier
  double aggression;
  int nemesisRank;
  int wins;
  int losses;

  Faction copy() => Faction(
        id: id,
        archetype: archetype,
        aggression: aggression,
        nemesisRank: nemesisRank,
        wins: wins,
        losses: losses,
      );
}

/// The three resources, as goods on the exchange.
enum Good {
  credits('CR', 'Credits'),
  materials('MAT', 'Materials'),
  intel('INT', 'Intel');

  const Good(this.unit, this.label);
  final String unit;
  final String label;
}

class PlayerData {
  PlayerData({
    required this.credits,
    required this.materials,
    required this.intel,
    required this.keys,
    required this.level,
    required this.xp,
    required this.lastLat,
    required this.lastLng,
    required this.lastSync,
    required this.monotonic,
    required this.worldSeed,
    required this.bootCount,
    required this.wallAtSync,
    required this.tamperStrikes,
    required this.blueprints,
    required this.liquidations,
    required this.lifetimeCredits,
    required this.lastEventDay,
    required this.heat,
    required this.createdAt,
    required this.settings,
    this.energy = 30,
  });

  double credits;
  double materials;
  double intel;
  int keys;
  int level;
  int xp;
  double? lastLat;
  double? lastLng;
  int lastSync;
  int monotonic;
  int worldSeed;
  int bootCount;
  int wallAtSync;
  int tamperStrikes;
  int blueprints;
  int liquidations;
  double lifetimeCredits;
  int lastEventDay;
  double heat;
  int createdAt;
  Map<String, dynamic> settings;

  /// Spent on jobs, regenerates over time.
  double energy;

  double have(Good g) => switch (g) {
        Good.credits => credits,
        Good.materials => materials,
        Good.intel => intel,
      };

  void add(Good g, double amount) {
    switch (g) {
      case Good.credits:
        credits += amount;
      case Good.materials:
        materials += amount;
      case Good.intel:
        intel += amount;
    }
  }

  PlayerData copy() => PlayerData(
        credits: credits,
        materials: materials,
        intel: intel,
        keys: keys,
        level: level,
        xp: xp,
        lastLat: lastLat,
        lastLng: lastLng,
        lastSync: lastSync,
        monotonic: monotonic,
        worldSeed: worldSeed,
        bootCount: bootCount,
        wallAtSync: wallAtSync,
        tamperStrikes: tamperStrikes,
        blueprints: blueprints,
        liquidations: liquidations,
        lifetimeCredits: lifetimeCredits,
        lastEventDay: lastEventDay,
        heat: heat,
        createdAt: createdAt,
        settings: (jsonDecode(jsonEncode(settings)) as Map).cast<String, dynamic>(),
        energy: energy,
      );
}

class Resources {
  const Resources({this.credits = 0, this.materials = 0, this.intel = 0});
  final double credits;
  final double materials;
  final double intel;

  Resources operator +(Resources o) =>
      Resources(credits: credits + o.credits, materials: materials + o.materials, intel: intel + o.intel);
  Resources operator *(double k) =>
      Resources(credits: credits * k, materials: materials * k, intel: intel * k);
  bool get isZero => credits == 0 && materials == 0 && intel == 0;
}

class Cost {
  const Cost({this.credits = 0, this.materials = 0, this.intel = 0});
  final double credits;
  final double materials;
  final double intel;

  bool affordable(PlayerData p) =>
      p.credits + 1e-9 >= credits && p.materials + 1e-9 >= materials && p.intel + 1e-9 >= intel;

  void pay(PlayerData p) {
    p.credits -= credits;
    p.materials -= materials;
    p.intel -= intel;
  }
}
