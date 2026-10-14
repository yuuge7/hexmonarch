import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../domain/balance.dart';
import 'common.dart';

/// Today on one line: the four Event Deck deals as ticks on a 24-hour track,
/// the night when nothing is dealt, and where "now" is.
class DealClock extends StatelessWidget {
  const DealClock({super.key, required this.now});

  /// Game time in ms.
  final int now;

  @override
  Widget build(BuildContext context) {
    final t = DateTime.fromMillisecondsSinceEpoch(now);
    final hour = t.hour + t.minute / 60 + t.second / 3600;
    return Semantics(
      label: 'Deals at ${kEventWaveHours.join(', ')} hundred hours',
      child: SizedBox(
        height: 40,
        width: double.infinity,
        child: CustomPaint(painter: _DealClockPainter(hour)),
      ),
    );
  }
}

class _DealClockPainter extends CustomPainter {
  _DealClockPainter(this.hour);
  final double hour;

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 8.0;
    const y = 15.0;
    final w = size.width - 2 * pad;
    double x(double h) => pad + w * h / 24;

    // Night: no deals between the last wave and the first.
    final first = kEventWaveHours.first.toDouble(), last = kEventWaveHours.last.toDouble();
    final night = Paint()..color = Palette.line.withValues(alpha: 0.35);
    canvas.drawRect(Rect.fromLTRB(x(0), y - 5, x(first), y + 5), night);
    canvas.drawRect(Rect.fromLTRB(x(last), y - 5, x(24), y + 5), night);

    // Track, lit up to now.
    canvas.drawLine(Offset(x(0), y), Offset(x(24), y), Paint()
      ..strokeWidth = 1
      ..color = Palette.line);
    canvas.drawLine(Offset(x(first), y), Offset(x(math.min(hour, last)), y), Paint()
      ..strokeWidth = 2
      ..color = Palette.mint.withValues(alpha: hour > first ? 0.6 : 0));

    final next = kEventWaveHours.firstWhere((h) => h > hour, orElse: () => -1);
    for (final h in kEventWaveHours) {
      final c = Offset(x(h.toDouble()), y);
      final dealt = h <= hour;
      final isNext = h == next;
      final r = isNext ? 6.0 : 4.5;
      final d = Path()
        ..moveTo(c.dx, c.dy - r)
        ..lineTo(c.dx + r, c.dy)
        ..lineTo(c.dx, c.dy + r)
        ..lineTo(c.dx - r, c.dy)
        ..close();
      final color = dealt ? Palette.mint : (isNext ? Palette.amber : Palette.textDim);
      canvas.drawPath(d, Paint()..color = dealt ? color : Palette.slateHi);
      canvas.drawPath(
        d,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = color,
      );
      _text(canvas, h.toString().padLeft(2, '0'), Offset(c.dx, y + 10), color);
    }
    _text(canvas, '00', Offset(x(0) + 6, y + 10), Palette.textFaint);
    _text(canvas, '24', Offset(x(24) - 6, y + 10), Palette.textFaint);

    // Now.
    final nx = x(hour);
    final mark = Paint()
      ..strokeWidth = 1.5
      ..color = Palette.text;
    canvas.drawLine(Offset(nx, y - 9), Offset(nx, y + 7), mark);
    canvas.drawPath(
      Path()
        ..moveTo(nx - 3.5, 0)
        ..lineTo(nx + 3.5, 0)
        ..lineTo(nx, 5)
        ..close(),
      Paint()..color = Palette.text,
    );
  }

  void _text(Canvas canvas, String s, Offset center, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(fontFamily: Fonts.mono, fontSize: 9, fontWeight: FontWeight.w600, color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, 0));
  }

  @override
  bool shouldRepaint(_DealClockPainter old) => (old.hour * 60).floor() != (hour * 60).floor();
}

/// Strike against defense as one bar: the mint share is your odds.
class OddsBar extends StatelessWidget {
  const OddsBar({super.key, required this.strike, required this.defense, required this.odds});
  final double strike;
  final double defense;
  final double odds;

  @override
  Widget build(BuildContext context) {
    final color = odds >= 0.6 ? Palette.mint : (odds >= 0.35 ? Palette.amber : Palette.hostile);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Eyebrow('Your odds'),
            const Spacer(),
            Text('${(odds * 100).round()}%', style: TextStyles.display.copyWith(color: color, fontSize: 26)),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 8,
          child: LayoutBuilder(
            builder: (context, c) {
              final split = c.maxWidth * odds.clamp(0.0, 1.0);
              return Stack(
                children: [
                  Positioned.fill(child: ColoredBox(color: Palette.hostile.withValues(alpha: 0.45))),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: split,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: color,
                        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8)],
                      ),
                    ),
                  ),
                  // The front line.
                  Positioned(left: math.max(0, split - 1), top: -2, bottom: -2, width: 2, child: const ColoredBox(color: Palette.text)),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Text('STRIKE ${fmtNum(strike)}', style: TextStyles.dataSmall.copyWith(color: Palette.mint)),
            const Spacer(),
            Text('DEFENSE ${fmtNum(defense)}', style: TextStyles.dataSmall.copyWith(color: Palette.hostile)),
          ],
        ),
      ],
    );
  }
}

/// How hard a faction fights, from its grit (balance.dart).
class StrengthChip extends StatelessWidget {
  const StrengthChip(this.grit, {super.key});
  final double grit;

  @override
  Widget build(BuildContext context) {
    final (label, color) = grit < 0.7
        ? ('Weak crew', Palette.mint)
        : grit < 0.95
            ? ('Soft', Palette.mint)
            : grit < kToughGrit
                ? ('Full strength', Palette.textDim)
                : ('Tough · rich loot', Palette.hostile);
    return TagChip('$label · ${(grit * 100).round()}%', color: color, filled: grit < 0.95 || grit >= kToughGrit);
  }
}

/// Used and free slots, as a row of chamfered pips.
class SlotPips extends StatelessWidget {
  const SlotPips({super.key, required this.used, required this.total, this.color = Palette.amber});
  final int used;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < total; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Container(
              width: 16,
              height: 10,
              decoration: ShapeDecoration(
                color: i < used ? color : Colors.transparent,
                shape: chamfer(3, i < used ? null : color.withValues(alpha: 0.6)),
              ),
            ),
          ],
        ],
      );
}

/// A running shop boost and the time it has left.
class BoostTag extends StatelessWidget {
  const BoostTag({super.key, required this.title, required this.leftMs});
  final String title;
  final int leftMs;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: ShapeDecoration(
          color: Palette.mint.withValues(alpha: 0.12),
          shape: chamfer(4, Palette.mint.withValues(alpha: 0.55)),
        ),
        child: Text(
          '${title.toUpperCase()} ${fmtDuration(Duration(milliseconds: math.max(0, leftMs)))}',
          style: TextStyles.label.copyWith(color: Palette.mint, fontSize: 8.5, letterSpacing: 1),
        ),
      );
}
