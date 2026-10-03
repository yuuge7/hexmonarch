import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:vector_map_tiles/vector_map_tiles.dart';

import '../../core/theme.dart';
import '../../domain/balance.dart';
import '../../domain/models.dart';
import '../../game/game_controller.dart';
import '../../geo/hex_grid.dart';
import '../../platform/tile_cache.dart';

/// Lets the console recenter / frame the map without owning it.
class TacticalMapController extends ChangeNotifier {
  bool follow = true;
  _TacticalMapState? _state;

  void release() {
    follow = false;
    notifyListeners();
  }

  void recenter() {
    follow = true;
    _state?._recenter(animateZoom: true);
    notifyListeners();
  }

  void focus(LatLng p, {double? zoom}) {
    follow = false;
    _state?._moveTo(p, zoom);
    notifyListeners();
  }

  void frameEmpire() {
    follow = false;
    _state?._frameEmpire();
    notifyListeners();
  }
}

/// Turf Wars-style map: every territory is a circle zone around the exact
/// spot it was planted on, drawn over a monochrome vector basemap.
class TacticalMap extends StatefulWidget {
  const TacticalMap({
    super.key,
    required this.game,
    required this.onTurfTap,
    required this.onGroundTap,
    required this.controller,
  });
  final GameController game;
  final void Function(String? turfId) onTurfTap;

  /// Tap on open ground (no turf under the finger).
  final void Function(double lat, double lng) onGroundTap;
  final TacticalMapController controller;

  @override
  State<TacticalMap> createState() => _TacticalMapState();
}

class _TacticalMapState extends State<TacticalMap> with SingleTickerProviderStateMixin {
  final _map = MapController();
  late final _fx = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();
  late final _tileProviders = TileProviders({'openmaptiles': OfflineVectorProvider(widget.game.tiles)});
  final _visible = _VisibleTurfs();
  bool _ready = false;
  double? _lastLat, _lastLng;
  late bool _sun = game.sunMap;

  GameController get game => widget.game;

  @override
  void initState() {
    super.initState();
    widget.controller._state = this;
    game.addListener(_onGame);
  }

  @override
  void dispose() {
    game.removeListener(_onGame);
    widget.controller._state = null;
    _fx.dispose();
    super.dispose();
  }

  void _onGame() {
    // Basemap style flipped (dark / sunlight white): rebuild the tile layer.
    if (game.sunMap != _sun) setState(() => _sun = game.sunMap);
    if (!_ready || game.lat == null) return;
    if (widget.controller.follow && (game.lat != _lastLat || game.lng != _lastLng)) {
      // First fix of the session: drop from the world view to street level.
      final first = _lastLat == null || _map.camera.zoom < 11;
      _lastLat = game.lat;
      _lastLng = game.lng;
      _recenter(animateZoom: first);
    }
  }

  void _recenter({bool animateZoom = false}) {
    if (!_ready || game.lat == null) return;
    final z = animateZoom ? math.max(_map.camera.zoom, 15.5) : _map.camera.zoom;
    _map.move(LatLng(game.lat!, game.lng!), z);
  }

  void _moveTo(LatLng p, double? zoom) {
    if (!_ready) return;
    _map.move(p, zoom ?? math.max(_map.camera.zoom, 15.5));
  }

  void _frameEmpire() {
    if (!_ready) return;
    final pts = [for (final t in game.world.playerTurfs) LatLng(t.lat, t.lng)];
    if (game.lat != null) pts.add(LatLng(game.lat!, game.lng!));
    if (pts.isEmpty) return;
    if (pts.length == 1) {
      _map.move(pts.first, 15.5);
      return;
    }
    _map.fitCamera(CameraFit.bounds(
      bounds: LatLngBounds.fromPoints(pts),
      padding: const EdgeInsets.all(56),
      maxZoom: 16.5,
    ));
  }

