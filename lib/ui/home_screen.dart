import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:latlong2/latlong.dart' show LatLng;

import '../core/theme.dart';
import '../domain/actions.dart';
import '../domain/models.dart';
import '../game/game_controller.dart';
import '../platform/location_service.dart';
import 'hud.dart';
import 'map/tactical_map.dart';
import 'panels/crew_panel.dart';
import 'panels/network_panel.dart';
import 'panels/ops_panel.dart';
import 'panels/turf_panel.dart';
import 'panels/vault_panel.dart';
import 'report_sheet.dart';
import 'turf_list_screen.dart';
import 'widgets/common.dart';

enum ConsoleTab {
  turf('Turf', Icons.hexagon_outlined),
  network('Network', Icons.hub_outlined),
  crew('Crew', Icons.groups_outlined),
  ops('Ops', Icons.radar),
  vault('Vault', Icons.key_outlined);

  const ConsoleTab(this.label, this.icon);
  final String label;
  final IconData icon;
}

const _kHeaderH = 44.0;
const _kTabBarH = 60.0;

/// Portrait split: 55% tactical map (read-only HUD on top), 45% command
/// console holding every control within thumb reach. In map-only mode the
/// console folds down to its header and tab bar and the map takes the rest.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.game});
  final GameController game;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _mapCtl = TacticalMapController();
  ConsoleTab _tab = ConsoleTab.turf;
  StreamSubscription<Outcome>? _toasts;
  double _consoleH = 0;

  GameController get game => widget.game;

  @override
  void initState() {
    super.initState();
    _toasts = game.toasts.stream.listen((o) {
      if (mounted) showOutcome(context, o, above: _consoleH);
    });
    game.addListener(_maybeReport);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeReport());
  }

  @override
  void dispose() {
    _toasts?.cancel();
    game.removeListener(_maybeReport);
    _mapCtl.dispose();
    super.dispose();
  }

  void _maybeReport() {
    final r = game.pendingReport;
    if (r == null || !mounted) return;
    game.pendingReport = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) showReport(context, r);
    });
  }

  void _setMapOnly(bool v) {
    if (v != game.mapOnly) unawaited(game.setSetting('mapOnly', v));
  }

  void _locate(double lat, double lng, String? turfId) {
    if (turfId != null) game.select(turfId);
    _mapCtl.focus(LatLng(lat, lng));
    if (turfId != null) {
      setState(() => _tab = ConsoleTab.turf);
      _setMapOnly(false);
    }
  }

  /// In map-only mode a tap just marks the turf (its name shows in the
  /// header); the console stays folded until the player opens it.
  void _onTurfTap(String? turfId) {
    game.select(turfId);
    if (game.mapOnly) return;
    if (turfId != null && _tab != ConsoleTab.turf && _tab != ConsoleTab.crew) {
      setState(() => _tab = ConsoleTab.turf);
    }
  }

  /// Open ground becomes the plant target. Without a GPS fix there is no range
  /// to plant from, so the tap just returns the console to where you stand.
  /// Map-only mode has no plant button, so there the tap only clears.
  void _onGroundTap(double lat, double lng) {
    if (game.lat != null && !game.mapOnly) {
      game.pickGround(lat, lng);
      if (_tab != ConsoleTab.turf) setState(() => _tab = ConsoleTab.turf);
    } else {
      game.select(null);
    }
  }

  void _onTab(ConsoleTab t) {
    // Tapping the open tab folds the console away; any tab opens it again.
    if (!game.mapOnly && t == _tab) {
      _setMapOnly(true);
    } else {
      setState(() => _tab = t);
      _setMapOnly(false);
    }
  }

  void _openTurfList() => TurfListScreen.open(context, game, onPick: (t) => _locate(t.lat, t.lng, t.id));

  @override
  Widget build(BuildContext context) {
    // Status bar icons sit over the map: dark ones on the white map.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: game.sunMap
          ? kDarkBars.copyWith(statusBarIconBrightness: Brightness.dark, statusBarBrightness: Brightness.light)
          : kDarkBars,
      child: _screen(),
    );
  }

  Widget _screen() {
    return Scaffold(
      backgroundColor: Palette.carbon,
      body: LayoutBuilder(
        builder: (context, c) {
          final openH = c.maxHeight * 0.45;
          final foldedH = _kHeaderH + _kTabBarH + MediaQuery.paddingOf(context).bottom;
          final mapOnly = game.mapOnly;
          _consoleH = mapOnly ? foldedH : openH;
          return Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: TacticalMap(
                        game: game,
                        onTurfTap: _onTurfTap,
                        onGroundTap: _onGroundTap,
                        controller: _mapCtl,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(bottom: false, child: Hud(game: game)),
                    ),
                    Positioned(
                      right: 10,
                      bottom: 34,
                      child: _MapControls(game: game, map: _mapCtl),
                    ),
                    // Soft fade into the console.
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 28,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Palette.slate.withValues(alpha: 0), Palette.slate.withValues(alpha: 0.9)],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                height: _consoleH,
                child: _console(mapOnly, openH - foldedH),
              ),
            ],
          );
        },
      ),
    );
  }

  /// [panelH] is the height of the open panel. The panel is always laid out
  /// at that height and clipped, so nothing overflows while the console folds.
  Widget _console(bool mapOnly, double panelH) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Palette.slate,
        border: Border(top: BorderSide(color: Palette.mint.withValues(alpha: 0.25))),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            _ConsoleHeader(game: game, folded: mapOnly, onFold: () => _setMapOnly(!mapOnly), onTurfList: _openTurfList),
            Expanded(
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.topCenter,
                  minHeight: panelH,
                  maxHeight: panelH,
                  child: ExcludeSemantics(
                    excluding: mapOnly,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 160),
                      child: KeyedSubtree(key: ValueKey(_tab), child: _panel()),
                    ),
                  ),
                ),
              ),
            ),
            _TabBar(game: game, current: mapOnly ? null : _tab, onSelect: _onTab),
          ],
        ),
      ),
    );
  }

  Widget _panel() => switch (_tab) {
    ConsoleTab.turf => ListenableBuilder(
      listenable: game,
      builder: (_, _) => TurfPanel(game: game, onLocate: _locate),
    ),
    ConsoleTab.network => ListenableBuilder(
      listenable: game,
      builder: (_, _) => NetworkPanel(game: game, onLocate: _locate, onTurfList: _openTurfList),
    ),
    ConsoleTab.crew => ListenableBuilder(
      listenable: game,
      builder: (_, _) => CrewPanel(game: game),
    ),
    ConsoleTab.ops => OpsPanel(game: game, onLocate: _locate),
    ConsoleTab.vault => VaultPanel(game: game),
  };
}

