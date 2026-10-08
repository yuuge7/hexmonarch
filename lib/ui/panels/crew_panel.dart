import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../domain/jobs.dart';
import '../../domain/perks.dart';
import '../../game/game_controller.dart';
import '../widgets/common.dart';
import 'arsenal_panel.dart';
import 'trade_panel.dart';

enum CrewSection {
  jobs('Jobs'),
  perks('Perks'),
  modules('Modules'),
  trade('Trade');

  const CrewSection(this.label);
  final String label;
}

/// Jobs (energy), street perks (credits + intel), the module stash and the
/// exchange.
class CrewPanel extends StatefulWidget {
  const CrewPanel({super.key, required this.game});
  final GameController game;

  @override
  State<CrewPanel> createState() => _CrewPanelState();
}

class _CrewPanelState extends State<CrewPanel> {
  CrewSection _section = CrewSection.jobs;

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              for (final s in CrewSection.values) ...[
                if (s != CrewSection.values.first) const SizedBox(width: 6),
                Expanded(
                  child: SegChip(s.label, on: s == _section, onTap: () => setState(() => _section = s)),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: switch (_section) {
            CrewSection.jobs => _Jobs(game: game),
            CrewSection.perks => _Perks(game: game),
            CrewSection.modules => ArsenalPanel(game: game),
            CrewSection.trade => TradePanel(game: game),
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- jobs

class _Jobs extends StatelessWidget {
  const _Jobs({required this.game});
  final GameController game;

  @override
  Widget build(BuildContext context) {
    return Ticking(
      tick: game.tick,
      builder: (context) {
        final p = game.player;
        final fx = game.world.perks;
        final a = game.actions;
        final board = a.jobBoard().reversed.toList(); // best-paying first
        final atHome = game.atHome;
        final toFull = fx.energyMax - p.energy;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Eyebrow('Energy'),
                      const Spacer(),
                      Text('${p.energy.floor()} / ${fx.energyMax.round()}',
                          style: TextStyles.data.copyWith(color: Palette.ice)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Meter(value: p.energy / fx.energyMax, color: Palette.ice),
                  const SizedBox(height: 6),
                  Text(
                    toFull <= 0.01
                        ? 'Full. Spend it: energy over the cap is wasted.'
                        : '+${fx.energyPerHour.toStringAsFixed(0)} per hour · full in ${fmtDuration(Duration(seconds: (toFull / fx.energyPerHour * 3600).round()))}',
                    style: TextStyles.dataSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    atHome
                        ? 'Home turf bonus active: jobs pay x${kHomeTurfBonus.toStringAsFixed(1)} while you stand in your own turf.'
                        : 'Stand inside one of your turfs for x${kHomeTurfBonus.toStringAsFixed(1)} job pay.',
                    style: TextStyles.bodyDim.copyWith(fontSize: 12, color: atHome ? Palette.mint : Palette.textDim),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            for (final j in board)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _JobCard(game: game, job: j, atHome: atHome),
              ),
          ],
        );
      },
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({required this.game, required this.job, required this.atHome});
  final GameController game;
  final JobDef job;
  final bool atHome;

  @override
  Widget build(BuildContext context) {
    final a = game.actions;
    final locked = job.unlockLevel > game.player.level;
    final blocker = a.jobBlocker(job);
    final runs = a.jobRuns(job);
    final mastery = masteryRank(runs);
    final pay = a.jobPayout(job, atHome: atHome);
    final tm = jobTierMult(job.tier);
    final extras = [
      if (job.intel > 0) '+${fmtNum(job.intel * job.energy * tm)} int',
      if (job.materials > 0) '+${fmtNum(job.materials * job.energy * tm)} mat',
    ].join(' · ');
    return Opacity(
      opacity: locked ? 0.55 : 1,
      child: Panel(
        padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(job.title, style: TextStyles.title.copyWith(fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    locked ? 'Unlocks at level ${job.unlockLevel} · tier ${job.tier.index1}' : job.blurb,
                    style: TextStyles.bodyDim.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text.rich(
                    TextSpan(children: [
                      TextSpan(text: '~${fmtNum(pay)} cr', style: const TextStyle(color: Palette.amber)),
                      if (extras.isNotEmpty) TextSpan(text: ' · $extras'),
                    ]),
                    style: TextStyles.dataSmall.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (!locked) ...[
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Text('MASTERY $mastery', style: TextStyles.label.copyWith(fontSize: 9)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Meter(value: (runs % kJobMasteryRuns) / kJobMasteryRuns, height: 2, color: Palette.textDim),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 96,
              child: CommandButton(
                label: locked ? 'Locked' : 'Do it',
                caption: '${job.energy} energy',
                height: 46,
                onPressed: blocker == null ? () => game.runJob(job.id) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- perks

class _Perks extends StatelessWidget {
  const _Perks({required this.game});
  final GameController game;

  @override
  Widget build(BuildContext context) {
    return Ticking(
      tick: game.tick,
      builder: (context) {
        final fx = game.world.perks;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            Text(
              'Bought with credits and intel. Perks stay with you through a Network Liquidation.',
              style: TextStyles.bodyDim.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 8),
            for (final perk in StreetPerk.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _PerkCard(game: game, perk: perk, fx: fx),
              ),
          ],
        );
      },
    );
  }
}

class _PerkCard extends StatelessWidget {
  const _PerkCard({required this.game, required this.perk, required this.fx});
  final GameController game;
  final StreetPerk perk;
  final PerkEffects fx;

  @override
  Widget build(BuildContext context) {
    final rank = fx.rank(perk);
    final q = game.actions.perkQuote(perk);
    final maxed = perk.maxed(rank);
    return Panel(
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
      border: perk == StreetPerk.plantRange ? Palette.mint.withValues(alpha: 0.3) : null,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${perk.title} · R$rank', style: TextStyles.title.copyWith(fontSize: 14)),
                const SizedBox(height: 2),
                Text(perk.blurb, style: TextStyles.bodyDim.copyWith(fontSize: 12)),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(children: [
                    TextSpan(text: fx.valueLabel(perk), style: const TextStyle(color: Palette.text)),
                    if (!maxed)
                      TextSpan(text: '  →  ${fx.valueLabel(perk, rank + 1)}', style: const TextStyle(color: Palette.mint)),
                  ]),
                  style: TextStyles.dataSmall.copyWith(fontWeight: FontWeight.w600),
                ),
                if (!maxed) ...[
                  const SizedBox(height: 3),
                  CostLine(q.cost, have: game.player, color: Palette.amber),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 92,
            child: CommandButton(
              label: maxed ? 'Max' : 'Buy',
              height: 44,
              tone: Tone.amber,
              onPressed: q.allowed ? () => game.buyPerk(perk) : null,
            ),
          ),
        ],
      ),
    );
  }
}
