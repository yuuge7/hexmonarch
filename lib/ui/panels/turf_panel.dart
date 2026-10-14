import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../domain/balance.dart';
import '../../domain/empire.dart';
import '../../domain/loot.dart';
import '../../domain/models.dart';
import '../../domain/perks.dart';
import '../../domain/tiers.dart';
import '../../domain/world.dart';
import '../../game/game_controller.dart';
import '../../geo/hex_grid.dart';
import '../../platform/location_service.dart';
import '../../platform/place_namer.dart';
import '../widgets/common.dart';
import '../widgets/event_card.dart';
import '../widgets/intel.dart';

/// The spot you are standing on, or the turf you tapped. Commands are pinned
/// to the bottom edge for thumbs.
class TurfPanel extends StatelessWidget {
  const TurfPanel({super.key, required this.game, required this.onLocate});
  final GameController game;
  final LocateCallback onLocate;

  @override
  Widget build(BuildContext context) {
    return Ticking(
      tick: game.tick,
      builder: (context) {
        // A tapped spot of open ground wins over everything else.
        if (game.hasPick && game.selected == null) {
          return _GroundBody(game: game, lat: game.pickLat!, lng: game.pickLng!, place: game.pickPlace, remote: true);
        }
        final t = game.focusTurf;
        if (t != null) return _TurfBody(key: ValueKey(t.id), game: game, t: t, onLocate: onLocate);
        if (game.lat == null) return _NoFix(game: game);
        return _GroundBody(game: game, lat: game.lat!, lng: game.lng!, place: game.herePlace, remote: false);
      },
    );
  }
}

class _NoFix extends StatelessWidget {
  const _NoFix({required this.game});
  final GameController game;

