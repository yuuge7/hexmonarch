import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../domain/balance.dart';
import '../../domain/tiers.dart';
import '../../game/game_controller.dart';
import '../../platform/location_service.dart';
import '../guide_screen.dart';
import '../widgets/common.dart';

class NetworkPanel extends StatelessWidget {
  const NetworkPanel({super.key, required this.game, required this.onLocate, required this.onTurfList});
  final GameController game;
  final LocateCallback onLocate;
  final VoidCallback onTurfList;

  @override
  Widget build(BuildContext context) {
    return Ticking(
      tick: game.tick,
      builder: (context) {
        final ix = game.index;
        final w = game.world;
        final nets = List.of(ix.networks)..sort((a, b) => b.hubs.length.compareTo(a.hubs.length));
        final heat = game.player.heat;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: [
            Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow('Empire output per hour'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: StatCell('Credits', fmtNum(ix.hourly.credits), color: Palette.amber)),
                      Expanded(child: StatCell('Materials', fmtNum(ix.hourly.materials))),
                      Expanded(child: StatCell('Intel', fmtNum(ix.hourly.intel), color: Palette.ice)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: StatCell('Turfs', fmtNum(ix.owned), sub: '${ix.stations} at stations')),
                      Expanded(
                        child: StatCell('Supplied', '${(ix.suppliedRatio * 100).round()}%',
                            color: ix.suppliedRatio > 0.8 ? Palette.mint : Palette.amber),
                      ),
                      Expanded(child: StatCell('Hubs', '${ix.hubs.length}', color: Palette.amber)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Eyebrow('Rival pressure'),
                      const Spacer(),
                      Text(heat.toStringAsFixed(2),
                          style: TextStyles.dataSmall.copyWith(color: Palette.hostile)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Meter(value: heat / kHeatOffensiveTrigger, color: Palette.hostile, height: 3),
                  const SizedBox(height: 5),
                  Text(
                    'Builds while your turf is quiet and fully supplied. At the red line a rival launches an offensive.',
                    style: TextStyles.bodyDim.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            CommandButton(
              label: 'All my turfs · ${ix.owned}',
              height: 42,
              filled: false,
              icon: Icons.format_list_bulleted,
              onPressed: onTurfList,
            ),
            const SizedBox(height: 12),
            if (nets.isEmpty)
              const Panel(
                child: Text(
                  'No Anchor Hubs yet. Upgrade one of your turfs (a station is ideal) into a hub to supply turfs around it, '
                  'then link distant hubs with relays for the cross-district trade multiplier.',
                  style: TextStyles.bodyDim,
                ),
              ),
            for (final n in nets) ...[
              Panel(
                border: n.relays > 0 ? Palette.amber.withValues(alpha: 0.35) : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Eyebrow(
                            n.relays == 0 ? 'Standalone hub' : 'Relay network · ${n.hubs.length} hubs',
                            color: Palette.amber,
                          ),
                        ),
                        Text('TRADE x${n.trade.toStringAsFixed(2)}',
                            style: TextStyles.dataSmall.copyWith(color: Palette.amber)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${n.districts.length} district${n.districts.length == 1 ? '' : 's'} · ${n.relays} relay${n.relays == 1 ? '' : 's'}',
                        style: TextStyles.dataSmall),
                    const SizedBox(height: 8),
                    for (final id in n.hubs) _HubRow(game: game, id: id, onLocate: onLocate),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 6),
            const Eyebrow('Field ops'),
            const SizedBox(height: 8),
            _Toggle(
              title: 'Patrol mode',
              body: 'Keeps GPS running with the screen off (shows a notification), so auto-plant works while you ride.',
              value: game.patrolMode,
              onChanged: (v) => game.setSetting('patrol', v),
            ),
            _AutoClaimPicker(game: game),
            _Toggle(
              title: 'White map',
              body: 'White basemap with dark markings, readable in direct sunlight. Also the sun button on the map.',
              value: game.sunMap,
              onChanged: (v) => game.setSetting('sunMap', v),
            ),
            _Toggle(
              title: 'Map only',
              body: 'Folds this console away so the main screen is just the map. '
                  'Also the arrow in the console header, or tap the open tab again.',
              value: game.mapOnly,
              onChanged: (v) => game.setSetting('mapOnly', v),
            ),
            _Toggle(
              title: 'Haptics',
              body: 'Tick when you cross a turf border, heavy double pulse on captures.',
              value: game.hapticsOn,
              onChanged: (v) => game.setSetting('haptics', v),
            ),
            const SizedBox(height: 8),
            Panel(
              border: Palette.mint.withValues(alpha: 0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Field manual', style: TextStyles.title.copyWith(fontSize: 14)),
                  const SizedBox(height: 2),
                  Text('What to do first, what the colours mean, how hubs, jobs and perks work.',
                      style: TextStyles.bodyDim.copyWith(fontSize: 12)),
                  const SizedBox(height: 8),
                  CommandButton(
                    label: 'Open the manual',
                    height: 42,
                    filled: false,
                    icon: Icons.menu_book_outlined,
                    onPressed: () => GuideScreen.open(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _SaveTransfer(game: game),
            const SizedBox(height: 8),
            _MapCache(game: game),
            const SizedBox(height: 8),
            _LocationRow(game: game),
            if (kDebugMode) ...[
              const SizedBox(height: 16),
              const Eyebrow('Debug · emulator tools', color: Palette.hostile),
              const SizedBox(height: 6),
              const Text('Long-press the map to teleport the agent.', style: TextStyles.bodyDim),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (final h in const [1, 8, 24]) ...[
                    Expanded(
                      child: CommandButton(
                        label: 'Warp +${h}h',
                        height: 40,
                        filled: false,
                        tone: Tone.hostile,
                        onPressed: () => game.debugWarp(Duration(hours: h)),
                      ),
                    ),
                    if (h != 24) const SizedBox(width: 8),
                  ],
                ],
              ),
              if (game.fakeFix) ...[
                const SizedBox(height: 8),
                CommandButton(label: 'Return to real GPS', height: 40, filled: false, onPressed: game.releaseFakeFix),
              ],
            ],
            const SizedBox(height: 12),
            Text('Tier ${tierFor(game.player.level).index1}: ${tierFor(game.player.level).title}',
                style: TextStyles.label),
            Text('Liquidations ${game.player.liquidations} · world seed ${game.player.worldSeed.toUnsigned(32).toRadixString(16)}',
                style: TextStyles.label.copyWith(color: Palette.textFaint)),
            if (w.player.tamperStrikes > 0)
              Text('Clock anomalies flagged: ${w.player.tamperStrikes}',
                  style: TextStyles.label.copyWith(color: Palette.hostile)),
          ],
        );
      },
    );
  }
}

class _HubRow extends StatelessWidget {
  const _HubRow({required this.game, required this.id, required this.onLocate});
  final GameController game;
  final String id;
  final LocateCallback onLocate;

  @override
  Widget build(BuildContext context) {
    final h = game.world.turfs[id]!;
    final s = game.index.hubs[id]!;
    final target = h.relayTarget == null ? null : game.world.turfs[h.relayTarget];
    return InkWell(
      onTap: () => onLocate(h.lat, h.lng, id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            const Icon(Icons.hexagon_outlined, size: 16, color: Palette.amber),
            const SizedBox(width: 8),
            Expanded(
              child: Text('${h.name} · ${hubClass(h.hubLevel)} ${h.hubLevel}',
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyles.body.copyWith(color: Palette.text)),
            ),
            Text(
              target == null ? fmtKm(s.radiusKm) : '${fmtKm(s.radiusKm)} → ${target.name}',
              style: TextStyles.dataSmall,
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 16, color: Palette.textFaint),
          ],
        ),
      ),
    );
  }
}

/// Off / stations only / everywhere: plants turfs for you while you travel.
class _AutoClaimPicker extends StatelessWidget {
  const _AutoClaimPicker({required this.game});
  final GameController game;

  @override
  Widget build(BuildContext context) {
    final current = game.autoClaim;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Auto-plant while travelling', style: TextStyles.title.copyWith(fontSize: 14)),
            const SizedBox(height: 2),
            Text(
              'Plants a turf the moment you reach free ground and can afford it. '
              '"Stations" only fires at transit stations: ride a line and own every stop. '
              'Turn on Patrol mode to keep it running with the screen off.',
              style: TextStyles.bodyDim.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (final m in AutoClaim.values) ...[
                  if (m != AutoClaim.values.first) const SizedBox(width: 8),
                  Expanded(
                    child: CommandButton(
                      label: m.label,
                      height: 40,
                      filled: m == current,
                      tone: m == current ? Tone.mint : Tone.neutral,
                      onPressed: () => game.setSetting('autoClaim', m.key),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.title, required this.body, required this.value, required this.onChanged});
  final String title;
  final String body;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Panel(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyles.title.copyWith(fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(body, style: TextStyles.bodyDim.copyWith(fontSize: 12)),
                  ],
                ),
              ),
              Switch(value: value, onChanged: onChanged),
            ],
          ),
        ),
      );
}

