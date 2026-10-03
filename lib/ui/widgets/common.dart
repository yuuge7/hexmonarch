import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../domain/actions.dart';
import '../../domain/models.dart';

/// Moves the map to a point and, when given, selects that turf.
typedef LocateCallback = void Function(double lat, double lng, String? turfId);

enum Tone { mint, amber, hostile, neutral }

Color toneColor(Tone t) => switch (t) {
      Tone.mint => Palette.mint,
      Tone.amber => Palette.amber,
      Tone.hostile => Palette.hostile,
      Tone.neutral => Palette.textDim,
    };

Color rarityColor(Rarity r) => switch (r) {
      Rarity.common => const Color(0xFF8A94A6),
      Rarity.uncommon => Palette.ice,
      Rarity.rare => Palette.mint,
      Rarity.epic => const Color(0xFFB98CFF),
      Rarity.legendary => Palette.amber,
      Rarity.mythic => const Color(0xFFFF5CF0),
    };

/// Mono eyebrow label, tracked out.
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: TextStyles.label.copyWith(color: color),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
}

class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.color = Palette.slateHi,
    this.border,
    this.cut = 10,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final Color? border;
  final double cut;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: ShapeDecoration(color: color, shape: chamfer(cut, border)),
        child: Padding(padding: padding, child: child),
      );
}

/// Thin progress bar with a tick-marked track.
class Meter extends StatelessWidget {
  const Meter({super.key, required this.value, this.color = Palette.mint, this.height = 4});
  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final v = value.isNaN ? 0.0 : value.clamp(0.0, 1.0);
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, c) => Stack(
          children: [
            Container(color: Palette.line.withValues(alpha: 0.6)),
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              width: c.maxWidth * v,
              decoration: BoxDecoration(
                color: color,
                boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "120 CR · 20 MAT · 5 INT", unaffordable parts in hostile red.
class CostLine extends StatelessWidget {
  const CostLine(this.cost, {super.key, this.have, this.color = Palette.carbon, this.size = 11.5});
  final Cost cost;
  final PlayerData? have;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final parts = <InlineSpan>[];
    void add(double v, double? owned, String unit) {
      if (v <= 0) return;
      if (parts.isNotEmpty) parts.add(TextSpan(text: '  ', style: TextStyle(color: color)));
      final short = owned != null && owned + 1e-9 < v;
      parts.add(TextSpan(
        text: '${fmtNum(v)} $unit',
        style: TextStyle(color: short ? Palette.hostile : color),
      ));
    }

    add(cost.credits, have?.credits, 'CR');
    add(cost.materials, have?.materials, 'MAT');
    add(cost.intel, have?.intel, 'INT');
    if (parts.isEmpty) parts.add(TextSpan(text: 'FREE', style: TextStyle(color: color)));
    return Text.rich(
      TextSpan(children: parts),
      style: TextStyles.dataSmall.copyWith(fontSize: size, fontWeight: FontWeight.w600),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Chamfered command button. Filled = primary; outlined = secondary.
class CommandButton extends StatefulWidget {
  const CommandButton({
    super.key,
    required this.label,
    this.onPressed,
    this.tone = Tone.mint,
    this.filled = true,
    this.cost,
    this.have,
    this.caption,
    this.height = 52,
    this.icon,
    this.holdToConfirm = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Tone tone;
  final bool filled;
  final Cost? cost;
  final PlayerData? have;
  final String? caption;
  final double height;
  final IconData? icon;
  final bool holdToConfirm;

  @override
  State<CommandButton> createState() => _CommandButtonState();
}

class _CommandButtonState extends State<CommandButton> with SingleTickerProviderStateMixin {
  late final _hold = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
  bool _down = false;

  @override
  void initState() {
    super.initState();
    _hold.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        widget.onPressed?.call();
        _hold.reset();
      }
    });
  }

  @override
  void dispose() {
    _hold.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final c = toneColor(widget.tone);
    final bg = !enabled
        ? Palette.slateHi
        : widget.filled
            ? c
            : Colors.transparent;
    final fg = !enabled
        ? Palette.textFaint
        : widget.filled
            ? Palette.carbon
            : c;
    final border = widget.filled && enabled ? null : (enabled ? c.withValues(alpha: 0.7) : Palette.line);

    final label = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: 18, color: fg),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            widget.label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.title.copyWith(
              color: fg,
              fontSize: widget.height >= 50 ? 15 : 13,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );

    Widget? sub;
    if (widget.cost != null) {
      sub = CostLine(widget.cost!, have: enabled ? widget.have : null, color: fg.withValues(alpha: 0.85));
    } else if (widget.caption != null) {
      sub = Text(
        widget.caption!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.dataSmall.copyWith(color: fg.withValues(alpha: 0.8)),
      );
    }

    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        label,
        if (sub != null && widget.height >= 44) ...[const SizedBox(height: 2), sub],
      ],
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: enabled ? (_) => _press(true) : null,
        onTapUp: enabled ? (_) => _press(false) : null,
        onTapCancel: enabled ? () => _press(false) : null,
        onTap: enabled && !widget.holdToConfirm ? widget.onPressed : null,
        child: AnimatedScale(
          scale: _down ? 0.975 : 1,
          duration: const Duration(milliseconds: 90),
          child: SizedBox(
            height: widget.height,
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: bg,
                shape: chamfer(9, border),
                shadows: widget.filled && enabled
                    ? [BoxShadow(color: c.withValues(alpha: 0.28), blurRadius: 14, spreadRadius: -2)]
                    : null,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.holdToConfirm)
                    AnimatedBuilder(
                      animation: _hold,
                      builder: (context, _) => FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _hold.value,
                        child: ColoredBox(color: Palette.carbon.withValues(alpha: 0.25)),
                      ),
                    ),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: content),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _press(bool down) {
    setState(() => _down = down);
    if (!widget.holdToConfirm) return;
    if (down) {
      _hold.forward();
    } else if (_hold.status != AnimationStatus.completed) {
      _hold.reverse();
    }
  }
}

/// Compact label/value cell used in stat rows.
class StatCell extends StatelessWidget {
  const StatCell(this.label, this.value, {super.key, this.color = Palette.text, this.sub});
  final String label;
  final String value;
  final Color color;
  final String? sub;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Eyebrow(label),
          const SizedBox(height: 3),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.data.copyWith(color: color, fontSize: 15)),
          if (sub != null)
            Text(sub!, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyles.dataSmall),
        ],
      );
}

