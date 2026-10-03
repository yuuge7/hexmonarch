import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../domain/balance.dart';
import '../../domain/vault.dart';
import '../../game/game_controller.dart';
import '../widgets/common.dart';

/// Network Liquidation (prestige) + Offshore Cryptokey upgrades.
class VaultPanel extends StatelessWidget {
  const VaultPanel({super.key, required this.game});
  final GameController game;

  @override
  Widget build(BuildContext context) {
    return Ticking(
      tick: game.tick,
      builder: (context) {
        final p = game.player;
        final s = game.actions.prestigeStatus();
        final v = game.world.vault;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Eyebrow('Offshore Cryptokeys'),
                    Text('${p.keys}',
                        style: TextStyles.display.copyWith(fontSize: 34, color: Palette.amber, fontFamily: Fonts.mono)),
                  ],
                ),
                const Spacer(),
                Text('${p.liquidations} liquidation${p.liquidations == 1 ? '' : 's'}', style: TextStyles.dataSmall),
              ],
            ),
            const SizedBox(height: 12),
            Panel(
              border: (s.ready ? Palette.hostile : Palette.line).withValues(alpha: 0.6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Network Liquidation', style: TextStyles.title),
                  const SizedBox(height: 4),
                  const Text(
                    'Sell the whole empire offshore. Every turf, hub, module and credit is wiped; '
                    'Cryptokeys and vault upgrades stay. The next city rolls fresh genetics.',
                    style: TextStyles.bodyDim,
                  ),
                  const SizedBox(height: 12),
                  _Req('Turfs held', s.owned, kPrestigeHexes, s.hexesMet),
                  _Req('Regions linked by relays (~45 km apart)', s.districts, kPrestigeDistricts, s.districtsMet),
                  _Req('Capital hub level', s.capital, kPrestigeCapitalLevel, s.capitalMet),
                  const SizedBox(height: 8),
                  Text(
                    s.ready ? 'Payout: ${s.keys} Cryptokeys' : 'Projected payout at threshold: ${s.keys} Cryptokeys',
                    style: TextStyles.dataSmall.copyWith(color: Palette.amber),
                  ),
                  const SizedBox(height: 10),
                  CommandButton(
                    label: s.ready ? 'Hold to liquidate' : 'Empire too small',
                    tone: Tone.hostile,
                    holdToConfirm: true,
                    icon: Icons.currency_exchange,
                    onPressed: s.ready ? game.liquidate : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Eyebrow('Vault upgrades · infinite ranks'),
            const SizedBox(height: 8),
            for (final u in VaultUpgrade.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Panel(
                  padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${u.title} · R${v.rank(u)}', style: TextStyles.title.copyWith(fontSize: 14)),
                            const SizedBox(height: 2),
                            Text(u.effect, style: TextStyles.dataSmall),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 112,
                        child: CommandButton(
                          label: '${u.costForRank(v.rank(u))} key${u.costForRank(v.rank(u)) == 1 ? '' : 's'}',
                          height: 40,
                          tone: Tone.amber,
                          filled: p.keys >= u.costForRank(v.rank(u)),
                          onPressed: p.keys >= u.costForRank(v.rank(u)) ? () => game.buyVault(u) : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 6),
            Text('Lifetime credits laundered: ${fmtNum(p.lifetimeCredits)}', style: TextStyles.label),
          ],
        );
      },
    );
  }
}

class _Req extends StatelessWidget {
  const _Req(this.label, this.value, this.target, this.met);
  final String label;
  final int value;
  final int target;
  final bool met;

  @override
  Widget build(BuildContext context) {
    final c = met ? Palette.mint : Palette.amber;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: TextStyles.body.copyWith(fontSize: 13))),
              Text('${fmtNum(value)} / ${fmtNum(target)}', style: TextStyles.dataSmall.copyWith(color: c)),
            ],
          ),
          const SizedBox(height: 4),
          Meter(value: value / target, color: c, height: 3),
        ],
      ),
    );
  }
}
