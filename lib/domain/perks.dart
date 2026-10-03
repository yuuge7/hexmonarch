import 'dart:math' as math;

import 'models.dart';

/// Street perks: bought with credits + intel, kept through liquidations.
/// (Module perks are the separate [Perk] enum.)
enum StreetPerk {
  plantRange('plant_range', 'Long Arm', 'Plant farther out. Everyone starts at 250 m; each rank adds more.',
      credits: 300, creditGrowth: 1.55, intel: 25, intelGrowth: 1.45),
  reach('reach', 'Deep Reach', 'Breach rival turfs and grab convoys and drops from farther away.',
      credits: 200, creditGrowth: 1.5, intel: 15, intelGrowth: 1.4),
  spacing('spacing', 'Close Quarters', 'Pack turfs tighter together.',
      credits: 250, creditGrowth: 1.5, intel: 20, intelGrowth: 1.4, maxRank: 13),
  relay('relay', 'Signal Boost', 'Relays reach farther from every hub: link towns that are out of range today.',
      credits: 500, creditGrowth: 1.6, intel: 40, intelGrowth: 1.45),
  muscle('muscle', 'Muscle', '+8% strike when breaching, +4% defense on every turf.',
      credits: 200, creditGrowth: 1.45, intel: 10, intelGrowth: 1.35),
  bench('bench', 'Deep Bench', '+10 maximum energy for jobs.',
      credits: 150, creditGrowth: 1.5, intel: 10, intelGrowth: 1.4),
  wind('wind', 'Second Wind', '+10% energy regeneration.',
      credits: 200, creditGrowth: 1.55, intel: 15, intelGrowth: 1.45),
  smarts('smarts', 'Street Smarts', '+5% XP from everything.',
      credits: 250, creditGrowth: 1.6, intel: 30, intelGrowth: 1.5),
  safehouse('safehouse', 'Safehouses', 'Turfs without a hub hold more of their integrity.',
      credits: 300, creditGrowth: 1.7, intel: 20, intelGrowth: 1.5, maxRank: 10);

  const StreetPerk(
    this.key,
    this.title,
    this.blurb, {
    required this.credits,
    required this.creditGrowth,
    required this.intel,
    required this.intelGrowth,
    this.maxRank,
  });

  final String key;
  final String title;
  final String blurb;
  final double credits;
  final double creditGrowth;
  final double intel;
  final double intelGrowth;

  /// Null = infinite ranks.
  final int? maxRank;

  Cost costForRank(int currentRank) => Cost(
        credits: credits * math.pow(creditGrowth, currentRank),
        intel: intel * math.pow(intelGrowth, currentRank),
      );

  bool maxed(int rank) => maxRank != null && rank >= maxRank!;
}

const kBaseEnergyMax = 30.0;
const kBaseEnergyPerHour = 15.0;
const kBaseDecayFloor = 30.0;
const kBaseSpacingM = 100.0;

/// Plant reach every player has from the start, before any Long Arm rank.
const kBasePlantReachM = 250.0;
const kMinSpacingM = 60.0;

/// Relay range gained per Signal Boost rank (+20% of the hub's own range).
const kRelayPerkStep = 0.20;

class PerkEffects {
  const PerkEffects(this.ranks);
  final Map<String, int> ranks;

  int rank(StreetPerk p) => ranks[p.key] ?? 0;

  static double _curve(int r, double unit) => r <= 0 ? 0 : unit * math.pow(r, 0.8);

  /// Usable plant reach: 250 m for everyone, plus Long Arm.
  double get plantReachM => kBasePlantReachM + _curve(rank(StreetPerk.plantRange), 80);

  /// How far from your position a new turf may be planted. The no-plant gap
  /// around turfs does not count against the reach, so standing on a turf you
  /// still get the full [plantReachM] of ground you can actually use.
  double get plantRangeM => spacingM + plantReachM;

  /// Extra distance for breaches and field events.
  double get reachM => _curve(rank(StreetPerk.reach), 20);

  /// Minimum distance between turfs.
  double get spacingM => math.max(kMinSpacingM, kBaseSpacingM * math.pow(0.96, rank(StreetPerk.spacing)));

  /// Multiplier on every hub's relay range.
  double get relayMult => 1 + kRelayPerkStep * rank(StreetPerk.relay);

  double get strikeMult => 1 + 0.08 * rank(StreetPerk.muscle);
  double get defenseMult => 1 + 0.04 * rank(StreetPerk.muscle);
  double get energyMax => kBaseEnergyMax + 10 * rank(StreetPerk.bench);
  double get energyPerHour => kBaseEnergyPerHour * (1 + 0.10 * rank(StreetPerk.wind));
  double get xpMult => 1 + 0.05 * rank(StreetPerk.smarts);

  /// Integrity that hub-less turfs never decay below.
  double get decayFloor => math.min(90, kBaseDecayFloor + 6 * rank(StreetPerk.safehouse));

  /// Current value of a perk, as shown on its card.
  String valueLabel(StreetPerk p, [int? atRank]) {
    final fx = atRank == null ? this : PerkEffects({...ranks, p.key: atRank});
    return switch (p) {
      StreetPerk.plantRange => '${fx.plantReachM.round()} m',
      StreetPerk.reach => '+${fx.reachM.round()} m',
      StreetPerk.spacing => '${fx.spacingM.round()} m apart',
      StreetPerk.relay => 'x${fx.relayMult.toStringAsFixed(2)} range',
      StreetPerk.muscle => 'x${fx.strikeMult.toStringAsFixed(2)} strike',
      StreetPerk.bench => '${fx.energyMax.round()} energy',
      StreetPerk.wind => '${fx.energyPerHour.toStringAsFixed(1)}/h',
      StreetPerk.smarts => 'x${fx.xpMult.toStringAsFixed(2)} XP',
      StreetPerk.safehouse => 'floor ${fx.decayFloor.round()}%',
    };
  }
}
