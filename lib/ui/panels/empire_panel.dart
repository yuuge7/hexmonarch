import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../domain/empire.dart';
import '../../domain/models.dart';
import '../../game/game_controller.dart';
import '../widgets/common.dart';

/// Every turf at once: raise garrisons or hub levels across the empire,
/// repair everything, fill every socket. For when you hold a hundred turfs
/// and do not want to open each one.
class EmpirePanel extends StatefulWidget {
  const EmpirePanel({super.key, required this.game, required this.onTurfList});
  final GameController game;
  final VoidCallback onTurfList;

  @override
  State<EmpirePanel> createState() => _EmpirePanelState();
}

class _EmpirePanelState extends State<EmpirePanel> {
  UpgradeKind _kind = UpgradeKind.garrison;
  TurfScope _scope = TurfScope.all;
  bool _upTo = false;
  int _add = 10;
  int _target = 10;

  GameController get game => widget.game;

  @override
  Widget build(BuildContext context) {
    return Ticking(
      tick: game.tick,
      builder: (context) {
        final ix = game.index;
        if (ix.owned == 0) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Panel(
              child: Text(
                'Nothing to manage yet. Plant your first turf from the Turf tab; once you hold a few, '
                'this is where you upgrade, repair and equip all of them at once.',
                style: TextStyles.bodyDim,
              ),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          children: [
            _Summary(game: game),
            const SizedBox(height: 14),
            _upgrader(),
            const SizedBox(height: 14),
            _Upkeep(game: game),
            const SizedBox(height: 10),
            CommandButton(
              label: 'Turf list · ${ix.owned}',
              height: 42,
              filled: false,
              tone: Tone.neutral,
              icon: Icons.format_list_bulleted,
              onPressed: widget.onTurfList,
            ),
          ],
        );
      },
    );
  }