  @override
  Widget build(BuildContext context) {
    final st = game.location.status;
    final (title, body, action) = switch (st) {
      LocStatus.deniedForever => (
        'Location blocked',
        'Turfs are planted where you physically stand. Allow precise location in system settings.',
        'Open settings',
      ),
      LocStatus.denied => ('Location needed', 'Grant precise location to plant turfs where you stand.', 'Grant access'),
      LocStatus.serviceOff => (
        'GPS is off',
        'Turn on location services to find your position.',
        'Open location settings',
      ),
      _ => ('Acquiring GPS', 'Hold on while your device finds a fix. Step outside for a faster lock.', null),
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('No position lock', color: Palette.amber),
          const SizedBox(height: 6),
          Text(title, style: TextStyles.display),
          const SizedBox(height: 6),
          Text(body, style: TextStyles.bodyDim),
          const Spacer(),
          if (action != null)
            CommandButton(
              label: action,
              icon: Icons.gps_fixed,
              onPressed: () {
                switch (st) {
                  case LocStatus.deniedForever:
                    game.location.openSettings();
                  case LocStatus.serviceOff:
                    game.location.openLocationSettings();
                  default:
                    game.retryLocation();
                }
              },
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- open ground

/// You are not inside any turf: this is where a new one can be planted.
class _GroundBody extends StatelessWidget {
  const _GroundBody({
    required this.game,
    required this.lat,
    required this.lng,
    required this.place,
    required this.remote,
  });
  final GameController game;
  final double lat;
  final double lng;
  final PlaceHit? place;

  /// True when this is a tapped spot, planted from a distance.
  final bool remote;

  @override
  Widget build(BuildContext context) {
    final w = game.world;
    final block = game.grid.cellAt(lat, lng, kPlayRes);
    final genome = w.genome(block);
    final q = remote
        ? game.actions.claimQuote(lat, lng, fromLat: game.lat, fromLng: game.lng, remote: true)
        : game.actions.claimQuote(lat, lng);
    final via = remote && q.blocker != 'Out of plant range'
        ? game.actions.claimVia(lat, lng, fromLat: game.lat, fromLng: game.lng)
        : null;
    final away = remote && game.lat != null ? metersBetween(game.lat!, game.lng!, lat, lng) : null;
    final near = w.nearest(lat, lng, withinM: 2000);
    final base = biomeYield(genome.biome);
    final (turfName, station) = game.turfIdentity(place);

    return Column(
      children: [
        Expanded(
          child: _Faded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Eyebrow(
                        remote ? 'Picked spot${away == null ? '' : ' · ${fmtKm(away / 1000)} away'}' : 'Open ground',
                      ),
                    ),
                    TagChip(
                      q.blocker ?? 'Turf can go here',
                      color: q.blocker == null ? Palette.mint : Palette.amber,
                      filled: q.blocker == null,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(turfName ?? 'Unnamed ground', style: TextStyles.display),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (via != null) TagChip('In reach of ${via.name}', color: Palette.mint, filled: true),
                    if (station)
                      const TagChip('Transit station · +30% credits · relay x1.5', color: Palette.amber, filled: true),
                    TagChip(genome.biome.label, color: Palette.textDim),
                    if (genome.anomaly != null)
                      TagChip('${genome.anomaly!.label} · ${genome.anomaly!.effect}', color: Palette.ice, filled: true),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: StatCell(
                        'Base yield /h',
                        fmtNum(base.credits * (station ? kStationCreditBonus : 1)),
                        color: Palette.amber,
                        sub: '${fmtNum(base.materials)} mat · ${fmtNum(base.intel)} int',
                      ),
                    ),
                    Expanded(
                      child: StatCell(
                        'Nearest turf',
                        near == null ? 'none in 2 km' : fmtKm(near.$2 / 1000),
                        color: near == null ? Palette.textDim : (near.$1.isHostile ? Palette.hostile : Palette.mint),
                        sub: near == null ? 'wide open' : (near.$1.isPlayer ? near.$1.name : 'rival crew'),
                      ),
                    ),
                  ],
                ),
                if (q.note != null && q.blocker != null) ...[
                  const SizedBox(height: 10),
                  Text('${q.note}.', style: TextStyles.bodyDim.copyWith(fontSize: 12)),
                ],
                if (!remote) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Or tap open ground within ${game.world.perks.plantRangeM.round()} m of you or of any turf you hold '
                    '(the green outlines) to plant there without walking over.',
                    style: TextStyles.bodyDim.copyWith(fontSize: 12),
                  ),
                ],
                if (w.index.owned == 0) ...[
                  const SizedBox(height: 12),
                  Panel(
                    border: Palette.mint.withValues(alpha: 0.3),
                    child: const Text(
                      'Plant a turf wherever you are: at a station, on the train, on your street. '
                      'Then upgrade one into an Anchor Hub so it supplies the turfs around it. '
                      'New here? Network tab, Field manual.',
                      style: TextStyles.bodyDim,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        _Bar(
          primary: CommandButton(
            label: q.blocker ?? (remote ? 'Plant turf there' : 'Plant turf here'),
            icon: q.blocker == null ? Icons.add_location_alt_outlined : null,
            cost: q.blocker == null ? q.cost : null,
            caption: q.blocker == null ? null : q.note,
            have: game.player,
            onPressed: q.allowed ? (remote ? game.claimPick : game.claimHere) : null,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- turf

enum _Section {
  overview('Overview'),
  modules('Modules'),
  manage('Manage');

  const _Section(this.label);
  final String label;
}

class _TurfBody extends StatefulWidget {
  const _TurfBody({super.key, required this.game, required this.t, required this.onLocate});
  final GameController game;
  final Turf t;
  final LocateCallback onLocate;

  @override
  State<_TurfBody> createState() => _TurfBodyState();
}

class _TurfBodyState extends State<_TurfBody> {
  _Section _section = _Section.overview;

  GameController get game => widget.game;
  Turf get t => widget.t;

  @override
  Widget build(BuildContext context) {
    final w = game.world;
    final mine = t.isPlayer;
    final relevant = [
      for (final e in w.events)
        if (e.target == t.id || (mine && e.type == EventType.lockdown && e.district == t.district)) e,
    ];

    final body = <Widget>[
      _header(context),
      const SizedBox(height: 12),
      if (mine) ...[
        Row(
          children: [
            for (final s in _Section.values) ...[
              if (s != _Section.overview) const SizedBox(width: 6),
              Expanded(
                child: SegChip(
                  s == _Section.modules ? 'Modules ${w.modulesOn(t.id).length}/${w.socketsOf(t)}' : s.label,
                  on: s == _section,
                  height: 32,
                  onTap: () => setState(() => _section = s),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        ...switch (_section) {
          _Section.overview => _overview(relevant),
          _Section.modules => _modules(),
          _Section.manage => _manage(context),
        },
      ] else ...[
        _RivalStats(game: game, t: t),
        for (final e in relevant) ...[
          const SizedBox(height: 10),
          EventCard(game: game, event: e, onLocate: widget.onLocate),
        ],
      ],
    ];

    return Column(
      children: [
        Expanded(
          child: _Faded(
            child: ListView(padding: const EdgeInsets.fromLTRB(16, 10, 16, 24), children: body),
          ),
        ),
        _commands(context),
      ],
    );
  }

  // ------------------------------------------------------------ header

  Widget _header(BuildContext context) {
    final mine = t.isPlayer;
    final inside = game.hereZone == t.id;
    final distM = game.lat == null ? null : metersBetween(game.lat!, game.lng!, t.lat, t.lng);
    final strikeFrom = mine ? null : game.actions.breachVia(t, game.lat, game.lng);
    final color = mine ? (t.isHub ? Palette.amber : Palette.mint) : Palette.hostile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Eyebrow(
                mine
                    ? (t.isHub
                          ? 'Anchor hub · ${hubClass(t.hubLevel)} L${t.hubLevel}'
                          : 'Your turf · garrison L${t.garrison}')
                    : 'Rival turf',
                color: color,
              ),
            ),
            TagChip(
              inside ? 'You are inside' : (distM == null ? 'No fix' : '${fmtKm(distM / 1000)} away'),
              color: inside ? Palette.mint : Palette.textDim,
              filled: inside,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                mine ? t.name : _factionLine(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.display.copyWith(
                  color: mine && t.isHub ? Palette.amber : (mine ? Palette.text : Palette.hostile),
                ),
              ),
            ),
            if (mine)
              IconButton(
                tooltip: 'Rename turf',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.edit_outlined, size: 18, color: Palette.textDim),
                onPressed: () => showRename(context, game, t),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            if (strikeFrom != null) TagChip('In reach of ${strikeFrom.name}', color: Palette.mint, filled: true),
            if (t.isStation) const TagChip('Transit station', color: Palette.amber, filled: true),
            TagChip(t.biome.label, color: Palette.textDim),
            if (t.anomaly != null && (mine || inside))
              TagChip('${t.anomaly!.label} · ${t.anomaly!.effect}', color: Palette.ice, filled: true),
          ],
        ),
      ],
    );
  }

  String _factionLine() {
    final f = game.world.factionById(factionIdOf(t.owner));
    return f == null ? 'Hostile turf' : factionName(f, game.player.level);
  }

  // ------------------------------------------------------------ sections

  List<Widget> _overview(List<WorldEvent> relevant) {
    final w = game.world;
    final ix = w.index;
    final supplierId = ix.supplier[t.id];
    final supplier = supplierId == null ? null : w.turfs[supplierId];
    final net = supplierId == null ? null : ix.networkOfHub(supplierId);
    final siege = w.siegeSince(t.id);
    return [
      _SupplyLine(supplier: supplier?.name, isHub: t.isHub, isStation: t.isStation, trade: net?.trade),
      if (siege != null) ...[
        const SizedBox(height: 6),
        _StatusLine(
          Palette.hostile,
          'Under siege since ${clockTime(siege)}. The next raid that breaks it takes it: '
          'repair it${supplier != null ? ' or let its hub mend it to 100%' : ''}.',
        ),
      ],
      const SizedBox(height: 12),
      _Stats(game: game, t: t),
      for (final e in relevant) ...[
        const SizedBox(height: 10),
        EventCard(game: game, event: e, onLocate: widget.onLocate),
      ],
    ];
  }

  List<Widget> _modules() {
    final stash = game.world.stash.length;
    final free = game.world.socketsOf(t) - game.world.modulesOn(t.id).length;
    return [
      _Sockets(game: game, t: t),
      const SizedBox(height: 12),
      CommandButton(
        label: free <= 0 ? 'Every socket is full' : (stash == 0 ? 'Stash is empty' : 'Fill from stash · best first'),
        height: 44,
        filled: false,
        icon: Icons.auto_fix_high_outlined,
        onPressed: free > 0 && stash > 0 ? () => game.run((a, now) => a.fillSockets(now, only: t.id)) : null,
      ),
      const SizedBox(height: 8),
      Text(
        'A module on a hub also lifts every turf the hub supplies. Tap an empty socket to choose one yourself, '
        'or the amber tile to buy another socket.',
        style: TextStyles.bodyDim.copyWith(fontSize: 12),
      ),
    ];
  }

  List<Widget> _manage(BuildContext context) {
    final a = game.actions;
    final id = t.id;
    final hubs = game.index.hubs.length;
    return [
      _LevelRows(game: game, t: t, kind: UpgradeKind.garrison),
      if (t.isHub) ...[
        const SizedBox(height: 10),
        _LevelRows(game: game, t: t, kind: UpgradeKind.hub),
        const SizedBox(height: 10),
        CommandButton(
          label: 'Relays · ${game.world.relayLinks(t).length}/$kRelayLinksPerHub',
          icon: Icons.cell_tower,
          height: 44,
          filled: false,
          tone: Tone.amber,
          onPressed: () => showRelayPicker(context, game, id, widget.onLocate),
        ),
      ] else ...[
        const SizedBox(height: 10),
        Builder(
          builder: (context) {
            final q = a.hubQuote(id);
            return CommandButton(
              label: hubs == 0 ? 'Make this an anchor hub' : 'Make this a hub',
              height: 48,
              filled: false,
              tone: Tone.amber,
              cost: q.cost,
              have: game.player,
              onPressed: q.allowed ? () => game.run((a, now) => a.establishHub(id, now)) : null,
            );
          },
        ),
      ],
      const SizedBox(height: 18),
      const Eyebrow('Let it go', color: Palette.hostile),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: CommandButton(
              label: 'Hold to abandon',
              height: 40,
              filled: false,
              tone: Tone.hostile,
              holdToConfirm: true,
              onPressed: () => game.run((a, now) => a.abandon(id, now)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CommandButton(
              label: 'Hold to delete',
              height: 40,
              tone: Tone.hostile,
              icon: Icons.delete_forever_outlined,
              holdToConfirm: true,
              onPressed: () => game.run((a, now) => a.delete(id, now)),
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      Text(
        'Abandon: you walk away, a crew or auto-plant can take the spot again. '
        'Delete: gone for good, nothing comes back here unless you plant it by hand. '
        'Either way the modules go to your stash and nothing is refunded.',
        style: TextStyles.bodyDim.copyWith(fontSize: 12),
      ),
    ];
  }

  // ------------------------------------------------------------ commands

  /// One row, thumb height: the turf's main move, plus Repair when it is
  /// damaged. Everything else lives under Manage.
  Widget _commands(BuildContext context) {
    final a = game.actions;
    final p = game.player;
    final id = t.id;
    if (!t.isPlayer) {
      final q = a.breachQuote(t, game.lat, game.lng);
      return _Bar(
        primary: CommandButton(
          label: q.blocker ?? 'Breach · ${q.note}',
          tone: Tone.hostile,
          cost: q.blocker == null ? q.cost : null,
          caption: q.blocker == null ? null : q.note,
          have: p,
          onPressed: q.allowed ? () => game.breach(id) : null,
        ),
      );
    }
    final Widget primary;
    if (t.isHub) {
      final q = a.hubUpgradeQuote(id);
      primary = CommandButton(
        label: 'Hub to L${t.hubLevel + 1}',
        tone: Tone.amber,
        cost: q.cost,
        have: p,
        onPressed: q.allowed ? () => game.run((a, now) => a.upgradeHub(id, now)) : null,
      );
    } else if (game.index.hubs.isEmpty) {
      final q = a.hubQuote(id);
      primary = CommandButton(
        label: 'Make anchor hub',
        tone: Tone.amber,
        cost: q.cost,
        have: p,
        onPressed: q.allowed ? () => game.run((a, now) => a.establishHub(id, now)) : null,
      );
    } else {
      final q = a.garrisonQuote(id);
      primary = CommandButton(
        label: 'Garrison to L${t.garrison + 1}',
        cost: q.cost,
        have: p,
        onPressed: q.allowed ? () => game.run((a, now) => a.upgradeGarrison(id, now)) : null,
      );
    }
    final rq = a.repairQuote(id);
    final Widget? secondary = rq.blocker == null
        ? CommandButton(
            label: 'Repair',
            filled: false,
            cost: rq.cost,
            have: p,
            onPressed: rq.allowed ? () => game.run((a, now) => a.repair(id, now)) : null,
          )
        : (t.isHub
              ? CommandButton(
                  label: 'Garrison +1',
                  filled: false,
                  cost: a.garrisonQuote(id).cost,
                  have: p,
                  onPressed: a.garrisonQuote(id).allowed
                      ? () => game.run((a, now) => a.upgradeGarrison(id, now))
                      : null,
                )
              : null);
    return _Bar(primary: primary, secondary: secondary);
  }
}

/// +1, +5, +10 and +25 levels for one turf, each with its price.
class _LevelRows extends StatelessWidget {
  const _LevelRows({required this.game, required this.t, required this.kind});
  final GameController game;
  final Turf t;
  final UpgradeKind kind;

  @override
  Widget build(BuildContext context) {
    final garrison = kind == UpgradeKind.garrison;
    final color = garrison ? Palette.mint : Palette.amber;
    final level = garrison ? t.garrison : t.hubLevel;
    final hub = game.index.hubs[t.id];
    return Panel(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      border: color.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Eyebrow(garrison ? 'Garrison · L$level' : 'Hub · L$level ${hubClass(level)}', color: color),
              const Spacer(),
              Text(
                garrison
                    ? 'defense ${fmtNum(game.index.turfDefense[t.id] ?? 0)}'
                    : 'sphere ${fmtKm(hub?.radiusKm ?? 0)} · relay ${fmtKm(hub?.relayKm ?? 0)}',
                style: TextStyles.dataSmall,
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (final n in const [1, 5, 10, 25])
            Builder(
              builder: (context) {
                final plan = game.actions.upgradePlan([t], kind, add: n);
                final ok = plan.cost.affordable(game.player);
                final gain = plan.gain;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 64,
                        child: Text(
                          'L${level + n}',
                          style: TextStyles.data.copyWith(color: ok ? Palette.text : Palette.textDim),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CostLine(plan.cost, have: game.player, color: Palette.amber),
                            Text(
                              '+${fmtNum(gain.credits)} cr/h${gain.materials > 0.05 ? ' · +${fmtNum(gain.materials)} mat/h' : ''}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyles.dataSmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 76,
                        child: CommandButton(
                          label: '+$n',
                          height: 36,
                          filled: n == 1,
                          tone: garrison ? Tone.mint : Tone.amber,
                          onPressed: ok ? () => game.run((a, now) => a.bulkUpgrade([t.id], kind, now, add: n)) : null,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// Fades the last few pixels of a scrolling list, so text running under the
/// command bar dissolves instead of being cut in half.
class _Faded extends StatelessWidget {
  const _Faded({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => ShaderMask(
    blendMode: BlendMode.dstIn,
    shaderCallback: (r) => LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [Colors.white, Colors.white, Colors.transparent],
      stops: [0, r.height <= 0 ? 0.9 : (1 - 22 / r.height).clamp(0.0, 1.0), 1],
    ).createShader(r),
    child: child,
  );
}

class _Bar extends StatelessWidget {
  const _Bar({required this.primary, this.secondary});
  final Widget primary;
  final Widget? secondary;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
    decoration: const BoxDecoration(
      color: Palette.slate,
      border: Border(top: BorderSide(color: Palette.line)),
    ),
    child: Row(
      children: [
        if (secondary != null) ...[Expanded(flex: 2, child: secondary!), const SizedBox(width: 8)],
        Expanded(flex: 3, child: primary),
      ],
    ),
  );
}

class _SupplyLine extends StatelessWidget {
  const _SupplyLine({required this.supplier, required this.isHub, required this.isStation, required this.trade});
  final String? supplier;
  final bool isHub;
  final bool isStation;
  final double? trade;

  @override
  Widget build(BuildContext context) {
    final tradeText = trade != null && trade! > 1 ? ' · trade x${trade!.toStringAsFixed(2)}' : '';
    final (Color c, String text) = isHub
        ? (Palette.amber, 'Supplies every turf in its sphere$tradeText')
        : supplier != null
        ? (Palette.mint, 'Supplied by $supplier$tradeText')
        : isStation
        ? (Palette.mint, 'Station turf: runs on its own at 70% until a hub covers it')
        : (Palette.amber, 'No hub in reach: 40% output, wears down and draws raids');
    return _StatusLine(c, text);
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine(this.color, this.text);
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            boxShadow: [BoxShadow(color: color, blurRadius: 6)],
          ),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(text, style: TextStyles.body.copyWith(color: color)),
      ),
    ],
  );
}

/// What this turf puts in your pocket every hour, and what makes it so.
class _Supplies extends StatelessWidget {
  const _Supplies({required this.game, required this.t});
  final GameController game;
  final Turf t;

  static String _x(double v) => 'x${v.toStringAsFixed(2)}';

  List<(String, Color)> _factors(TurfYield y) => [
    if (y.lockdown != 1) (y.lockdown == 0 ? 'Lockdown: frozen' : 'Lockdown ${_x(y.lockdown)}', Palette.hostile),
    if (y.supply != 1) (t.isStation ? 'No hub, station ${_x(y.supply)}' : 'No hub ${_x(y.supply)}', Palette.amber),
    if (y.garrison != 1) ('Garrison ${_x(y.garrison)}', Palette.mint),
    if (y.hub != 1) ('Hub ${_x(y.hub)}', Palette.amber),
    if (y.trade != 1) ('Trade ${_x(y.trade)}', Palette.amber),
    if (y.aura != 1) ('Hub modules ${_x(y.aura)}', Palette.mint),
    if (y.modules != 1) ('Modules ${_x(y.modules)}', Palette.mint),
    if (y.level != 1) ('Level ${_x(y.level)}', Palette.textDim),
    if (y.station != 1) ('Station ${_x(y.station)} cr', Palette.amber),
    if (y.surge != 1) ('Surge ${_x(y.surge)}', Palette.mint),
    if (y.market != 1) ('Market ${_x(y.market)} cr', y.market > 1 ? Palette.mint : Palette.hostile),
    if (y.vaultCredits != 1) ('Vault ${_x(y.vaultCredits)} cr', Palette.textDim),
    if (y.vaultLogistics != 1) ('Vault ${_x(y.vaultLogistics)} mat, int', Palette.textDim),
    if (!y.flat.isZero) ('Modules +${fmtNum(y.flat.materials)} mat +${fmtNum(y.flat.intel)} int', Palette.mint),
  ];

  @override
  Widget build(BuildContext context) {
    final ix = game.index;
    final y = ix.turfHourly[t.id] ?? const Resources();
    final parts = ix.turfYield[t.id];
    Widget cell(String label, double v, Color c) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(label),
          const SizedBox(height: 3),
          Text('+${fmtNum(v)}', style: TextStyles.data.copyWith(color: c, fontSize: 18)),
          Text('${fmtNum(v * 24)} a day', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyles.dataSmall),
        ],
      ),
    );
    final factors = parts == null ? const <(String, Color)>[] : _factors(parts);
    return Panel(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      border: Palette.amber.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('This turf supplies you, per hour', color: Palette.amber),
          const SizedBox(height: 8),
          Row(
            children: [
              cell('Credits', y.credits, Palette.amber),
              cell('Materials', y.materials, Palette.text),
              cell('Intel', y.intel, Palette.ice),
            ],
          ),
          if (parts != null) ...[
            const SizedBox(height: 8),
            Text(
              '${t.biome.label} ground gives ${fmtNum(parts.base.credits)} cr · ${fmtNum(parts.base.materials)} mat · '
              '${fmtNum(parts.base.intel)} int${factors.isEmpty ? '' : ', then:'}',
              style: TextStyles.bodyDim.copyWith(fontSize: 12),
            ),
            if (factors.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [for (final (label, color) in factors) TagChip(label, color: color)],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.game, required this.t});
  final GameController game;
  final Turf t;

  @override
  Widget build(BuildContext context) {
    final ix = game.index;
    final def = ix.turfDefense[t.id] ?? 0;
    final integ = t.integrity.clamp(0, 100) / 100;
    final integColor = integ > 0.6 ? Palette.mint : (integ > 0.3 ? Palette.amber : Palette.hostile);
    final hub = ix.hubs[t.id];
    return Column(
      children: [
        _Supplies(game: game, t: t),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: StatCell('Defense', fmtNum(def), sub: 'garrison L${t.garrison}')),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatCell('Integrity', '${(integ * 100).round()}%', color: integColor),
                  const SizedBox(height: 4),
                  Meter(value: integ.toDouble(), color: integColor, height: 3),
                ],
              ),
            ),
          ],
        ),
        if (hub != null) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: StatCell('Supply sphere', fmtKm(hub.radiusKm), color: Palette.amber)),
              Expanded(child: StatCell('Relay range', fmtKm(hub.relayKm), color: Palette.amber)),
              Expanded(
                child: Builder(
                  builder: (context) {
                    final links = game.world.relayLinks(t);
                    return StatCell(
                      'Relays',
                      links.isEmpty ? 'none' : '${links.length} / $kRelayLinksPerHub',
                      color: links.isEmpty ? Palette.textDim : Palette.amber,
                      sub: links.isEmpty ? null : links.map((id) => game.world.turfs[id]?.name ?? '?').join(', '),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _RivalStats extends StatelessWidget {
  const _RivalStats({required this.game, required this.t});
  final GameController game;
  final Turf t;

  @override
  Widget build(BuildContext context) {
    final w = game.world;
    final f = w.factionById(factionIdOf(t.owner));
    final base = biomeYield(t.biome);
    final s = game.actions.strikeParts(t);
    final def = w.enemyDefense(t);
    final integ = t.integrity.clamp(0, 100).round();
    final hub = w.coverHub(t);
    final recon = w.perks.rivalDefMult;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (f != null) ...[
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              StrengthChip(factionProfile(f.archetype).grit),
              if (f.nemesisRank > 0) TagChip('Nemesis rank ${f.nemesisRank}', color: Palette.hostile),
              if (t.isHub) TagChip('Captured hub L${t.hubLevel}', color: Palette.amber),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${factionKind(f, game.player.level)} · take it and it becomes yours, hub and modules included.',
            style: TextStyles.bodyDim,
          ),
        ],
        const SizedBox(height: 10),
        Panel(
          border: Palette.hostile.withValues(alpha: 0.3),
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OddsBar(strike: s.total, defense: def, odds: game.actions.breachOdds(t)),
              const SizedBox(height: 10),
              const Divider(height: 1, color: Palette.line),
              const SizedBox(height: 8),
              const Eyebrow('Your strike'),
              const SizedBox(height: 4),
              _Line('Level ${game.player.level}', fmtNum(s.level)),
              if (s.hub > 0) _Line('Hub · ${hub?.hub.name ?? 'covering hub'}', '+${fmtNum(s.hub)}'),
              if (s.backup > 0)
                _Line(
                  'Backup · ${s.backupFrom?.name ?? 'your turf'} (L${s.backupFrom?.garrison ?? 1})',
                  '+${fmtNum(s.backup)}',
                ),
              if (s.perk > 1) _Line('Muscle', 'x${s.perk.toStringAsFixed(2)}'),
              if (s.boost > 1) _Line('Hired Guns', 'x${s.boost.toStringAsFixed(1)}', color: Palette.mint),
              const SizedBox(height: 8),
              const Eyebrow('Their defense'),
              const SizedBox(height: 4),
              _Line(
                hub == null ? 'No hub of yours nearby: they stay small' : 'Armed up by your hub L${hub.hub.hubLevel}',
                fmtNum(def),
                color: Palette.hostile,
              ),
              if (integ < 100)
                _Line('Worn to $integ% integrity', '-${100 - (50 + integ / 2).round()}%', color: Palette.mint),
              if (recon < 1) _Line('Recon', '-${((1 - recon) * 100).round()}%', color: Palette.mint),
              if (w.boosted(kBoostInsideMan))
                _Line('Inside Man', '-${((1 - kInsideManDefense) * 100).round()}%', color: Palette.mint),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: StatCell(
                'Worth /h',
                fmtNum(base.credits),
                color: Palette.amber,
                sub: '${fmtNum(base.materials)} mat · ${fmtNum(base.intel)} int',
              ),
            ),
            Expanded(
              child: StatCell(
                'Integrity',
                '$integ%',
                color: integ < 100 ? Palette.mint : Palette.text,
                sub: integ < 100 ? 'worn down' : 'untouched',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Hit harder: garrison the turf of yours next to it, Muscle and Recon in Crew > Perks, '
          'Hired Guns and Inside Man in Crew > Shop. A failed breach still knocks ${kBreachWear.round()}% off their integrity.',
          style: TextStyles.bodyDim.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}

/// One line of a breakdown: what, and how much.
class _Line extends StatelessWidget {
  const _Line(this.label, this.value, {this.color = Palette.text});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.body.copyWith(fontSize: 13),
          ),
        ),
        const SizedBox(width: 8),
        Text(value, style: TextStyles.data.copyWith(fontSize: 13, color: color)),
      ],
    ),
  );
}

class _Sockets extends StatelessWidget {
  const _Sockets({required this.game, required this.t});
  final GameController game;
  final Turf t;

  @override
  Widget build(BuildContext context) {
    final count = game.world.socketsOf(t);
    final mods = {for (final m in game.world.modulesOn(t.id)) m.socket: m};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Eyebrow('Module sockets ${mods.length}/$count'),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < count; i++)
              _SocketTile(
                module: mods[i],
                onTap: () =>
                    mods[i] == null ? showModulePicker(context, game, t.id) : showModuleDetail(context, game, mods[i]!),
              ),
            _AddSocketTile(onTap: () => showSocketSheet(context, game, t)),
          ],
        ),
      ],
    );
  }
}

class _SocketTile extends StatelessWidget {
  const _SocketTile({required this.module, required this.onTap});
  final Module? module;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final m = module;
    final c = m == null ? Palette.line : rarityColor(m.rarity);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: ShapeDecoration(
          color: m == null ? Colors.transparent : c.withValues(alpha: 0.08),
          shape: chamfer(7, c.withValues(alpha: m == null ? 1 : 0.7)),
        ),
        child: m == null
            ? const Row(
                children: [
                  Icon(Icons.add, size: 16, color: Palette.textDim),
                  SizedBox(width: 6),
                  Text('EMPTY SOCKET', style: TextStyles.label),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    m.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.body.copyWith(fontSize: 12, color: c),
                  ),
                  Text(
                    _modStats(m),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.dataSmall.copyWith(fontSize: 10),
                  ),
                ],
              ),
      ),
    );
  }
}

class _AddSocketTile extends StatelessWidget {
  const _AddSocketTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 150,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: ShapeDecoration(shape: chamfer(7, Palette.amber.withValues(alpha: 0.6))),
      child: Row(
        children: [
          const Icon(Icons.add_box_outlined, size: 16, color: Palette.amber),
          const SizedBox(width: 6),
          Text('BUY A SOCKET', style: TextStyles.label.copyWith(color: Palette.amber)),
        ],
      ),
    ),
  );
}

String _modStats(Module m) {
  final parts = <String>[];
  if (m.cashMult > 0.0005) parts.add('${fmtPct(m.cashMult)} yld');
  if (m.defMult > 0.0005) parts.add('${fmtPct(m.defMult)} def');
  return parts.join(' · ');
}

// ---------------------------------------------------------------- sheets

Future<void> _sheet(BuildContext context, String title, List<Widget> Function(BuildContext) children) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Palette.slate,
    shape: chamfer(16, Palette.line),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * 0.6),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(title, style: TextStyles.title),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: children(ctx),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> showRename(BuildContext context, GameController game, Turf t) {
  final ctl = TextEditingController(text: t.name);
  void submit(BuildContext ctx) {
    Navigator.pop(ctx);
    game.run((a, now) => a.rename(t.id, ctl.text, now));
  }

  return _sheet(
    context,
    'Rename turf',
    (ctx) => [
      TextField(
        controller: ctl,
        autofocus: true,
        maxLength: 28,
        textCapitalization: TextCapitalization.words,
        style: TextStyles.title,
        cursorColor: Palette.mint,
        onSubmitted: (_) => submit(ctx),
        decoration: const InputDecoration(
          counterStyle: TextStyles.label,
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Palette.line)),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Palette.mint)),
        ),
      ),
      const SizedBox(height: 12),
      CommandButton(label: 'Save name', onPressed: () => submit(ctx)),
    ],
  );
}

