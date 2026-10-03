import 'dart:math' as math;

/// Offshore Cryptokey upgrades. Every line is infinite; cost creeps up by one
/// key every five ranks so keys always buy something.
enum VaultUpgrade {
  relayRange('relay_range', 'Relay Amplifier', '+1% global relay range'),
  offlineIncome('offline_income', 'Dormant Accounts', '+2% offline income'),
  cashFlow('cash_flow', 'Laundering Pipeline', '+3% credit yield'),
  hardened('hardened', 'Hardened Doctrine', '+3% defense everywhere'),
  logistics('logistics', 'Ghost Logistics', '+3% materials & intel yield'),
  headStart('head_start', 'Seed Capital', '+750 credits, +150 materials per restart'),
  fortune('fortune', 'Loaded Dice', '+2% loot luck'),
  quartermaster('quartermaster', 'Quartermaster', '-1.5% claim & build costs');

  const VaultUpgrade(this.key, this.title, this.effect);
  final String key;
  final String title;
  final String effect;

  int costForRank(int currentRank) => 1 + currentRank ~/ 5;
}

class VaultEffects {
  const VaultEffects(this.ranks);
  final Map<String, int> ranks;

  int rank(VaultUpgrade u) => ranks[u.key] ?? 0;

  double get relayMult => 1 + 0.01 * rank(VaultUpgrade.relayRange);
  double get offlineMult => 1 + 0.02 * rank(VaultUpgrade.offlineIncome);
  double get creditMult => 1 + 0.03 * rank(VaultUpgrade.cashFlow);
  double get defenseMult => 1 + 0.03 * rank(VaultUpgrade.hardened);
  double get logisticsMult => 1 + 0.03 * rank(VaultUpgrade.logistics);
  double get startCredits => 750.0 * rank(VaultUpgrade.headStart);
  double get startMaterials => 150.0 * rank(VaultUpgrade.headStart);
  double get luck => 0.02 * rank(VaultUpgrade.fortune);
  double get discount => math.pow(0.985, rank(VaultUpgrade.quartermaster)).toDouble();
}
