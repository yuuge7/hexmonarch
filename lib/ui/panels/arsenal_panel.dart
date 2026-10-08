import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../domain/loot.dart';
import '../../game/game_controller.dart';
import '../widgets/common.dart';
import 'turf_panel.dart' show ModuleTile;

class ArsenalPanel extends StatelessWidget {
  const ArsenalPanel({super.key, required this.game});
  final GameController game;

  @override
  Widget build(BuildContext context) {
    return Ticking(
      tick: game.tick,
      builder: (context) {
        final w = game.world;
        final a = game.actions;
        final focusTurf = game.focusTurf;
        final target = focusTurf != null && w.turfs.containsKey(focusTurf.id) ? focusTurf : null;
        final canInstall = target != null && target.isPlayer && a.freeSocket(target) >= 0;
        final installed = target == null ? const [] : w.modulesOn(target.id);
        final stash = List.of(w.stash)..sort((x, y) => y.score.compareTo(x.score));
        final cq = a.craftQuote();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: [
            Panel(
              border: Palette.amber.withValues(alpha: 0.3),
              child: Row(
                children: [
                  Expanded(
                    child: StatCell('Blueprints', '${game.player.blueprints}',
                        color: Palette.amber, sub: 'crafts Rare or better'),
                  ),
                  SizedBox(
                    width: 170,
                    child: CommandButton(
                      label: 'Decrypt',
                      height: 46,
                      tone: Tone.amber,
                      cost: cq.blocker == null ? cq.cost : null,
                      caption: cq.blocker == null ? null : 'intercept convoys',
                      have: game.player,
                      onPressed: cq.allowed ? () => game.run((a, t) => a.craft(t)) : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (target != null && target.isPlayer) ...[
              Eyebrow('Socketed in ${target.name} · ${installed.length}/${w.socketsOf(target)}'),
              const SizedBox(height: 8),
              if (installed.isEmpty)
                const Text('Nothing socketed here yet.', style: TextStyles.bodyDim),
              for (final m in installed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ModuleTile(
                    module: m,
                    trailing: CommandButton(
                      label: 'Pull',
                      height: 36,
                      filled: false,
                      onPressed: () => game.run((a, t) => a.uninstall(m.id, t)),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
            ] else ...[
              const Text('Tap one of your turfs on the map to socket modules into it.',
                  style: TextStyles.bodyDim),
              const SizedBox(height: 12),
            ],
            Eyebrow('Stash · ${stash.length}'),
            const SizedBox(height: 8),
            if (stash.isEmpty)
              const Panel(
                child: Text(
                  'Empty. Modules drop from breaching rival turfs, repelled raids, convoys, '
                  'dead drops and decrypted blueprints. There is always a stronger roll out there.',
                  style: TextStyles.bodyDim,
                ),
              ),
            for (final m in stash)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ModuleTile(
                  module: m,
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CommandButton(
                        label: 'Install',
                        height: 34,
                        onPressed: canInstall ? () => game.run((a, t) => a.install(m.id, target.id, t)) : null,
                      ),
                      const SizedBox(height: 6),
                      CommandButton(
                        label: 'Scrap ${fmtNum(LootTable.scrapValue(m))}',
                        height: 30,
                        filled: false,
                        tone: Tone.neutral,
                        onPressed: () => game.run((a, t) => a.scrap(m.id, t)),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
