import 'dart:math' as math;

import 'balance.dart';
import 'models.dart';
import 'world.dart';

/// What a shop item does: a timed boost, or something handed over at once.
enum ShopKind { offense, defense, supplies }

/// The fence's shop (Crew > Shop). Prices follow what the empire earns per
/// hour, so every item stays worth a thought at any stage, and each one
/// bought again on the same day costs 50% more (Energy Drink doubles).
enum ShopItem {
  hiredGuns(kBoostHiredGuns, 'Hired Guns', 'x1.5 strike on every breach for 3 hours.', ShopKind.offense,
      boostMs: 3 * kHour),
  insideMan(kBoostInsideMan, 'Inside Man', 'Rival turfs defend 30% weaker for 3 hours.', ShopKind.offense,
      boostMs: 3 * kHour),
  barricades(kBoostBarricades, 'Barricades', 'x1.5 defense on every turf you hold for 12 hours.', ShopKind.defense,
      boostMs: 12 * kHour),
  ceasefire(kBoostCeasefire, 'Ceasefire', 'No raids on any of your turfs for 6 hours. Offensives already announced still land.',
      ShopKind.defense,
      boostMs: 6 * kHour),
  repairCrew('repair_crew', 'Repair Crew', 'Every damaged turf back to 100%, wherever it is. Lifts sieges.',
      ShopKind.defense),
  energyDrink('energy_drink', 'Energy Drink', 'Energy refilled to the maximum.', ShopKind.supplies),
  supplyCrate('supply_crate', 'Supply Crate', 'One module, Uncommon or better.', ShopKind.supplies),
  blueprint('blueprint', 'Blueprint', 'One blueprint to decrypt in Crew > Modules.', ShopKind.supplies);

  const ShopItem(this.key, this.title, this.blurb, this.kind, {this.boostMs = 0});
  final String key;
  final String title;
  final String blurb;
  final ShopKind kind;

  /// How long the boost runs; 0 for items that act at once.
  final int boostMs;

  bool get isBoost => boostMs > 0;

  /// Price before today's mark-up. [hourly] is the empire's output per hour
  /// in credits' worth. Repair Crew is priced from the damage instead.
  Cost basePrice({required int level, required double hourly}) => switch (this) {
        hiredGuns => Cost(credits: math.max(200, hourly), intel: 10 + 2.0 * level),
        insideMan => Cost(credits: math.max(150, 0.75 * hourly), intel: 20 + 4.0 * level),
        barricades => Cost(credits: math.max(300, 2 * hourly), materials: math.max(60, 0.25 * hourly)),
        ceasefire => Cost(credits: math.max(500, 3 * hourly), intel: 15 + 3.0 * level),
        repairCrew => const Cost(),
        energyDrink => Cost(credits: math.max(100, 0.5 * hourly)),
        supplyCrate => Cost(credits: math.max(400, 3 * hourly), materials: math.max(80, 0.5 * hourly)),
        blueprint => Cost(credits: math.max(600, 4 * hourly), intel: 30 + 5.0 * level),
      };

  /// Mark-up for the [bought]-th purchase of the day (0 = first).
  double markup(int bought) => this == energyDrink ? math.pow(2, bought).toDouble() : 1 + 0.5 * bought;
}

/// Repair Crew charges this share of what repairing each turf by hand costs.
const kRepairCrewShare = 0.75;