Future<void> showSocketSheet(BuildContext context, GameController game, Turf t) {
  final q = game.actions.socketQuote(t.id);
  final now = game.world.socketsOf(t);
  return _sheet(
    context,
    'Buy a socket',
    (ctx) => [
      Text(
        'One more module socket on ${t.name}, for good ($now now). '
        'No ceiling: each extra socket on the same turf costs double the last. Also in Crew > Trade.',
        style: TextStyles.bodyDim,
      ),
      const SizedBox(height: 12),
      CommandButton(
        label: 'Add a socket',
        tone: Tone.amber,
        icon: Icons.add_box_outlined,
        cost: q.cost,
        have: game.player,
        onPressed: q.allowed
            ? () {
                Navigator.pop(ctx);
                game.run((a, now) => a.expandSocket(t.id, now));
              }
            : null,
      ),
    ],
  );
}

Future<void> showModulePicker(BuildContext context, GameController game, String turfId) {
  final stash = List.of(game.world.stash)..sort((a, b) => b.score.compareTo(a.score));
  return _sheet(context, 'Socket a module', (ctx) {
    if (stash.isEmpty) {
      return [
        const Text(
          'Stash is empty. Modules drop from breaches, repelled raids, convoys and dead drops.',
          style: TextStyles.bodyDim,
        ),
      ];
    }
    return [
      for (final m in stash)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ModuleTile(
            module: m,
            trailing: CommandButton(
              label: 'Install',
              height: 36,
              onPressed: () {
                Navigator.pop(ctx);
                game.run((a, now) => a.install(m.id, turfId, now));
              },
            ),
          ),
        ),
    ];
  });
}