  Widget _upgrader() {
    final a = game.actions;
    final garrison = _kind == UpgradeKind.garrison;
    final scope = garrison ? _scope : TurfScope.hubs;
    final turfs = a.scoped(scope);
    final levels = [for (final t in turfs) garrison ? t.garrison : t.hubLevel];
    final lowest = levels.isEmpty ? 1 : levels.reduce(math.min);
    final full = a.upgradePlan(turfs, _kind, add: _upTo ? 0 : _add, upTo: _upTo ? _target : null);
    final funds = a.upgradePlan(turfs, _kind, add: _upTo ? 0 : _add, upTo: _upTo ? _target : null, withinFunds: true);
    final affordable = full.cost.affordable(game.player);
    final color = garrison ? Palette.mint : Palette.amber;
    final tone = garrison ? Tone.mint : Tone.amber;

    return Panel(
      border: color.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Eyebrow('Upgrade many at once', color: color),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SegChip('Garrisons', on: garrison, onTap: () => setState(() => _kind = UpgradeKind.garrison)),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: SegChip('Hub levels',
                    on: !garrison, color: Palette.amber, onTap: () => setState(() => _kind = UpgradeKind.hub)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (garrison) ...[
            const Eyebrow('Which turfs'),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final s in TurfScope.values)
                  _ScopeChip(
                    label: s.label,
                    count: a.scoped(s).length,
                    on: s == _scope,
                    onTap: () => setState(() => _scope = s),
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(child: SegChip('Add levels', on: !_upTo, height: 32, onTap: () => setState(() => _upTo = false))),
              const SizedBox(width: 6),
              Expanded(
                child: SegChip('Up to level', on: _upTo, height: 32, onTap: () {
                  setState(() {
                    _upTo = true;
                    _target = math.max(_target, lowest + 1);
                  });
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _Stepper(
            value: _upTo ? _target : _add,
            prefix: _upTo ? 'L' : '+',
            min: 1,
            max: _upTo ? 999 : 100,
            quick: _upTo ? [lowest + 5, lowest + 10, lowest + 25] : const [1, 5, 10, 25],
            color: color,
            onChanged: (v) => setState(() => _upTo ? _target = v : _add = v),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Palette.line),
          const SizedBox(height: 10),
          if (full.wanted == 0)
            Text(
              turfs.isEmpty
                  ? (garrison ? 'No turf fits this filter.' : 'No hubs yet. Make one from a turf\'s Manage section.')
                  : 'Every one of them is already at L$_target or above.',
              style: TextStyles.bodyDim,
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    '+${fmtNum(full.wanted)} level${full.wanted == 1 ? '' : 's'} on ${full.turfs} '
                    '${garrison ? 'turf' : 'hub'}${full.turfs == 1 ? '' : 's'}',
                    style: TextStyles.body.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            CostLine(full.cost, have: game.player, color: Palette.amber, size: 13),
            const SizedBox(height: 4),
            YieldLine(full.gain, suffix: garrison ? ' per hour more' : ' per hour more on the hubs'),
            if (!affordable) ...[
              const SizedBox(height: 6),
              Text(
                funds.isEmpty
                    ? 'Not enough for even one level yet.'
                    : 'Your funds cover ${fmtNum(funds.levels)} of the ${fmtNum(full.wanted)} levels: '
                        'the lowest ones first, ${fmtNum(funds.cost.credits)} CR.',
                style: TextStyles.bodyDim.copyWith(fontSize: 12, color: Palette.amber),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CommandButton(
                    label: 'Max affordable',
                    height: 48,
                    filled: false,
                    tone: tone,
                    caption: funds.isEmpty ? 'nothing affordable' : '+${fmtNum(funds.levels)} levels',
                    onPressed: !affordable && !funds.isEmpty ? () => _apply(turfs, withinFunds: true) : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CommandButton(
                    label: 'Hold: upgrade all',
                    height: 48,
                    tone: tone,
                    holdToConfirm: true,
                    caption: '+${fmtNum(full.wanted)} levels',
                    onPressed: affordable ? () => _apply(turfs) : null,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _apply(List<Turf> turfs, {bool withinFunds = false}) {
    final ids = [for (final t in turfs) t.id];
    game.run((a, now) => a.bulkUpgrade(ids, _kind, now,
        add: _upTo ? 0 : _add, upTo: _upTo ? _target : null, withinFunds: withinFunds));
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.game});
  final GameController game;

  @override
  Widget build(BuildContext context) {
    final w = game.world;
    final ix = w.index;
    final turfs = w.playerTurfs.toList();
    final gs = [for (final t in turfs) t.garrison];
    final avg = gs.isEmpty ? 0.0 : gs.reduce((a, b) => a + b) / gs.length;
    final damaged = turfs.where((t) => t.integrity < 99.5).length;
    final besieged = turfs.where((t) => w.siegeSince(t.id) != null).length;
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('Your empire'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: StatCell('Turfs', fmtNum(ix.owned), sub: '${ix.stations} at stations')),
              Expanded(child: StatCell('Hubs', '${ix.hubs.length}', color: Palette.amber, sub: 'best L${ix.maxHubLevel}')),
              Expanded(
                child: StatCell('Garrison', 'L${avg.toStringAsFixed(1)}',
                    color: Palette.mint, sub: gs.isEmpty ? null : 'L${gs.reduce(math.min)} to L${gs.reduce(math.max)}'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: StatCell('Supplied', '${(ix.suppliedRatio * 100).round()}%',
                    color: ix.suppliedRatio > 0.8 ? Palette.mint : Palette.amber,
                    sub: '${ix.owned - ix.supplied} without a hub'),
              ),
              Expanded(
                child: StatCell('Damaged', '$damaged',
                    color: damaged == 0 ? Palette.text : Palette.amber,
                    sub: besieged == 0 ? 'none under siege' : '$besieged under siege'),
              ),
              Expanded(
                child: StatCell('Sockets', '${game.actions.emptySockets} empty',
                    sub: '${w.stash.length} in stash'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          YieldLine(ix.hourly, suffix: ' per hour'),
        ],
      ),
    );
  }
}

/// Repair everything and fill every socket, in one tap each.
class _Upkeep extends StatelessWidget {
  const _Upkeep({required this.game});
  final GameController game;

  @override
  Widget build(BuildContext context) {
    final a = game.actions;
    final all = game.world.playerTurfs.toList();
    final rq = a.repairAllQuote(all);
    final empty = a.emptySockets;
    final stash = game.world.stash.length;
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Eyebrow('Upkeep'),
          const SizedBox(height: 8),
          _Row(
            title: 'Repair every damaged turf',
            detail: rq.blocker == null ? '${rq.note} · lifts their sieges' : 'Every turf is at 100%',
            cost: rq.blocker == null ? rq.cost : null,
            game: game,
            action: 'Repair',
            onPressed: rq.allowed
                ? () => game.run((a, now) => a.repairAll([for (final t in all) t.id], now))
                : null,
          ),
          const Divider(height: 18, color: Palette.line),
          _Row(
            title: 'Fill every empty socket',
            detail: empty == 0
                ? 'Every socket is full'
                : (stash == 0
                    ? '$empty empty, stash is empty'
                    : '$empty empty · $stash in stash · best modules to hubs first'),
            game: game,
            action: 'Fill',
            onPressed: empty > 0 && stash > 0 ? () => game.run((a, now) => a.fillSockets(now)) : null,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.title,
    required this.detail,
    required this.game,
    required this.action,
    required this.onPressed,
    this.cost,
  });
  final String title;
  final String detail;
  final GameController game;
  final String action;
  final VoidCallback? onPressed;
  final Cost? cost;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(detail, style: TextStyles.bodyDim.copyWith(fontSize: 12)),
                if (cost != null) ...[
                  const SizedBox(height: 2),
                  CostLine(cost!, have: game.player, color: Palette.amber),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 88,
            child: CommandButton(label: action, height: 40, filled: false, onPressed: onPressed),
          ),
        ],
      );
}

class _ScopeChip extends StatelessWidget {
  const _ScopeChip({required this.label, required this.count, required this.on, required this.onTap});
  final String label;
  final int count;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: on,
        label: '$label, $count',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: ShapeDecoration(
              color: on ? Palette.mint : Colors.transparent,
              shape: chamfer(6, on ? null : Palette.textDim.withValues(alpha: 0.6)),
            ),
            child: Text.rich(
              TextSpan(children: [
                TextSpan(text: label.toUpperCase()),
                TextSpan(text: '  $count', style: TextStyle(color: on ? Palette.carbon : Palette.mint)),
              ]),
              style: TextStyles.label.copyWith(
                fontSize: 10.5,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w700,
                color: on ? Palette.carbon : Palette.textDim,
              ),
            ),
          ),
        ),
      );
}

/// Big number with − and + either side, and a row of quick picks.
class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.value,
    required this.prefix,
    required this.min,
    required this.max,
    required this.quick,
    required this.color,
    required this.onChanged,
  });
  final int value;
  final String prefix;
  final int min;
  final int max;
  final List<int> quick;
  final Color color;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget step(IconData icon, int delta, String tip) {
      final next = (value + delta).clamp(min, max);
      final enabled = next != value;
      return Semantics(
        button: true,
        enabled: enabled,
        label: tip,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? () => onChanged(next) : null,
          child: Container(
            width: 52,
            height: 44,
            decoration: ShapeDecoration(shape: chamfer(8, enabled ? Palette.textDim : Palette.line)),
            child: Icon(icon, size: 22, color: enabled ? Palette.text : Palette.textFaint),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            step(Icons.remove, -1, 'One less'),
            Expanded(
              child: Text('$prefix$value',
                  textAlign: TextAlign.center, style: TextStyles.display.copyWith(fontSize: 30, color: color)),
            ),
            step(Icons.add, 1, 'One more'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final q in quick) ...[
              if (q != quick.first) const SizedBox(width: 6),
              Expanded(
                child: SegChip('$prefix$q', on: q == value, height: 30, color: color, onTap: () => onChanged(q.clamp(min, max))),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
