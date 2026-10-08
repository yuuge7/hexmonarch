import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;

import '../core/format.dart';
import '../core/theme.dart';
import '../domain/models.dart';
import '../domain/tiers.dart';
import '../game/game_controller.dart';
import '../geo/hex_grid.dart';
import 'widgets/common.dart';

enum _Sort {
  nearest('Nearest'),
  name('Name'),
  income('Credits'),
  materials('Materials'),
  intel('Intel'),
  weakest('Weakest');

  const _Sort(this.label);
  final String label;
}

enum _Filter {
  all('All'),
  hubs('Hubs'),
  stations('Stations'),
  noHub('No hub'),
  lost('Lost');

  const _Filter(this.label);
  final String label;
}

/// Roster of every turf you hold (and the ones rivals took from you). Tap a
/// row to jump to that turf on the map.
class TurfListScreen extends StatefulWidget {
  const TurfListScreen({super.key, required this.game, required this.onPick});
  final GameController game;
  final ValueChanged<Turf> onPick;

  static Future<void> open(BuildContext context, GameController game, {required ValueChanged<Turf> onPick}) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => TurfListScreen(game: game, onPick: onPick),
        ),
      );

  @override
  State<TurfListScreen> createState() => _TurfListScreenState();
}

class _TurfListScreenState extends State<TurfListScreen> {
  _Sort _sort = _Sort.nearest;
  _Filter _filter = _Filter.all;

  GameController get game => widget.game;

  double? _distM(Turf t) => game.lat == null ? null : metersBetween(game.lat!, game.lng!, t.lat, t.lng);

  /// Turfs a rival crew took from you: they keep the date you first held them.
  bool _lost(Turf t) => t.isHostile && t.capturedAt != null;

  List<Turf> _rows() {
    final ix = game.index;
    final rows = [
      for (final t in game.world.turfs.values)
        if (switch (_filter) {
          _Filter.all => t.isPlayer,
          _Filter.hubs => t.isPlayer && t.isHub,
          _Filter.stations => t.isPlayer && t.isStation,
          _Filter.noHub => t.isPlayer && !ix.supplier.containsKey(t.id),
          _Filter.lost => _lost(t),
        })
          t,
    ];
    int byName(Turf a, Turf b) => a.name.toLowerCase().compareTo(b.name.toLowerCase());
    switch (_sort) {
      case _Sort.nearest:
        if (game.lat == null) {
          rows.sort(byName);
        } else {
          final d = {for (final t in rows) t.id: _distM(t)!};
          rows.sort((a, b) => d[a.id]!.compareTo(d[b.id]!));
        }
      case _Sort.name:
        rows.sort(byName);
      case _Sort.income:
        double y(Turf t) => ix.turfHourly[t.id]?.credits ?? 0;
        rows.sort((a, b) => y(b).compareTo(y(a)));
      case _Sort.materials:
        double y(Turf t) => ix.turfHourly[t.id]?.materials ?? 0;
        rows.sort((a, b) => y(b).compareTo(y(a)));
      case _Sort.intel:
        double y(Turf t) => ix.turfHourly[t.id]?.intel ?? 0;
        rows.sort((a, b) => y(b).compareTo(y(a)));
      case _Sort.weakest:
        rows.sort((a, b) => a.integrity.compareTo(b.integrity));
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(value: kDarkBars, child: _page(context));
  }

  Widget _page(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.carbon,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: game,
          builder: (context, _) {
            final ix = game.index;
            final lost = game.world.turfs.values.where(_lost).length;
            if (lost == 0 && _filter == _Filter.lost) _filter = _Filter.all;
            final rows = _rows();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Eyebrow('Turf roster', color: Palette.mint),
                      const SizedBox(height: 4),
                      Text('${ix.owned} turf${ix.owned == 1 ? '' : 's'}', style: TextStyles.display),
                      const SizedBox(height: 4),
                      Text(
                        '${ix.hubs.length} hub${ix.hubs.length == 1 ? '' : 's'} · ${ix.stations} at stations · '
                        '${ix.owned - ix.supplied} with no hub${lost > 0 ? ' · $lost lost to rivals' : ''}',
                        style: TextStyles.dataSmall,
                      ),
                      const SizedBox(height: 4),
                      YieldLine(ix.hourly, size: 12.5, suffix: '  per hour'),
                      const SizedBox(height: 4),
                      Text(
                        'Each row shows what that turf supplies per hour. Tap one to see it on the map.',
                        style: TextStyles.bodyDim.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: rows.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              ix.owned == 0 ? 'No turfs yet. Plant one where you stand.' : 'Nothing in this filter.',
                              style: TextStyles.bodyDim,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                          itemCount: rows.length,
                          itemBuilder: (context, i) => _Row(
                            game: game,
                            t: rows[i],
                            distM: _distM(rows[i]),
                            onTap: () {
                              Navigator.of(context).pop();
                              widget.onPick(rows[i]);
                            },
                          ),
                        ),
                ),
                // Sorting, filters and the way back sit at the bottom, in thumb reach.
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  decoration: const BoxDecoration(
                    color: Palette.slate,
                    border: Border(top: BorderSide(color: Palette.line)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Chips<_Filter>(
                        label: 'Show',
                        values: [
                          for (final f in _Filter.values)
                            if (f != _Filter.lost || lost > 0) f,
                        ],
                        current: _filter,
                        text: (f) => f.label,
                        tone: (f) => f == _Filter.lost ? Tone.hostile : Tone.mint,
                        onSelect: (f) => setState(() => _filter = f),
                      ),
                      const SizedBox(height: 6),
                      _Chips<_Sort>(
                        label: 'Sort',
                        values: _Sort.values,
                        current: _sort,
                        text: (s) => s.label,
                        tone: (_) => Tone.amber,
                        onSelect: (s) => setState(() => _sort = s),
                      ),
                      const SizedBox(height: 10),
                      CommandButton(label: 'Back to the map', onPressed: () => Navigator.of(context).pop()),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Chips<T> extends StatelessWidget {
  const _Chips({
    required this.label,
    required this.values,
    required this.current,
    required this.text,
    required this.tone,
    required this.onSelect,
  });
  final String label;
  final List<T> values;
  final T current;
  final String Function(T) text;
  final Tone Function(T) tone;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      SizedBox(width: 38, child: Text(label.toUpperCase(), style: TextStyles.label.copyWith(fontSize: 9))),
      Expanded(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final v in values)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: _Chip(text(v), on: v == current, color: toneColor(tone(v)), onTap: () => onSelect(v)),
                ),
            ],
          ),
        ),
      ),
    ],
  );
}

