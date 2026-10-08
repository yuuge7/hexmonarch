import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../domain/balance.dart';
import '../../domain/models.dart';
import '../../game/game_controller.dart';
import '../widgets/common.dart';

Color _goodColor(Good g) => switch (g) {
      Good.credits => Palette.amber,
      Good.materials => Palette.text,
      Good.intel => Palette.ice,
    };

/// The exchange: swap credits, materials and intel for one another at a fee,
/// and buy extra module sockets.
class TradePanel extends StatefulWidget {
  const TradePanel({super.key, required this.game});
  final GameController game;

  @override
  State<TradePanel> createState() => _TradePanelState();
}

class _TradePanelState extends State<TradePanel> {
  static const _shares = [0.1, 0.25, 0.5, 1.0];

  Good _give = Good.credits;
  Good _get = Good.materials;
  double _share = 0.25;

  void _pick({Good? give, Good? get}) => setState(() {
        // Picking the same good on both sides swaps them.
        if (give != null) {
          if (give == _get) _get = _give;
          _give = give;
        }
        if (get != null) {
          if (get == _give) _give = _get;
          _get = get;
        }
      });

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    return Ticking(
      tick: game.tick,
      builder: (context) {
        final a = game.actions;
        final p = game.player;
        final now = game.now;
        final cap = a.tradeCap;
        final left = a.tradeLeft(now);
        final max = a.tradeMax(_give, now);
        var amount = max * _share;
        if (amount >= 10) amount = amount.floorToDouble();
        final rate = a.tradeRate(_give, _get);
        final got = amount * rate;
        final capped = left / goodValue(_give) < p.have(_give);

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            Text(
              'Swap what you have too much of for what you are short on. '
              'The fence keeps ${(kTradeFee * 100).round()}% of every trade.',
              style: TextStyles.bodyDim.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 10),
            Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow('You give'),
                  const SizedBox(height: 6),
                  _GoodRow(player: p, current: _give, onPick: (g) => _pick(give: g)),
                  const SizedBox(height: 10),
                  const Eyebrow('You get'),
                  const SizedBox(height: 6),
                  _GoodRow(player: p, current: _get, onPick: (g) => _pick(get: g)),
                  const SizedBox(height: 10),
                  const Eyebrow('How much'),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      for (final s in _shares) ...[
                        if (s != _shares.first) const SizedBox(width: 6),
                        Expanded(
                          child: SegChip(
                            s == 1 ? 'Max' : '${(s * 100).round()}%',
                            on: s == _share,
                            color: Palette.amber,
                            onTap: () => setState(() => _share = s),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text.rich(
                    TextSpan(children: [
                      TextSpan(text: '${fmtNum(amount)} ${_give.unit}', style: TextStyle(color: _goodColor(_give))),
                      const TextSpan(text: '  →  ', style: TextStyle(color: Palette.textDim)),
                      TextSpan(text: '${fmtNum(got)} ${_get.unit}', style: TextStyle(color: _goodColor(_get))),
                    ]),
                    style: TextStyles.data.copyWith(fontSize: 17),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    rate >= 1
                        ? '1 ${_give.unit} buys ${rate.toStringAsFixed(2)} ${_get.unit}'
                        : '1 ${_get.unit} costs ${(1 / rate).toStringAsFixed(2)} ${_give.unit}',
                    style: TextStyles.dataSmall,
                  ),
                  const SizedBox(height: 10),
                  CommandButton(
                    label: amount > 0 ? 'Trade' : (left <= 0 ? "Today's limit reached" : 'No ${_give.label.toLowerCase()} to give'),
                    height: 46,
                    tone: Tone.amber,
                    icon: amount > 0 ? Icons.swap_horiz : null,
                    onPressed: amount > 0 ? () => game.run((a, t) => a.trade(_give, _get, amount, t)) : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Panel(
              border: capped ? Palette.amber.withValues(alpha: 0.35) : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(child: Eyebrow("Today's limit")),
                      const Text('RESETS IN ', style: TextStyles.label),
                      Countdown(
                        remainingMs: () {
                          final n = game.now;
                          return (n ~/ kDay + 1) * kDay - n;
                        },
                        style: TextStyles.dataSmall.copyWith(color: Palette.amber),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Meter(value: cap <= 0 ? 0 : left / cap, color: Palette.amber, height: 3),
                  const SizedBox(height: 6),
                  Text("${fmtNum(left)} of ${fmtNum(cap)} credits' worth left", style: TextStyles.dataSmall),
                  const SizedBox(height: 4),
                  Text(
                    'To raise it: level up (+250 a level) and grow your hourly output '
                    '(the limit adds 12 hours of what your turfs produce).',
                    style: TextStyles.bodyDim.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _SocketExpander(game: game),
          ],
        );
      },
    );
  }
}

class _GoodRow extends StatelessWidget {
  const _GoodRow({required this.player, required this.current, required this.onPick});
  final PlayerData player;
  final Good current;
  final ValueChanged<Good> onPick;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          for (final g in Good.values) ...[
            if (g != Good.values.first) const SizedBox(width: 6),
            Expanded(
              child: SegChip(
                '${g.unit} ${fmtNum(player.have(g))}',
                on: g == current,
                color: _goodColor(g),
                onTap: () => onPick(g),
              ),
            ),
          ],
        ],
      );
}

/// One more module socket on the turf the console is on.
class _SocketExpander extends StatelessWidget {
  const _SocketExpander({required this.game});
  final GameController game;

  @override
  Widget build(BuildContext context) {
    final w = game.world;
    final focus = game.focusTurf;
    final target = focus != null && focus.isPlayer && w.turfs.containsKey(focus.id) ? focus : null;
    final q = target == null ? null : game.actions.socketQuote(target.id);
    return Panel(
      border: Palette.mint.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Socket expander', style: TextStyles.title.copyWith(fontSize: 14)),
          const SizedBox(height: 2),
          Text(
            'Adds a module socket to one turf, for good. No ceiling: each extra socket on the same turf costs double the last.',
            style: TextStyles.bodyDim.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 8),
          if (target == null || q == null)
            const Text('Tap one of your turfs on the map to choose where the socket goes.', style: TextStyles.body)
          else ...[
            Text(
              '${target.name} · ${w.socketsOf(target)} socket${w.socketsOf(target) == 1 ? '' : 's'} now',
              style: TextStyles.dataSmall.copyWith(color: Palette.text),
            ),
            const SizedBox(height: 8),
            CommandButton(
              label: 'Add a socket',
              height: 46,
              icon: Icons.add_box_outlined,
              cost: q.cost,
              have: game.player,
              onPressed: q.allowed ? () => game.run((a, t) => a.expandSocket(target.id, t)) : null,
            ),
          ],
        ],
      ),
    );
  }
}
