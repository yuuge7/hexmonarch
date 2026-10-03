import '../core/rng.dart';
import 'models.dart';

/// Procedural Hex Genetics. Attributes are a pure function of the H3 index of
/// a res-9 block and the hidden WorldSeed, so every device regenerates the same
/// map without storing untouched ground. Every turf inherits its block's genome.
class Genome {
  const Genome({required this.biome, required this.anomaly});
  final Biome biome;
  final Anomaly? anomaly;
}

/// A rival crew's day-one turf inside a block: faction + offset from the
/// block center.
class RivalSpawn {
  const RivalSpawn({required this.faction, required this.bearing, required this.distanceM});
  final int faction;
  final double bearing; // radians
  final double distanceM;
}

const kAnomalyChance = 0.15;
const kPresetRivalChance = 0.09;

const _biomeWeights = {
  Biome.commercial: 0.40,
  Biome.municipal: 0.25,
  Biome.industrial: 0.35,
};

const _anomalyWeights = {
  Anomaly.bunker: 22.0,
  Anomaly.deadZone: 18.0,
  Anomaly.dataVault: 14.0,
  Anomaly.blackMarket: 14.0,
  Anomaly.signalTower: 12.0,
  Anomaly.tunnels: 10.0,
  Anomaly.scrapyard: 10.0,
};

Biome _biomeFromUnit(double u) {
  var acc = 0.0;
  for (final e in _biomeWeights.entries) {
    acc += e.value;
    if (u < acc) return e.key;
  }
  return Biome.industrial;
}

/// [neighborhood] is the cell's coarser parent (res 8). Biomes follow the
/// neighborhood 70% of the time, which clusters them into believable zones.
Genome genomeFor(String cell, String neighborhood, int worldSeed) {
  final h = mix64(fnv1a64(cell) ^ worldSeed);
  final n = mix64(fnv1a64(neighborhood) ^ worldSeed ^ 0xB10E5EED);

  final useCluster = unitFromHash(mix64(h ^ 0x1)) < 0.7;
  final biome = _biomeFromUnit(unitFromHash(useCluster ? n : mix64(h ^ 0x2)));

  Anomaly? anomaly;
  if (unitFromHash(mix64(h ^ 0x3)) < kAnomalyChance) {
    final rng = Rng(mix64(h ^ 0x4));
    anomaly = rng.weighted(_anomalyWeights);
  }

  return Genome(biome: biome, anomaly: anomaly);
}

RivalSpawn? rivalSpawnFor(String block, int worldSeed) {
  final h = mix64(fnv1a64(block) ^ worldSeed ^ 0x51A7C0DE);
  if (unitFromHash(h) >= kPresetRivalChance) return null;
  return RivalSpawn(
    faction: (mix64(h ^ 0x6) >>> 7) % 3,
    bearing: unitFromHash(mix64(h ^ 0x7)) * 6.283185307179586,
    distanceM: 15 + unitFromHash(mix64(h ^ 0x8)) * 95,
  );
}
