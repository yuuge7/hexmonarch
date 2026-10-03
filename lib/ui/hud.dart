import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../domain/balance.dart';
import '../domain/tiers.dart';
import '../game/game_controller.dart';
import 'widgets/common.dart';

/// Read-only status strip over the map. Nothing here is tappable: every
/// control lives in the bottom console.
class Hud extends StatelessWidget {
  const Hud({super.key, required this.game});
  final GameController game;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Ticking(
        tick: game.tick,
        builder: (context) {
          final p = game.player;
          final rate = game.index.hourly;
          final need = xpToNext(p.level);
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: Palette.carbon.withValues(alpha: 0.86),
                shape: chamfer(10, Palette.line),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 9),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        _Readout('CR', fmtNum(p.credits), '+${fmtNum(rate.credits)}/h', Palette.amber),
                        _Readout('MAT', fmtNum(p.materials), '+${fmtNum(rate.materials)}/h', Palette.text),
                        _Readout('INT', fmtNum(p.intel), '+${fmtNum(rate.intel)}/h', Palette.ice),
                        _Readout('NRG', '${p.energy.floor()}', '/${game.world.perks.energyMax.round()}'
                            '${p.keys > 0 ? ' · ${p.keys} key${p.keys == 1 ? '' : 's'}' : ''}', Palette.mint),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Text(tierBadge(p.level),
                            style: TextStyles.label.copyWith(color: Palette.mint, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        Text('LV ${p.level}', style: TextStyles.label.copyWith(color: Palette.text)),
                        const SizedBox(width: 10),
                        Expanded(child: Meter(value: p.xp / need, height: 3)),
                        const SizedBox(width: 10),
                        Text('${fmtNum(p.xp)}/${fmtNum(need)}', style: TextStyles.label),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Readout extends StatelessWidget {
  const _Readout(this.label, this.value, this.rate, this.color);
  final String label;
  final String value;
  final String rate;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyles.label.copyWith(fontSize: 9)),
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: TextStyles.data.copyWith(color: color, fontSize: 16)),
            Text(rate,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: TextStyles.dataSmall.copyWith(fontSize: 9.5)),
          ],
        ),
      );
}
