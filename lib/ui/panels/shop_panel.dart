import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../domain/shop.dart';
import '../../game/game_controller.dart';
import '../widgets/common.dart';

/// Crew > Shop: boosts for breaching and holding, and supplies, bought
/// outright with what the empire earns.
class ShopPanel extends StatelessWidget {
  const ShopPanel({super.key, required this.game});
  final GameController game;

  static IconData icon(ShopItem i) => switch (i) {
        ShopItem.hiredGuns => Icons.sports_mma_outlined,
        ShopItem.insideMan => Icons.visibility_outlined,
        ShopItem.barricades => Icons.shield_outlined,
        ShopItem.ceasefire => Icons.front_hand_outlined,
        ShopItem.repairCrew => Icons.build_outlined,
        ShopItem.energyDrink => Icons.bolt_outlined,
        ShopItem.supplyCrate => Icons.inventory_2_outlined,
        ShopItem.blueprint => Icons.description_outlined,
      };

  static String _section(ShopKind k) => switch (k) {
        ShopKind.offense => 'Offense',
        ShopKind.defense => 'Defense',
        ShopKind.supplies => 'Supplies',
      };

  static String _purpose(ShopKind k) => switch (k) {
        ShopKind.offense => 'Win more breaches.',
        ShopKind.defense => 'Hold what you have, wherever you are.',
        ShopKind.supplies => 'Skip the wait.',
      };

  @override
  Widget build(BuildContext context) {
    return Ticking(
      tick: game.tick,
      builder: (context) {
        final boosts = game.world.boosts;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            Text(
              'Prices follow what your turfs earn per hour. Each repeat buy of the same item on the same day '
              'costs 50% more (Energy Drink doubles); prices reset once a day, with the exchange limit.',
              style: TextStyles.bodyDim.copyWith(fontSize: 12),
            ),
            for (final kind in ShopKind.values) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Eyebrow(_section(kind), color: Palette.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_purpose(kind),
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyles.bodyDim.copyWith(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              for (final item in ShopItem.values)
                if (item.kind == kind)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ItemCard(game: game, item: item, until: boosts[item.key]),
                  ),
            ],
          ],
        );
      },
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.game, required this.item, required this.until});
  final GameController game;
  final ShopItem item;

  /// When the boost runs out, while it is running.
  final int? until;

  bool get on => until != null;

  @override
  Widget build(BuildContext context) {
    final q = game.actions.shopQuote(item, game.now);
    final left = (until ?? 0) - game.now;
    return Panel(
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
      border: on ? Palette.mint.withValues(alpha: 0.35) : null,
      child: Row(
        children: [
          Icon(ShopPanel.icon(item), size: 20, color: on ? Palette.mint : Palette.amber),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: TextStyles.title.copyWith(fontSize: 14)),
                const SizedBox(height: 2),
                Text(item.blurb, style: TextStyles.bodyDim.copyWith(fontSize: 12)),
                const SizedBox(height: 4),
                if (q.blocker != null)
                  Text(q.blocker!, style: TextStyles.dataSmall)
                else
                  CostLine(q.cost, have: game.player, color: Palette.amber),
                if (q.note != null) ...[
                  const SizedBox(height: 2),
                  Text(q.note!, style: TextStyles.dataSmall),
                ],
                if (on) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(child: Meter(value: left / item.boostMs, height: 3)),
                      const SizedBox(width: 8),
                      Text('${fmtDuration(Duration(milliseconds: left))} left',
                          style: TextStyles.dataSmall.copyWith(color: Palette.mint)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 92,
            child: CommandButton(
              label: on ? 'Extend' : 'Buy',
              height: 44,
              tone: Tone.amber,
              onPressed: q.allowed ? () => game.run((a, now) => a.buy(item, now)) : null,
            ),
          ),
        ],
      ),
    );
  }
}
