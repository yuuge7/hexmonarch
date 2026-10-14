import 'dart:math' as math;

import 'balance.dart';
import 'models.dart';
import 'world.dart';

/// Which of your turfs a bulk command works on (Empire tab).
enum TurfScope {
  all('All'),
  plain('Turfs'),
  hubs('Hubs'),
  stations('Stations'),
  unsupplied('No hub'),
  damaged('Damaged');

  const TurfScope(this.label);
  final String label;

  bool test(Turf t, WorldIndex ix) => switch (this) {
        all => true,
        plain => !t.isHub,
        hubs => t.isHub,
        stations => t.isStation,
        unsupplied => !ix.supplier.containsKey(t.id),
        damaged => t.integrity < 99.5,
      };
}

/// What to upgrade: garrisons on any turf, or hub levels on hubs.
enum UpgradeKind { garrison, hub }

/// A bulk upgrade worked out before paying: how many levels each turf gets,
/// what it all costs, and what it adds.
class UpgradePlan {
  const UpgradePlan({
    required this.steps,
    required this.cost,
    required this.wanted,
    required this.gain,
  });

  /// Turf id to levels added.
  final Map<String, int> steps;
  final Cost cost;

  /// Levels asked for. A plan made within your funds can hold fewer.
  final int wanted;

  /// Extra output per hour once done (garrisons on every turf, hub levels
  /// on the hub's own output).
  final Resources gain;

  int get levels => steps.values.fold(0, (a, b) => a + b);
  int get turfs => steps.length;
  bool get complete => levels == wanted;
  bool get isEmpty => levels == 0;
}

/// Levels raised one at a time, cheapest first: every turf at the lowest
/// level gets its next level before anything one level up. With a [budget],
/// stops at the first level it cannot pay for, so the money goes as far as
/// it can across all of them.
UpgradePlan planUpgrades(
  World w,
  Iterable<Turf> turfs,
  UpgradeKind kind, {
  int add = 0,
  int? upTo,
  Cost? budget,
}) {
  final discount = w.vault.discount;
  final ix = w.index;
  int levelOf(Turf t) => kind == UpgradeKind.garrison ? t.garrison : t.hubLevel;
  Cost costAt(int level) => kind == UpgradeKind.garrison
      ? garrisonCost(level, discount: discount)
      : hubUpgradeCost(level, discount: discount);

  // Turfs by current level, each with the level it should end at.
  final byLevel = <int, List<(Turf, int)>>{};
  var wanted = 0;
  for (final t in turfs) {
    if (!t.isPlayer || (kind == UpgradeKind.hub && !t.isHub)) continue;
    final from = levelOf(t);
    final int to = upTo != null ? math.max<int>(from, upTo) : from + math.max<int>(0, add);
    if (to <= from) continue;
    wanted += to - from;
    (byLevel[from] ??= []).add((t, to));
  }

  final steps = <String, int>{};
  var credits = 0.0, materials = 0.0, intel = 0.0;
  var out = false;
  final levels = byLevel.keys.toList()..sort();
  var i = 0;
  // Walk the levels upward; turfs that reach a level join that bucket.
  while (!out && i < levels.length) {
    final level = levels[i];
    final bucket = byLevel.remove(level) ?? const [];
    final c = costAt(level);
    for (final (t, to) in bucket) {
      if (budget != null &&
          (credits + c.credits > budget.credits + 1e-9 ||
              materials + c.materials > budget.materials + 1e-9 ||
              intel + c.intel > budget.intel + 1e-9)) {
        out = true;
        break;
      }
      credits += c.credits;
      materials += c.materials;
      intel += c.intel;
      steps[t.id] = (steps[t.id] ?? 0) + 1;
      if (level + 1 < to) {
        final next = byLevel[level + 1];
        if (next == null) {
          byLevel[level + 1] = [(t, to)];
          // Keep the level list sorted: level + 1 sits right after level.
          if (i + 1 >= levels.length || levels[i + 1] != level + 1) levels.insert(i + 1, level + 1);
        } else {
          next.add((t, to));
        }
      }
    }
    i++;
  }

  // What it adds per hour: the turf's yield with its new multiplier.
  var gain = const Resources();
  for (final e in steps.entries) {
    final t = w.turfs[e.key]!;
    final y = ix.turfYield[t.id];
    if (y == null) continue;
    final next = kind == UpgradeKind.garrison
        ? y.copyWith(garrison: garrisonYieldMult(t.garrison + e.value))
        : y.copyWith(hub: hubYieldMult(t.hubLevel + e.value));
    gain = gain + next.total + (y.total * -1);
  }

  return UpgradePlan(
    steps: steps,
    cost: Cost(credits: credits, materials: materials, intel: intel),
    wanted: wanted,
    gain: gain,
  );
}