class TagChip extends StatelessWidget {
  const TagChip(this.text, {super.key, this.color = Palette.textDim, this.filled = false});
  final String text;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: ShapeDecoration(
          color: filled ? color.withValues(alpha: 0.16) : Colors.transparent,
          shape: chamfer(5, color.withValues(alpha: 0.6)),
        ),
        child: Text(
          text.toUpperCase(),
          style: TextStyles.label.copyWith(color: color, fontSize: 9.5, letterSpacing: 1.2),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
}

/// Rebuilds every second (resource counters, countdowns, affordability).
class Ticking extends StatelessWidget {
  const Ticking({super.key, required this.tick, required this.builder});
  final ValueListenable<int> tick;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<int>(valueListenable: tick, builder: (c, _, _) => builder(c));
}

/// Live countdown text.
class Countdown extends StatefulWidget {
  const Countdown({super.key, required this.remainingMs, this.style});
  final int Function() remainingMs;
  final TextStyle? style;

  @override
  State<Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<Countdown> {
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      Text(fmtDuration(Duration(milliseconds: widget.remainingMs())), style: widget.style ?? TextStyles.dataSmall);
}

/// [above] is the height of the console the toast must clear.
void showOutcome(BuildContext context, Outcome o, {double? above}) {
  final m = ScaffoldMessenger.maybeOf(context);
  if (m == null) return;
  m.hideCurrentSnackBar();
  m.showSnackBar(SnackBar(
    duration: const Duration(milliseconds: 2200),
    // Float just above the console so toasts never cover a command.
    margin: EdgeInsets.fromLTRB(16, 0, 16, (above ?? MediaQuery.sizeOf(context).height * 0.45) + 10),
    content: Row(
      children: [
        Container(width: 3, height: 18, color: o.ok ? Palette.mint : Palette.hostile),
        const SizedBox(width: 10),
        Expanded(child: Text(o.message, style: TextStyles.body)),
      ],
    ),
  ));
}