Future<void> showModuleDetail(BuildContext context, GameController game, Module m) {
  return _sheet(
    context,
    m.name,
    (ctx) => [
      ModuleTile(module: m),
      const SizedBox(height: 12),
      CommandButton(
        label: 'Pull to stash',
        filled: false,
        onPressed: () {
          Navigator.pop(ctx);
          game.run((a, now) => a.uninstall(m.id, now));
        },
      ),
    ],
  );
}

Future<void> showRelayPicker(BuildContext context, GameController game, String fromId, LocateCallback onLocate) {
  final a = game.actions;
  final from = game.world.turfs[fromId];
  final candidates = a.relayCandidates(fromId);
  final range = game.index.hubs[fromId]?.relayKm;
  final boost = game.world.perks.rank(StreetPerk.relay);
  return _sheet(context, 'Relay from ${from?.name ?? 'hub'}', (ctx) {
    final links = from == null ? const <String>[] : game.world.relayLinks(from);
    final net = game.index.networkOfHub(fromId);
    final rows = <Widget>[
      Row(
        children: [
          const Eyebrow('Relay slots'),
          const SizedBox(width: 10),
          SlotPips(used: links.length, total: kRelayLinksPerHub),
          const Spacer(),
          if (net != null)
            Text('TRADE x${net.trade.toStringAsFixed(2)}', style: TextStyles.dataSmall.copyWith(color: Palette.amber)),
        ],
      ),
      if (net != null && net.hubs.length > 1) ...[
        const SizedBox(height: 4),
        Text(
          'Network: ${net.hubs.length} hubs · ${net.districts.length} district${net.districts.length == 1 ? '' : 's'} · '
          '${net.relays} relay${net.relays == 1 ? '' : 's'}',
          style: TextStyles.dataSmall,
        ),
      ],
      const SizedBox(height: 8),
      Text(
        'Up to $kRelayLinksPerHub outbound relays per hub. Linked hubs pool defense, every relay adds 4% trade, '
        'every extra district 30%. Link stations in different districts for the biggest payoff.',
        style: TextStyles.bodyDim,
      ),
      const SizedBox(height: 10),
      if (range != null) ...[
        Panel(
          border: Palette.amber.withValues(alpha: 0.35),
          padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'THIS HUB REACHES ${fmtKm(range).toUpperCase()}',
                style: TextStyles.label.copyWith(color: Palette.amber),
              ),
              const SizedBox(height: 4),
              Text(
                'To reach farther: upgrade this hub (+2.5 km per level${from?.isStation == true ? ', x1.5 at a station' : ''}), '
                'or buy Signal Boost in Crew > Perks (+${(kRelayPerkStep * 100).round()}% per rank on every hub'
                '${boost > 0 ? ', you have rank $boost' : ''}).',
                style: TextStyles.bodyDim.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    ];

    if (candidates.isEmpty) {
      rows.add(const Text('You need a second Anchor Hub to link to.', style: TextStyles.body));
    }
    for (final id in candidates) {
      final h = game.world.turfs[id]!;
      final q = a.relayQuote(fromId, id);
      final isLinked = game.world.linked(fromId, id);
      // Ours to cut only when the relay starts here.
      final outbound = links.contains(id);
      final sameDistrict = h.district == from?.district;
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Panel(
            border: isLinked ? Palette.amber.withValues(alpha: 0.4) : null,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${h.name} · H${h.hubLevel}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.title.copyWith(color: Palette.amber),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${from == null ? '' : fmtKm(game.world.kmBetween(from, h))} · ${sameDistrict ? 'same district' : 'new district +30% trade'}',
                        style: TextStyles.dataSmall.copyWith(color: sameDistrict ? Palette.textDim : Palette.mint),
                      ),
                      const SizedBox(height: 3),
                      if (isLinked)
                        Text(
                          outbound ? 'Linked from this hub' : 'Linked from ${h.name}',
                          style: TextStyles.dataSmall.copyWith(color: Palette.amber),
                        )
                      else if (q.blocker != null) ...[
                        Text(q.blocker!, style: TextStyles.dataSmall.copyWith(color: Palette.hostile)),
                        if (q.note != null) Text(q.note!, style: TextStyles.dataSmall),
                      ] else
                        CostLine(q.cost, have: game.player, color: Palette.amber),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 96,
                  child: outbound
                      ? CommandButton(
                          label: 'Sever',
                          height: 44,
                          filled: false,
                          tone: Tone.hostile,
                          onPressed: () {
                            Navigator.pop(ctx);
                            game.run((a, now) => a.severRelay(fromId, id, now));
                          },
                        )
                      : CommandButton(
                          label: isLinked ? 'Linked' : 'Link',
                          height: 44,
                          tone: Tone.amber,
                          onPressed: q.allowed && !isLinked
                              ? () {
                                  Navigator.pop(ctx);
                                  game.run((a, now) => a.buildRelay(fromId, id, now));
                                }
                              : null,
                        ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return rows;
  });
}

class ModuleTile extends StatelessWidget {
  const ModuleTile({super.key, required this.module, this.trailing});
  final Module module;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final m = module;
    final c = rarityColor(m.rarity);
    return Panel(
      padding: EdgeInsets.zero,
      border: c.withValues(alpha: 0.35),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 3, color: c),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.name,
                      style: TextStyles.body.copyWith(color: c, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text('${m.rarity.label} · iL ${m.itemLevel}', style: TextStyles.label),
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (m.cashMult > 0.0005) '${fmtPct(m.cashMult)} yield',
                        if (m.defMult > 0.0005) '${fmtPct(m.defMult)} defense',
                        if (m.perk != null) perkText(m.perk!, m.perkValue),
                      ].join('  ·  '),
                      style: TextStyles.dataSmall.copyWith(color: Palette.text),
                    ),
                  ],
                ),
              ),
            ),
            if (trailing != null)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Center(child: SizedBox(width: 96, child: trailing)),
              ),
          ],
        ),
      ),
    );
  }
}
