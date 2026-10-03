import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../domain/balance.dart';
import '../../game/game_controller.dart';
import '../widgets/common.dart';
import '../widgets/event_card.dart';

class OpsPanel extends StatelessWidget {
  const OpsPanel({super.key, required this.game, required this.onLocate});
  final GameController game;
  final LocateCallback onLocate;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: game,
      builder: (context, _) {
        final events = List.of(game.world.events)..sort((a, b) => a.expiresAt.compareTo(b.expiresAt));
        final log = game.recentLog.take(60).toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: [
            Row(
              children: [
                Expanded(child: Eyebrow('Event deck · ${events.length} active')),
                const Text('NEXT DEAL ', style: TextStyles.label),
                Countdown(
                  remainingMs: () {
                    final n = game.now;
                    return (n ~/ kDay + 1) * kDay - n;
                  },
                  style: TextStyles.dataSmall.copyWith(color: Palette.amber),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (events.isEmpty)
              Panel(
                child: Text(
                  game.index.owned == 0
                      ? 'The director deals 2-4 cards a day once you hold territory.'
                      : 'Quiet for now. New cards are dealt every 24h: lockdowns, convoys, dead drops, market swings and offensives.',
                  style: TextStyles.bodyDim,
                ),
              ),
            for (final e in events) ...[
              EventCard(game: game, event: e, onLocate: onLocate),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 10),
            const Eyebrow('Tactical feed'),
            const SizedBox(height: 6),
            if (log.isEmpty) const Text('No traffic yet.', style: TextStyles.bodyDim),
            for (final l in log)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 44, child: Text(clockTime(l.ts), style: TextStyles.dataSmall)),
                    Container(
                      width: 2,
                      height: 16,
                      margin: const EdgeInsets.only(right: 8, top: 1),
                      color: switch (l.kind) {
                        'gain' => Palette.mint,
                        'loss' => Palette.hostile,
                        'event' => Palette.amber,
                        _ => Palette.textFaint,
                      },
                    ),
                    Expanded(child: Text(l.message, style: TextStyles.body.copyWith(fontSize: 13))),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
