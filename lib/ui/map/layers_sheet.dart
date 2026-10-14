import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../game/game_controller.dart';
import '../widgets/common.dart';
import 'map_layers.dart';

extension MapLayersOf on GameController {
  MapLayers get layers => MapLayers.fromSetting(player.settings['layers']);
  Future<void> setLayers(MapLayers l) => setSetting('layers', l.toSetting());
}

/// Map layers, like acetate sheets over a paper map: pick a mode, or switch
/// single layers. The map behind the sheet changes as you flip them.
Future<void> showMapLayers(BuildContext context, GameController game) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Palette.slate,
    // Light scrim: the point is to watch the map change behind the sheet.
    barrierColor: Colors.black.withValues(alpha: 0.18),
    shape: chamfer(16, Palette.line),
    builder: (ctx) => ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * 0.58),
      child: SafeArea(
        top: false,
        child: ListenableBuilder(
          listenable: game,
          builder: (ctx, _) {
            final layers = game.layers;
            final mode = layers.mode;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      const Expanded(child: Text('Map layers', style: TextStyles.title)),
                      Text('${layers.on.length}/${MapLayer.values.length} ON',
                          style: TextStyles.label.copyWith(color: Palette.mint)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      for (final m in [MapMode.clean, MapMode.tactical, MapMode.intel]) ...[
                        if (m != MapMode.clean) const SizedBox(width: 6),
                        Expanded(
                          child: SegChip(m.title,
                              on: m == mode, onTap: () => game.setLayers(MapLayers(layersOf(m)))),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                  child: Text(mode.blurb, style: TextStyles.bodyDim.copyWith(fontSize: 12)),
                ),
                const Divider(height: 1, color: Palette.line),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(16, 4, 8, 12),
                    children: [
                      for (final l in MapLayer.values)
                        _LayerRow(
                          layer: l,
                          on: layers.has(l),
                          ink: game.ink,
                          onChanged: (_) => game.setLayers(layers.toggle(l)),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}

class _LayerRow extends StatelessWidget {
  const _LayerRow({required this.layer, required this.on, required this.ink, required this.onChanged});
  final MapLayer layer;
  final bool on;
  final MapInk ink;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: on,
      label: layer.title,
      child: InkWell(
        onTap: () => onChanged(!on),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              // The swatch is a piece of the map itself: it dims with the layer.
              AnimatedOpacity(
                duration: const Duration(milliseconds: 160),
                opacity: on ? 1 : 0.35,
                child: Container(
                  width: 52,
                  height: 36,
                  decoration: ShapeDecoration(
                    color: ink.ground,
                    shape: chamfer(6, on ? Palette.line : Palette.line.withValues(alpha: 0.5)),
                  ),
                  child: CustomPaint(painter: _SwatchPainter(layer, ink)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(layer.title,
                        style: TextStyles.body.copyWith(
                            fontWeight: FontWeight.w600, color: on ? Palette.text : Palette.textDim)),
                    const SizedBox(height: 1),
                    Text(layer.blurb, style: TextStyles.bodyDim.copyWith(fontSize: 12)),
                  ],
                ),
              ),
              Switch(value: on, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }
}

/// A thumbnail of what each layer paints, in the map's own inks.
class _SwatchPainter extends CustomPainter {
  _SwatchPainter(this.layer, this.k);
  final MapLayer layer;
  final MapInk k;

  Path _hex(Offset c, double r) {
    final p = Path();
    for (var i = 0; i < 6; i++) {
      final a = math.pi / 6 + i * math.pi / 3;
      final o = c + Offset(math.cos(a), math.sin(a)) * r;
      i == 0 ? p.moveTo(o.dx, o.dy) : p.lineTo(o.dx, o.dy);
    }
    return p..close();
  }

  void _glyph(Canvas canvas, Offset c, Color color, {double r = 4, Color? fill}) {
    final h = _hex(c, r);
    canvas.drawPath(h, Paint()..color = fill ?? k.ground);
    canvas.drawPath(
      h,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..color = color,
    );
  }

  Paint _stroke(Color c, [double w = 1.2]) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..color = c;

  void _dash(Canvas canvas, Offset a, Offset b, Paint p, {double dash = 3, double gap = 3}) {
    final d = b - a;
    final len = d.distance;
    final u = d / len;
    for (var s = 0.0; s < len; s += dash + gap) {
      canvas.drawLine(a + u * s, a + u * math.min(len, s + dash), p);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    switch (layer) {
      case MapLayer.labels:
        _glyph(canvas, c + const Offset(0, -6), k.mine);
        final tp = TextPainter(
          text: TextSpan(
            text: 'GARA',
            style: TextStyle(fontFamily: Fonts.mono, fontSize: 7.5, fontWeight: FontWeight.w700, color: k.mine),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, c + Offset(-tp.width / 2, 2));
      case MapLayer.spheres:
        final circle = Rect.fromCircle(center: c + const Offset(0, 6), radius: 20);
        canvas.drawOval(circle, Paint()..color = k.hub.withValues(alpha: 0.08));
        for (var i = 0; i < 12; i++) {
          canvas.drawArc(circle, i * math.pi / 6, math.pi / 12, false, _stroke(k.hub.withValues(alpha: 0.8)));
        }
        _glyph(canvas, c + const Offset(0, 6), k.hub, r: 5);
      case MapLayer.reach:
        canvas.drawCircle(c + const Offset(-8, 4), 16, _stroke(k.mine.withValues(alpha: 0.55), 1));
        canvas.drawCircle(c + const Offset(10, 2), 14, _stroke(k.mine.withValues(alpha: 0.55), 1));
        _glyph(canvas, c + const Offset(-8, 4), k.mine);
        _glyph(canvas, c + const Offset(10, 2), k.mine);
      case MapLayer.relays:
        final a = c + const Offset(-16, 8), b = c + const Offset(16, -8);
        _dash(canvas, a, b, _stroke(k.hub, 1.4), dash: 4, gap: 3);
        canvas.drawCircle(Offset.lerp(a, b, 0.55)!, 2, Paint()..color = k.hub);
        _glyph(canvas, a, k.hub, r: 4.5);
        _glyph(canvas, b, k.hub, r: 4.5);
      case MapLayer.supplyLines:
        final hub = c + const Offset(-12, 2);
        final spokes = [c + const Offset(12, -10), c + const Offset(14, 8), c + const Offset(-4, 13)];
        for (final s in spokes) {
          canvas.drawLine(s, hub, _stroke(k.mine.withValues(alpha: 0.6), 1));
        }
        for (final s in spokes) {
          _glyph(canvas, s, k.mine, r: 3.5);
        }
        _glyph(canvas, hub, k.hub, r: 5);
      case MapLayer.reachWeb:
        final pts = [c + const Offset(-16, 6), c + const Offset(-2, -9), c + const Offset(14, 4), c + const Offset(2, 12)];
        final p = _stroke(k.mine.withValues(alpha: 0.6), 1);
        for (var i = 0; i < pts.length; i++) {
          _dash(canvas, pts[i], pts[(i + 1) % pts.length], p);
        }
        for (final o in pts) {
          _glyph(canvas, o, k.mine, r: 3.5);
        }
      case MapLayer.integrity:
        final r = Rect.fromCircle(center: c, radius: 11);
        canvas.drawOval(r, _stroke(k.dim.withValues(alpha: 0.35), 2));
        canvas.drawArc(r, -math.pi / 2, 2 * math.pi * 0.7, false, _stroke(k.mine, 2));
        _glyph(canvas, c, k.mine);
      case MapLayer.odds:
        _glyph(canvas, c + const Offset(0, -6), k.hostile);
        final tp = TextPainter(
          text: TextSpan(
            text: '62%',
            style: TextStyle(fontFamily: Fonts.mono, fontSize: 8, fontWeight: FontWeight.w700, color: k.hub),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, c + Offset(-tp.width / 2, 2));
      case MapLayer.ground:
        _glyph(canvas, c + const Offset(-14, 0), k.mine, r: 5, fill: k.hub);
        _glyph(canvas, c, k.mine, r: 5, fill: k.ink);
        _glyph(canvas, c + const Offset(14, 0), k.mine, r: 5, fill: k.intel);
      case MapLayer.events:
        void diamond(Offset o, Color color) {
          final d = Path()
            ..moveTo(o.dx, o.dy - 6)
            ..lineTo(o.dx + 6, o.dy)
            ..lineTo(o.dx, o.dy + 6)
            ..lineTo(o.dx - 6, o.dy)
            ..close();
          canvas.drawPath(d, _stroke(color, 1.6));
        }
        diamond(c + const Offset(-9, 0), k.hub);
        diamond(c + const Offset(9, 0), k.intel);
    }
  }

  @override
  bool shouldRepaint(_SwatchPainter old) => old.layer != layer || old.k != k;
}