class _ConsoleHeader extends StatelessWidget {
  const _ConsoleHeader({required this.game, required this.folded, required this.onFold, required this.onTurfList});
  final GameController game;

  /// Map-only mode: the console shows this strip and the tab bar, no panel.
  final bool folded;
  final VoidCallback onFold;
  final VoidCallback onTurfList;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: game,
      builder: (context, _) {
        final st = game.location.status;
        final live = st == LocStatus.active;
        final sel = game.selected == null ? null : game.world.turfById(game.selected!);
        final String text;
        if (sel != null) {
          text = 'INSPECTING · ${sel.isPlayer ? sel.name : 'RIVAL TURF'}';
        } else if (game.hasPick) {
          text = 'PLANT TARGET · ${game.turfIdentity(game.pickPlace).$1 ?? 'open ground'}';
        } else if (game.lat != null) {
          final place = game.herePlace?.name;
          text =
              '${live ? 'LIVE' : 'LAST FIX'}${place == null ? '' : ' · $place'}'
              '${game.accuracy != null && live ? ' · ±${game.accuracy!.round()}m' : ''}';
        } else {
          text = 'NO FIX';
        }
        return SizedBox(
          height: _kHeaderH,
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 6),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: live ? Palette.mint : Palette.amber,
                    boxShadow: [BoxShadow(color: live ? Palette.mint : Palette.amber, blurRadius: 6)],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  // Folded: the strip itself opens the console again.
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: folded ? onFold : null,
                    child: SizedBox(
                      height: _kHeaderH,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          text.toUpperCase(),
                          style: TextStyles.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
                if (game.selected != null || game.hasPick)
                  _IconBtn(icon: Icons.close, tip: 'Back to my position', onTap: () => game.select(null)),
                _IconBtn(icon: Icons.format_list_bulleted, tip: 'All my turfs', onTap: onTurfList),
                _IconBtn(
                  icon: folded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  tip: folded ? 'Open the console' : 'Map only',
                  active: folded,
                  onTap: onFold,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// View controls that float on the map: sunlight style, frame the empire,
/// follow me. They sit just above the console, still in thumb reach.
class _MapControls extends StatelessWidget {
  const _MapControls({required this.game, required this.map});
  final GameController game;
  final TacticalMapController map;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([game, map]),
      builder: (context, _) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MapBtn(
            icon: game.sunMap ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            tip: game.sunMap ? 'Dark map' : 'White map for sunlight',
            active: game.sunMap,
            onTap: () => game.setSetting('sunMap', !game.sunMap),
          ),
          const SizedBox(height: 8),
          _MapBtn(icon: Icons.center_focus_strong_outlined, tip: 'Frame my empire', onTap: map.frameEmpire),
          const SizedBox(height: 8),
          _MapBtn(
            icon: map.follow ? Icons.my_location : Icons.location_searching,
            tip: 'Follow me',
            active: map.follow,
            onTap: () {
              game.select(null);
              map.recenter();
            },
          ),
        ],
      ),
    );
  }
}