  void _onTap(LatLng p) {
    final mpp = _metersPerPixel(_map.camera);
    final reach = math.max(220.0, 30 * mpp);
    Turf? hit;
    var best = double.infinity;
    for (final t in game.world.turfsNear(p.latitude, p.longitude, reach)) {
      final d = metersBetween(p.latitude, p.longitude, t.lat, t.lng);
      final grab = math.max(turfRadiusM(t), 26 * mpp);
      if (d <= grab && d < best) {
        best = d;
        hit = t;
      }
    }
    if (hit != null) {
      widget.onTurfTap(hit.id);
    } else {
      widget.onGroundTap(p.latitude, p.longitude);
    }
  }

  @override
  Widget build(BuildContext context) {
    final start = game.lat == null ? const LatLng(20, 0) : LatLng(game.lat!, game.lng!);
    final ink = game.ink;
    return FlutterMap(
      mapController: _map,
      options: MapOptions(
        initialCenter: start,
        initialZoom: game.lat == null ? 3 : 15.5,
        minZoom: 3,
        maxZoom: 18.5,
        backgroundColor: ink.ground,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
        onMapReady: () {
          _ready = true;
          _lastLat = game.lat;
          _lastLng = game.lng;
        },
        onPositionChanged: (camera, hasGesture) {
          if (hasGesture && widget.controller.follow) widget.controller.release();
        },
        onTap: (_, p) => _onTap(p),
        onLongPress: kDebugMode ? (_, p) => game.teleport(p.latitude, p.longitude) : null,
      ),
      children: [
        VectorTileLayer(
          key: ValueKey(game.mapTheme.id),
          tileProviders: _tileProviders,
          theme: game.mapTheme,
          layerMode: VectorTileLayerMode.vector,
          maximumZoom: 18.5,
          fileCacheTtl: const Duration(days: 3650),
          concurrency: 4,
        ),
        ListenableBuilder(
          listenable: game,
          builder: (context, _) => _TurfLayer(game: game, visible: _visible),
        ),
        _FxLayer(game: game, fx: _fx),
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
            child: Text('© OpenStreetMap contributors · OpenMapTiles · OpenFreeMap',
                style: TextStyle(fontFamily: Fonts.mono, fontSize: 8.5, color: ink.light ? ink.dim : Palette.textFaint)),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- geometry

double _metersPerPixel(MapCamera cam) =>
    156543.03392 * math.cos(cam.center.latitude * math.pi / 180) / math.pow(2, cam.zoom);

Path _dashed(Path source, double dash, double gap, [double phase = 0]) {
  final out = Path();
  for (final m in source.computeMetrics()) {
    var d = -phase % (dash + gap);
    while (d < m.length) {
      final s = math.max(0.0, d);
      final e = math.min(m.length, d + dash);
      if (e > s) out.addPath(m.extractPath(s, e), Offset.zero);
      d += dash + gap;
    }
  }
  return out;
}

Path _ring(MapCamera cam, List<LatLng> ring) {
  final path = Path();
  for (var i = 0; i < ring.length; i++) {
    final o = cam.latLngToScreenOffset(ring[i]);
    i == 0 ? path.moveTo(o.dx, o.dy) : path.lineTo(o.dx, o.dy);
  }
  return path..close();
}

Path _hexGlyph(Offset c, double r) {
  final p = Path();
  for (var i = 0; i < 6; i++) {
    final a = math.pi / 6 + i * math.pi / 3;
    final o = c + Offset(math.cos(a), math.sin(a)) * r;
    i == 0 ? p.moveTo(o.dx, o.dy) : p.lineTo(o.dx, o.dy);
  }
  return p..close();
}

/// Turfs worth drawing: persisted ones in view, plus day-one rival turfs for
/// the blocks around the camera (memoised per block window, not per frame).
class _VisibleTurfs {
  String? _block;
  int _k = -1;
  int _seed = 0;
  List<String> _blocks = const [];

  List<Turf> collect(GameController g, MapCamera cam, Size size) {
    final w = g.world;
    final out = <Turf>[];
    final b = cam.visibleBounds;
    const padLat = 0.0025, padLng = 0.004;
    for (final t in w.turfs.values) {
      if (t.lat >= b.south - padLat && t.lat <= b.north + padLat && t.lng >= b.west - padLng && t.lng <= b.east + padLng) {
        out.add(t);
      }
    }
    final halfDiag = math.sqrt(size.width * size.width + size.height * size.height) / 2;
    final k = (halfDiag * _metersPerPixel(cam) / 300).ceil() + 1;
    if (k <= 20) {
      final block = g.grid.cellAt(cam.center.latitude, cam.center.longitude, kPlayRes);
      if (block != _block || k != _k || _seed != w.player.worldSeed) {
        _block = block;
        _k = k;
        _seed = w.player.worldSeed;
        _blocks = g.grid.disk(block, k);
      }
      for (final bl in _blocks) {
        final p = w.presetRival(bl);
        if (p != null) out.add(p);
      }
    }
    return out;
  }
}

// ---------------------------------------------------------------- static layer

class _TurfLayer extends StatelessWidget {
  const _TurfLayer({required this.game, required this.visible});
  final GameController game;
  final _VisibleTurfs visible;

  @override
  Widget build(BuildContext context) {
    final cam = MapCamera.of(context);
    return IgnorePointer(
      child: CustomPaint(size: Size.infinite, painter: _TurfPainter(game, cam, visible)),
    );
  }
}

class _TurfPainter extends CustomPainter {
  _TurfPainter(this.g, this.cam, this.visible);
  final GameController g;
  final MapCamera cam;
  final _VisibleTurfs visible;

  @override
  void paint(Canvas canvas, Size size) {
    final w = g.world;
    final ix = w.index;
    final zoom = cam.zoom;
    final mpp = _metersPerPixel(cam);
    final k = g.ink;
    // Fill and line opacity: the sunlight map needs both heavier.
    double fa(double a) => math.min(1.0, a * k.fill);
    double la(double a) => k.light ? math.min(1.0, a + 0.3) : a;

    // Hub supply spheres ---------------------------------------------------
    for (final s in ix.hubs.values) {
      final c = cam.latLngToScreenOffset(LatLng(s.hub.lat, s.hub.lng));
      final r = s.radiusKm * 1000 / mpp;
      if (r < 6) continue;
      final circle = Path()..addOval(Rect.fromCircle(center: c, radius: r));
      canvas.drawPath(circle, Paint()..color = k.hub.withValues(alpha: fa(0.035)));
      canvas.drawPath(
        _dashed(circle, 7, 6),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2 + k.stroke
          ..color = k.hub.withValues(alpha: la(0.5)),
      );
    }

    // Locked-down districts ---------------------------------------------------
    for (final e in w.events) {
      if (e.type != EventType.lockdown || e.district == null) continue;
      final dp = _ring(cam, g.grid.boundary(e.district!));
      // No wash on the sunlight map: it would turn a whole white district pink.
      if (!k.light) canvas.drawPath(dp, Paint()..color = k.hostile.withValues(alpha: 0.05));
      canvas.drawPath(
        _dashed(dp, 10, 6),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 + k.stroke
          ..color = k.hostile.withValues(alpha: la(0.6)),
      );
    }

    // Relay spines ------------------------------------------------------------
    final relayPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4 + k.stroke
      ..color = k.hub.withValues(alpha: la(0.6));
    for (final s in ix.hubs.values) {
      final target = s.hub.relayTarget == null ? null : ix.hubs[s.hub.relayTarget];
      if (target == null) continue;
      final a = cam.latLngToScreenOffset(LatLng(s.hub.lat, s.hub.lng));
      final b = cam.latLngToScreenOffset(LatLng(target.hub.lat, target.hub.lng));
      canvas.drawPath(
        _dashed(Path()
          ..moveTo(a.dx, a.dy)
          ..lineTo(b.dx, b.dy), 8, 5),
        relayPaint,
      );
    }

    // Turf zones --------------------------------------------------------------
    final rival = Path();
    final supplied = Path();
    final orphan = Path();
    final hubs = Path();
    final stationRings = Path();
    final glyphs = <(Offset, Turf)>[];

    for (final t in visible.collect(g, cam, size)) {
      final c = cam.latLngToScreenOffset(LatLng(t.lat, t.lng));
      final r = math.max(3.0, turfRadiusM(t) / mpp);
      final oval = Rect.fromCircle(center: c, radius: r);
      if (t.isPlayer) {
        if (t.isHub) {
          hubs.addOval(oval);
        } else if (ix.supplier.containsKey(t.id)) {
          supplied.addOval(oval);
        } else {
          orphan.addOval(oval);
        }
        if (t.isStation && r > 10) stationRings.addOval(Rect.fromCircle(center: c, radius: r * 0.62));
      } else if (t.isHostile) {
        rival.addOval(oval);
      }
      glyphs.add((c, t));
    }

    canvas.drawPath(rival, Paint()..color = k.hostile.withValues(alpha: fa(0.13)));
    canvas.drawPath(
      rival,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3 + k.stroke
        ..color = k.hostile.withValues(alpha: la(0.75)),
    );

    // Neon glow only reads on the dark map; on white it turns to smudge.
    if (!k.light) {
      canvas.drawPath(
        supplied,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
          ..color = k.mine.withValues(alpha: 0.4),
      );
    }
    canvas.drawPath(supplied, Paint()..color = k.mine.withValues(alpha: fa(0.14)));
    canvas.drawPath(
      supplied,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 + k.stroke
        ..color = k.mine.withValues(alpha: la(0.9)),
    );

    canvas.drawPath(orphan, Paint()..color = k.mine.withValues(alpha: fa(0.06)));
    canvas.drawPath(
      _dashed(orphan, 5, 4),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3 + k.stroke
        ..color = k.mine.withValues(alpha: la(0.7)),
    );

    if (!k.light) {
      canvas.drawPath(
        hubs,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
          ..color = k.hub.withValues(alpha: 0.5),
      );
    }
    canvas.drawPath(hubs, Paint()..color = k.hub.withValues(alpha: fa(0.18)));
    canvas.drawPath(
      hubs,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.9 + k.stroke
        ..color = k.hub,
    );

    // Station turfs carry an inner ring: the transit backbone.
    canvas.drawPath(
      stationRings,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1 + k.stroke / 2
        ..color = k.ink.withValues(alpha: la(0.55)),
    );

    // Center glyphs + labels -----------------------------------------------
    final showNames = zoom >= 15;
    for (final (c, t) in glyphs) {
      final color = t.isPlayer ? (t.isHub ? k.hub : k.mine) : k.hostile;
      final gr = t.isHub ? 6.5 : 4.5;
      final glyph = _hexGlyph(c, gr);
      canvas.drawPath(glyph, Paint()..color = k.ground);
      canvas.drawPath(
        glyph,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 + k.stroke / 2
          ..color = color,
      );
      if (t.isHub) canvas.drawCircle(c, 1.8, Paint()..color = color);
      if (t.isPlayer && (showNames || (t.isHub && zoom >= 12.5))) {
        final label = t.isHub ? '${t.name} · H${t.hubLevel}' : t.name;
        _label(canvas, c + Offset(0, gr + 9), label.toUpperCase(), color, k.ground);
      }
    }
  }

  void _label(Canvas canvas, Offset at, String text, Color c, Color halo) {
    final tp = TextPainter(
      text: TextSpan(
        text: text.length > 22 ? '${text.substring(0, 21)}…' : text,
        style: TextStyle(
          fontFamily: Fonts.mono,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: c,
          shadows: [Shadow(color: halo, blurRadius: 4), Shadow(color: halo, blurRadius: 2)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_TurfPainter old) => true;
}

// ---------------------------------------------------------------- fx layer

class _FxLayer extends StatelessWidget {
  const _FxLayer({required this.game, required this.fx});
  final GameController game;
  final Animation<double> fx;

  @override
  Widget build(BuildContext context) {
    final cam = MapCamera.of(context);
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(size: Size.infinite, painter: _FxPainter(game, cam, fx)),
      ),
    );
  }
}

class _FxPainter extends CustomPainter {
  _FxPainter(this.g, this.cam, this.fx) : super(repaint: Listenable.merge([fx, g]));
  final GameController g;
  final MapCamera cam;
  final Animation<double> fx;

  @override
  void paint(Canvas canvas, Size size) {
    final t = fx.value;
    final w = g.world;
    final ix = w.index;
    final mpp = _metersPerPixel(cam);
    final pulse = 0.5 + 0.5 * math.sin(t * math.pi * 2);
    final k = g.ink;

    // Relay packets.
    final packet = Paint()..color = k.hub;
    final halo = Paint()
      ..color = k.hub.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    for (final s in ix.hubs.values) {
      final target = s.hub.relayTarget == null ? null : ix.hubs[s.hub.relayTarget];
      if (target == null) continue;
      final a = cam.latLngToScreenOffset(LatLng(s.hub.lat, s.hub.lng));
      final b = cam.latLngToScreenOffset(LatLng(target.hub.lat, target.hub.lng));
      for (var i = 0; i < 3; i++) {
        final f = (t + i / 3) % 1.0;
        final p = Offset.lerp(a, b, f)!;
        canvas.drawCircle(p, 5, halo);
        canvas.drawCircle(p, 2.2, packet);
      }
    }

    // Events.
    for (final e in w.events) {
      Offset? c;
      if (e.lat != null && e.lng != null) {
        c = cam.latLngToScreenOffset(LatLng(e.lat!, e.lng!));
      } else {
        final turf = w.turfs[e.target];
        if (turf != null) c = cam.latLngToScreenOffset(LatLng(turf.lat, turf.lng));
      }
      if (c == null) continue;
      switch (e.type) {
        case EventType.convoy:
          _rangeRing(canvas, c, g.actions.eventRangeM(EventType.convoy) / mpp, k.hub);
          _diamond(canvas, c, 7 + 2 * pulse, k.hub, t * math.pi * 2);
        case EventType.deadDrop:
          _rangeRing(canvas, c, g.actions.eventRangeM(EventType.deadDrop) / mpp, k.intel);
          _diamond(canvas, c, 6 + 2 * pulse, k.intel, 0);
        case EventType.offensive:
          final r = 22 + 8 * pulse;
          canvas.drawCircle(
            c,
            r,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5 + k.stroke
              ..color = k.hostile.withValues(alpha: 0.9 - 0.5 * pulse),
          );
          _ticks(canvas, c, r + 5, k.hostile);
        default:
          break;
      }
    }

    // Selected turf reticle.
    final sel = g.selected == null ? null : w.turfById(g.selected!);
    if (sel != null) {
      final c = cam.latLngToScreenOffset(LatLng(sel.lat, sel.lng));
      final r = math.max(9.0, turfRadiusM(sel) / mpp) + 4;
      canvas.drawPath(
        _dashed(Path()..addOval(Rect.fromCircle(center: c, radius: r)), 6, 4, t * 20),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 + k.stroke / 2
          ..color = k.ink,
      );
    }

    // The zone you are standing in.
    final here = g.hereZone == null ? null : w.turfById(g.hereZone!);
    if (here != null) {
      final c = cam.latLngToScreenOffset(LatLng(here.lat, here.lng));
      final r = math.max(6.0, turfRadiusM(here) / mpp);
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..color = (here.isHostile ? k.hostile : (here.isHub ? k.hub : k.mine))
              .withValues(alpha: 0.35 + 0.65 * pulse),
      );
    }

    if (g.lat != null) {
      final p = cam.latLngToScreenOffset(LatLng(g.lat!, g.lng!));

      // Plant range: any open ground inside this ring can be planted by
      // tapping it. The dimmed patches are the no-plant gap around turfs.
      final rangePx = w.perks.plantRangeM / mpp;
      final gapPx = w.perks.spacingM / mpp;
      if (rangePx >= 10) {
        if (gapPx >= 6 && g.blockers.isNotEmpty) {
          final gaps = Path();
          for (final b in g.blockers) {
            gaps.addOval(Rect.fromCircle(center: cam.latLngToScreenOffset(LatLng(b.lat, b.lng)), radius: gapPx));
          }
          canvas.save();
          canvas.clipPath(Path()..addOval(Rect.fromCircle(center: p, radius: rangePx)));
          canvas.drawPath(gaps, Paint()..color = k.shade);
          canvas.drawPath(
            _dashed(gaps, 2, 5),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1 + k.stroke / 2
              ..color = k.dim.withValues(alpha: k.light ? 0.85 : 0.55),
          );
          canvas.restore();
        }
        _rangeRing(canvas, p, rangePx, k.mine);
      }

      // Picked spot for a remote plant.
      if (g.hasPick) {
        final q = g.actions.claimQuote(g.pickLat!, g.pickLng!, fromLat: g.lat, fromLng: g.lng);
        final c = cam.latLngToScreenOffset(LatLng(g.pickLat!, g.pickLng!));
        final color = q.blocker == null ? k.mine : k.hub;
        final r = math.max(8.0, kTurfBaseRadiusM / mpp);
        final spot = Path()..addOval(Rect.fromCircle(center: c, radius: r));
        canvas.drawPath(spot, Paint()..color = color.withValues(alpha: (0.06 + 0.06 * pulse) * k.fill));
        canvas.drawPath(
          _dashed(spot, 4, 5, -t * 18),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6 + k.stroke
            ..color = color,
        );
        _ticks(canvas, c, 3, color);
        canvas.drawLine(
          p,
          c,
          Paint()
            ..strokeWidth = 1 + k.stroke / 2
            ..color = color.withValues(alpha: k.light ? 0.6 : 0.35),
        );
      }

      // Ghost turf: where a new turf would land if you plant right now.
      if (g.plantable && !g.hasPick) {
        final r = math.max(8.0, kTurfBaseRadiusM / mpp);
        final ghost = Path()..addOval(Rect.fromCircle(center: p, radius: r));
        canvas.drawPath(ghost, Paint()..color = k.mine.withValues(alpha: (0.04 + 0.05 * pulse) * k.fill));
        canvas.drawPath(
          _dashed(ghost, 4, 5, -t * 18),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4 + k.stroke
            ..color = k.mine.withValues(alpha: 0.55 + 0.4 * pulse),
        );
      }

      final acc = (g.accuracy ?? 0) / mpp;
      if (acc > 10) {
        canvas.drawCircle(p, acc, Paint()..color = k.ink.withValues(alpha: 0.04 * k.fill));
      }
      canvas.drawCircle(
        p,
        9 + 9 * t,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 + k.stroke
          ..color = k.ink.withValues(alpha: (1 - t) * (k.light ? 0.85 : 0.6)),
      );
      canvas.drawCircle(p, k.light ? 8 : 7, Paint()..color = k.ground);
      canvas.drawCircle(p, k.light ? 5.5 : 4.5, Paint()..color = k.ink);
    }
  }

  void _rangeRing(Canvas canvas, Offset c, double r, Color color) {
    if (r < 10) return;
    canvas.drawPath(
      _dashed(Path()..addOval(Rect.fromCircle(center: c, radius: r)), 3, 5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1 + g.ink.stroke
        ..color = color.withValues(alpha: g.ink.light ? 0.85 : 0.5),
    );
  }

  void _diamond(Canvas canvas, Offset c, double r, Color color, double rot) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(rot);
    final path = Path()
      ..moveTo(0, -r)
      ..lineTo(r, 0)
      ..lineTo(0, r)
      ..lineTo(-r, 0)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..color = color,
    );
    canvas.restore();
  }

  void _ticks(Canvas canvas, Offset c, double r, Color color) {
    final p = Paint()
      ..strokeWidth = 1.5
      ..color = color;
    for (var i = 0; i < 4; i++) {
      final a = i * math.pi / 2;
      final d = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(c + d * r, c + d * (r + 6), p);
    }
  }

  @override
  bool shouldRepaint(_FxPainter old) => old.cam != cam;
}

/// Tiny hex wireframe glyph for splash / empty states.
class HexGlyph extends StatelessWidget {
  const HexGlyph({super.key, this.size = 56, this.color = Palette.mint});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: _GlyphPainter(color));
}

class _GlyphPainter extends CustomPainter {
  _GlyphPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    canvas.drawPath(
      _hexGlyph(c, r * 0.9),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = color.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawPath(
      _hexGlyph(c, r * 0.9),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = color,
    );
    canvas.drawPath(
      _hexGlyph(c, r * 0.45),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Palette.amber,
    );
    canvas.drawCircle(c, r * 0.08, Paint()..color = Palette.amber);
  }

  @override
  bool shouldRepaint(_GlyphPainter old) => old.color != color;
}
