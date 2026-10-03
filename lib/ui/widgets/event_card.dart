import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../domain/models.dart';
import '../../domain/tiers.dart';
import '../../game/game_controller.dart';
import 'common.dart';

class EventView {
  const EventView(this.title, this.detail, this.action, this.color, this.icon);
  final String title;
  final String detail;
  final String? action;
  final Color color;
  final IconData icon;
}

EventView describeEvent(GameController g, WorldEvent e) {
  final lvl = g.player.level;
  final w = g.world;
  switch (e.type) {
    case EventType.lockdown:
      final c = lockdownCopy(lvl);
      return EventView(c.title, 'Income frozen in the district around ${e.payload['near'] ?? 'your turf'}. Go there in person.',
          c.action, Palette.hostile, Icons.gpp_bad_outlined);
    case EventType.convoy:
      final c = convoyCopy(lvl);
      final bp = e.payload['blueprints'];
      return EventView(c.title, 'Carries $bp blueprint${bp == 1 ? '' : 's'} + ${fmtNum(e.payload['credits'] as num)} cr. Get within 150 m.',
          c.action, Palette.amber, Icons.local_shipping_outlined);
    case EventType.deadDrop:
      final c = deadDropCopy(lvl);
      return EventView(c.title, 'Materials, intel${e.payload['module'] == true ? ' and a module' : ''}. Walk to it.',
          c.action, Palette.ice, Icons.inventory_2_outlined);
    case EventType.surge:
      final b = Biome.fromKey(e.payload['biome'] as String? ?? '');
      return EventView(surgeTitle(b), '${b.label} turfs produce x2.', null, Palette.mint, Icons.trending_up);
    case EventType.market:
      final boom = e.payload['boom'] == true;
      return EventView(boom ? 'Street Price Spike' : 'Market Crash',
          boom ? 'Credit income x1.5.' : 'Credit income x0.6.', null, boom ? Palette.mint : Palette.hostile,
          boom ? Icons.show_chart : Icons.trending_down);
    case EventType.offensive:
      final c = offensiveCopy(lvl);
      final f = w.factionById(e.payload['faction'] as String? ?? '');
      final hub = w.turfs[e.target];
      final fortified = e.payload['fortified'] == true;
      return EventView(
          c.title,
          '${f == null ? 'Rivals' : factionName(f, lvl)} massing on ${hub?.name ?? 'a hub'}.'
          '${fortified ? ' Fortified.' : ' Fortify before it lands.'}',
          fortified ? null : c.action,
          Palette.hostile,
          Icons.crisis_alert);
  }
}

class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.game, required this.event, required this.onLocate});
  final GameController game;
  final WorldEvent event;
  final LocateCallback onLocate;

  /// Where the event is on the map: its own point, or the turf it targets.
  (double, double, String?)? _point() {
    if (event.lat != null && event.lng != null) return (event.lat!, event.lng!, null);
    final t = game.world.turfs[event.target];
    return t == null ? null : (t.lat, t.lng, t.id);
  }

  @override
  Widget build(BuildContext context) {
    final v = describeEvent(game, event);
    final dist = game.actions.eventDistanceM(event, game.lat, game.lng);
    final where = dist == null ? '' : (dist < 20 ? 'HERE' : fmtKm(dist / 1000));
    final q = v.action == null ? null : game.actions.eventQuote(event.id, game.lat, game.lng);
    final point = _point();
    final locatable = point != null && event.type != EventType.market;

    Widget locate() => CommandButton(
          label: 'Locate',
          caption: where.isEmpty ? null : where,
          height: 44,
          filled: false,
          tone: Tone.neutral,
          icon: Icons.my_location,
          onPressed: () => onLocate(point!.$1, point.$2, point.$3),
        );

    return Panel(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      border: v.color.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(v.icon, size: 18, color: v.color),
              const SizedBox(width: 8),
              Expanded(child: Text(v.title, style: TextStyles.title.copyWith(fontSize: 15))),
              Countdown(
                remainingMs: () => event.expiresAt - game.now,
                style: TextStyles.dataSmall.copyWith(color: v.color),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(v.detail, style: TextStyles.bodyDim),
          if (q != null || locatable) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (q != null)
                  Expanded(
                    child: CommandButton(
                      label: q.blocker ?? v.action!,
                      height: 44,
                      tone: v.color == Palette.hostile ? Tone.amber : Tone.mint,
                      cost: q.blocker == null ? q.cost : null,
                      have: game.player,
                      onPressed: q.allowed
                          ? () => game.run((a, now) => a.resolveEvent(event.id, game.lat, game.lng, now))
                          : null,
                    ),
                  ),
                if (q != null && locatable) const SizedBox(width: 8),
                if (locatable)
                  if (q != null) SizedBox(width: 104, child: locate()) else Expanded(child: locate()),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
