import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../domain/simulation.dart';
import 'widgets/common.dart';

/// "While you were dark" catch-up summary.
Future<void> showReport(BuildContext context, SimReport r) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Palette.slate,
    shape: chamfer(16, Palette.line),
    builder: (ctx) => ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.62),
      child: SafeArea(
        top: false,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          children: [
            const Eyebrow('While you were dark', color: Palette.mint),
            const SizedBox(height: 4),
            Text(fmtDuration(r.span), style: TextStyles.display.copyWith(fontSize: 28, fontFamily: Fonts.mono)),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: StatCell('Credits', '+${fmtNum(r.earned.credits)}', color: Palette.amber)),
                Expanded(child: StatCell('Materials', '+${fmtNum(r.earned.materials)}')),
                Expanded(child: StatCell('Intel', '+${fmtNum(r.earned.intel)}', color: Palette.ice)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: StatCell('Raids held', '${r.raidsRepelled}', color: Palette.mint)),
                Expanded(
                  child: StatCell('Raids lost', '${r.raidsLost}',
                      color: r.raidsLost > 0 ? Palette.hostile : Palette.textDim),
                ),
                Expanded(
                  child: StatCell('Turfs lost', '${r.turfsCaptured}',
                      color: r.turfsCaptured > 0 ? Palette.hostile : Palette.textDim),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: StatCell('Levels', '+${r.levelsGained}')),
                Expanded(child: StatCell('Cards dealt', '${r.eventsRolled}', color: Palette.amber)),
                Expanded(child: StatCell('Modules', '+${r.modulesFound}', color: Palette.mint)),
              ],
            ),
            if (r.headlines.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Eyebrow('Headlines'),
              const SizedBox(height: 6),
              for (final h in r.headlines.take(8))
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('— $h', style: TextStyles.body.copyWith(fontSize: 13)),
                ),
            ],
            const SizedBox(height: 14),
            CommandButton(label: 'Resume operations', onPressed: () => Navigator.pop(ctx)),
          ],
        ),
      ),
    ),
  );
}