/// Chamfered toggle sized to its label, so nothing is cut short.
class _Chip extends StatelessWidget {
  const _Chip(this.label, {required this.on, required this.color, required this.onTap});
  final String label;
  final bool on;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: on,
    label: label,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 36,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 11),
        decoration: ShapeDecoration(
          color: on ? color : Colors.transparent,
          shape: chamfer(7, on ? null : Palette.textDim.withValues(alpha: 0.7)),
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyles.label.copyWith(
            fontSize: 11,
            letterSpacing: 1,
            fontWeight: FontWeight.w700,
            color: on ? Palette.carbon : Palette.textDim,
          ),
        ),
      ),
    ),
  );
}

class _Row extends StatelessWidget {
  const _Row({required this.game, required this.t, required this.distM, required this.onTap});
  final GameController game;
  final Turf t;
  final double? distM;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ix = game.index;
    final mine = t.isPlayer;
    final supplied = ix.supplier.containsKey(t.id);
    final color = !mine ? Palette.hostile : (t.isHub ? Palette.amber : Palette.mint);
    final integ = t.integrity.clamp(0, 100) / 100;
    final integColor = integ > 0.6 ? Palette.mint : (integ > 0.3 ? Palette.amber : Palette.hostile);
    final y = ix.turfHourly[t.id];
    final faction = mine ? null : game.world.factionById(factionIdOf(t.owner));
    final locked = mine && ix.lockedDistricts.contains(t.district);
    final sieged = mine && game.world.siegeSince(t.id) != null;
    final status = !mine
        ? 'Held by ${faction == null ? 'rivals' : factionName(faction, game.player.level)}'
        : sieged
        ? 'Under siege · repair it before the next raid'
        : locked
        ? 'District locked down · income frozen'
        : t.isHub
        ? '${hubClass(t.hubLevel)} · hub L${t.hubLevel}'
        : supplied
        ? 'Supplied by ${game.world.turfs[ix.supplier[t.id]]?.name ?? 'hub'}'
        : (t.isStation ? 'Station · runs alone at 70%' : 'No hub · 40% output');
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Panel(
          padding: EdgeInsets.zero,
          border: color.withValues(alpha: 0.3),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 3, color: color),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 9, 6, 9),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                t.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyles.title.copyWith(fontSize: 14, color: mine ? Palette.text : color),
                              ),
                            ),
                            if (t.isStation) ...[
                              const SizedBox(width: 6),
                              const TagChip('Station', color: Palette.amber),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          status,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyles.dataSmall.copyWith(
                            color: locked || sieged
                                ? Palette.hostile
                                : (mine && !supplied && !t.isHub ? Palette.amber : null),
                          ),
                        ),
                        if (mine) ...[
                          const SizedBox(height: 4),
                          YieldLine(y ?? const Resources()),
                        ],
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            SizedBox(
                              width: 128,
                              child: Text(
                                '${t.biome.label.split(' ').first} · ${mine ? 'G${t.garrison}' : (t.isHub ? 'hub L${t.hubLevel}' : 'L${t.garrison}')}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyles.dataSmall,
                              ),
                            ),
                            Expanded(
                              child: Meter(value: integ.toDouble(), color: integColor, height: 3),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 36,
                              child: Text(
                                '${(integ * 100).round()}%',
                                textAlign: TextAlign.right,
                                style: TextStyles.dataSmall.copyWith(color: integColor),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 70,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.near_me_outlined, size: 16, color: Palette.textDim),
                      const SizedBox(height: 3),
                      Text(distM == null ? '—' : fmtKm(distM! / 1000), style: TextStyles.dataSmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