/// Export / import the whole empire as one file: phone changes and backups.
class _SaveTransfer extends StatelessWidget {
  const _SaveTransfer({required this.game});
  final GameController game;

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Move to another phone', style: TextStyles.title.copyWith(fontSize: 14)),
          const SizedBox(height: 2),
          Text(
            'Your empire lives only on this phone. Export it to a file (Drive works well), '
            'then import that file on the new phone. Also a good backup.',
            style: TextStyles.bodyDim.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: CommandButton(
                  label: 'Export save',
                  height: 42,
                  icon: Icons.upload_file_outlined,
                  onPressed: game.exportSave,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CommandButton(
                  label: 'Hold to import',
                  height: 42,
                  filled: false,
                  tone: Tone.hostile,
                  holdToConfirm: true,
                  onPressed: game.importSave,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Importing replaces the empire on this phone.',
              style: TextStyles.label.copyWith(color: Palette.textFaint, letterSpacing: 0.8)),
        ],
      ),
    );
  }
}

class _MapCache extends StatefulWidget {
  const _MapCache({required this.game});
  final GameController game;

  @override
  State<_MapCache> createState() => _MapCacheState();
}

class _MapCacheState extends State<_MapCache> {
  (int, int)? _stats;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final s = await widget.game.tiles.stats();
    if (mounted) setState(() => _stats = s);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<(int, int)?>(
      valueListenable: widget.game.cacheProgress,
      builder: (context, prog, _) {
        final s = _stats;
        return Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Offline map', style: TextStyles.title.copyWith(fontSize: 14)),
              const SizedBox(height: 2),
              Text(
                s == null ? 'Measuring cache…' : '${s.$1} vector tiles stored · ${(s.$2 / 1048576).toStringAsFixed(1)} MB',
                style: TextStyles.dataSmall,
              ),
              const SizedBox(height: 8),
              if (prog != null) ...[
                Meter(value: prog.$2 == 0 ? 0 : prog.$1 / prog.$2, color: Palette.ice),
                const SizedBox(height: 4),
                Text('Downloading ${prog.$1}/${prog.$2}', style: TextStyles.dataSmall),
              ] else
                CommandButton(
                  label: 'Cache 5 km around me',
                  height: 42,
                  filled: false,
                  tone: Tone.mint,
                  icon: Icons.download_for_offline_outlined,
                  onPressed: widget.game.lat == null
                      ? null
                      : () async {
                          await widget.game.cacheMapArea();
                          await _refresh();
                        },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({required this.game});
  final GameController game;

  @override
  Widget build(BuildContext context) {
    final st = game.location.status;
    final label = switch (st) {
      LocStatus.active => 'GPS locked${game.accuracy == null ? '' : ' · ±${game.accuracy!.round()} m'}',
      LocStatus.searching => 'Searching for GPS fix',
      LocStatus.denied => 'Location permission denied',
      LocStatus.deniedForever => 'Location blocked in settings',
      LocStatus.serviceOff => 'Location services off',
      LocStatus.unknown => 'Location not started',
    };
    final ok = st == LocStatus.active;
    return Panel(
      child: Row(
        children: [
          Icon(ok ? Icons.gps_fixed : Icons.gps_off, size: 18, color: ok ? Palette.mint : Palette.amber),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: TextStyles.body)),
          if (!ok)
            SizedBox(
              width: 100,
              child: CommandButton(
                label: 'Fix',
                height: 36,
                filled: false,
                onPressed: () => st == LocStatus.deniedForever
                    ? game.location.openSettings()
                    : game.retryLocation(),
              ),
            ),
        ],
      ),
    );
  }
}