class _MapBtn extends StatelessWidget {
  const _MapBtn({required this.icon, required this.tip, required this.onTap, this.active = false});
  final IconData icon;
  final String tip;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tip,
    child: Semantics(
      button: true,
      label: tip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: ShapeDecoration(
            color: Palette.carbon.withValues(alpha: 0.86),
            shape: chamfer(8, active ? Palette.mint.withValues(alpha: 0.7) : Palette.line),
          ),
          child: Icon(icon, size: 20, color: active ? Palette.mint : Palette.text),
        ),
      ),
    ),
  );
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.tip, required this.onTap, this.active = false});
  final IconData icon;
  final String tip;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onTap,
    tooltip: tip,
    icon: Icon(icon, size: 20, color: active ? Palette.mint : Palette.textDim),
    visualDensity: VisualDensity.compact,
  );
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.game, required this.current, required this.onSelect});
  final GameController game;

  /// Null while the console is folded: no panel is showing.
  final ConsoleTab? current;
  final ValueChanged<ConsoleTab> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: game,
      builder: (context, _) {
        final hot = game.world.events.where((e) => e.type != EventType.surge && e.type != EventType.market).length;
        return Container(
          height: _kTabBarH,
          decoration: const BoxDecoration(
            color: Palette.carbon,
            border: Border(top: BorderSide(color: Palette.line)),
          ),
          child: Row(
            children: [
              for (final t in ConsoleTab.values)
                Expanded(
                  child: _Tab(
                    tab: t,
                    selected: t == current,
                    badge: t == ConsoleTab.ops && hot > 0
                        ? '$hot'
                        : (t == ConsoleTab.crew && game.world.stash.isNotEmpty ? '${game.world.stash.length}' : null),
                    onTap: () => onSelect(t),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.tab, required this.selected, required this.onTap, this.badge});
  final ConsoleTab tab;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final c = selected ? Palette.mint : Palette.textDim;
    return Semantics(
      selected: selected,
      button: true,
      label: tab.label,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: selected ? 28 : 0,
                height: 2,
                decoration: BoxDecoration(
                  color: Palette.mint,
                  boxShadow: [BoxShadow(color: Palette.mint.withValues(alpha: 0.7), blurRadius: 8)],
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(tab.icon, size: 21, color: c),
                const SizedBox(height: 3),
                Text(tab.label.toUpperCase(), style: TextStyles.label.copyWith(color: c, fontSize: 9)),
              ],
            ),
            if (badge != null)
              Positioned(
                top: 8,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  color: tab == ConsoleTab.ops ? Palette.amber : Palette.slateHi,
                  child: Text(
                    badge!,
                    style: TextStyles.label.copyWith(
                      color: tab == ConsoleTab.ops ? Palette.carbon : Palette.text,
                      fontSize: 8.5,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
