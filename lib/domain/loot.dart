import 'dart:math' as math;

import '../core/format.dart';
import '../core/rng.dart';
import 'models.dart';
import 'tiers.dart';

/// Procedural module generator (ARPG loot). Stats are floats with no hard
/// ceiling: item level grows forever, and a Pareto tail on quality means a
/// better roll always exists.
class LootTable {
  static const _thresholds = [
    (Rarity.mythic, 0.003),
    (Rarity.legendary, 0.015),
    (Rarity.epic, 0.06),
    (Rarity.rare, 0.18),
    (Rarity.uncommon, 0.45),
  ];

  static Rarity rollRarity(Rng rng, {double luck = 0, Rarity min = Rarity.common}) {
    final u = rng.nextDouble() / (1 + luck);
    var r = Rarity.common;
    for (final (rarity, p) in _thresholds) {
      if (u < p) {
        r = rarity;
        break;
      }
    }
    return r.index < min.index ? min : r;
  }

  static int itemLevel(Rng rng, {required int playerLevel, required int maxHubLevel, int bonus = 0}) =>
      math.max(1, playerLevel + maxHubLevel ~/ 2 + bonus + rng.nextInt(4));

  static Module roll(
    Rng rng, {
    required int playerLevel,
    required int maxHubLevel,
    required int now,
    double luck = 0,
    Rarity minRarity = Rarity.common,
    int levelBonus = 0,
  }) {
    final rarity = rollRarity(rng, luck: luck, min: minRarity);
    final il = itemLevel(rng, playerLevel: playerLevel, maxHubLevel: maxHubLevel, bonus: levelBonus);
    final tier = tierFor(playerLevel);
    final base = rng.pick(moduleBases[tier]!);

    var quality = rng.range(0.7, 1.3);
    var exceptional = false;
    if (rng.chance(0.03 + luck * 0.02)) {
      quality *= rng.pareto(2.2);
      exceptional = true;
    }
    final magnitude = 0.04 * math.pow(il, 0.85) * rarity.mult * quality;
    final cash = magnitude * base.cash;
    final def = magnitude * base.def * 1.5;

    Perk? perk;
    var perkValue = 0.0;
    final perkChance = switch (rarity) {
      Rarity.common => 0.0,
      Rarity.uncommon => 0.3,
      _ => 1.0,
    };
    if (rng.chance(perkChance)) {
      var chosen = rng.chance(0.6) ? base.perk : rng.pick(Perk.values);
      if (chosen == Perk.supplyRadius && rarity.index < Rarity.epic.index) chosen = Perk.bulwark;
      perk = chosen;
      perkValue = perkMagnitude(chosen, il, rarity, quality);
    }

    final mk = 1 + il ~/ 10;
    final name = '${rarityPrefix[rarity]}${base.name}${exceptional ? ' ★' : ''} Mk.${roman(mk)}';
    return Module(
      id: rng.hexId(16),
      name: name,
      rarity: rarity,
      cashMult: cash,
      defMult: def,
      itemLevel: il,
      perk: perk,
      perkValue: perkValue,
      acquiredAt: now,
    );
  }

  static double perkMagnitude(Perk perk, int il, Rarity r, double quality) {
    final q = math.max(0.5, quality);
    return switch (perk) {
      Perk.relayRange => 0.03 * math.sqrt(il) * r.mult * q,
      Perk.supplyRadius => r.index >= Rarity.legendary.index ? 2 : 1,
      Perk.intelSiphon => 0.4 * math.pow(il, 0.8) * r.mult * q,
      Perk.materialForge => 0.8 * math.pow(il, 0.8) * r.mult * q,
      Perk.autoRepair => 1.5 * math.pow(il, 0.2) * r.mult * q,
      Perk.bulwark => 0.02 * math.sqrt(il) * r.mult * q,
    };
  }

  static double scrapValue(Module m) => 12.0 * m.itemLevel * m.rarity.mult;

  static double craftMaterials(int itemLevelHint) => 80 * math.pow(math.max(1, itemLevelHint), 1.1).toDouble();
}

String perkText(Perk p, double v) => switch (p) {
      Perk.relayRange => '+${(v * 100).toStringAsFixed(1)}% relay range',
      Perk.supplyRadius => '+${v.round()} supply radius',
      Perk.intelSiphon => '+${v.toStringAsFixed(1)} intel/h',
      Perk.materialForge => '+${v.toStringAsFixed(1)} materials/h',
      Perk.autoRepair => '+${v.toStringAsFixed(1)} integrity/h',
      Perk.bulwark => '+${(v * 100).toStringAsFixed(1)}% sphere defense',
    };
