import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show StandardMessageCodec;

import '../core/theme.dart';
import '../game/game_controller.dart';
import 'widgets/common.dart';

const _kTape = 'dQw4w9WgXcQ';

/// The answer to a device clock pushed forward between sessions: a verdict,
/// and a certain music video playing above it, inside the game. Shown once
/// per attempt and left out of the manual on purpose: whoever sees it has
/// earned it.
///
/// The video is the publisher's own embed in a native WebView
/// (TapeView.kt), so nothing copyrighted ships with the game and it needs a
/// connection. Offline, the frame stays dark and the verdict stands alone.
Future<void> showClockAnomaly(BuildContext context, GameController game) {
  final strikes = game.player.tamperStrikes;
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black87,
    builder: (ctx) => Dialog(
      backgroundColor: Palette.slate,
      shape: chamfer(16, Palette.hostile),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AspectRatio(aspectRatio: 16 / 9, child: ColoredBox(color: Colors.black, child: _Tape())),
            const SizedBox(height: 14),
            const Eyebrow('Clock anomaly', color: Palette.hostile),
            const SizedBox(height: 6),
            const Text('Nice try.', style: TextStyles.display),
            const SizedBox(height: 10),
            const Text(
              'The clock on your phone jumped ahead. The clock this empire runs on did not: '
              'it counts real seconds and nobody gets to set it.',
              style: TextStyles.body,
            ),
            const SizedBox(height: 10),
            Text(
              'You just got rickrolled. No free credits today.',
              style: TextStyles.body.copyWith(color: Palette.amber),
            ),
            const SizedBox(height: 10),
            Text(
              strikes > 1
                  ? 'Strike $strikes on your file. The auditors took 15% of your credits, and will again.'
                  : 'Strike $strikes on your file. Next time the auditors take 15% of your credits.',
              style: TextStyles.bodyDim,
            ),
            const SizedBox(height: 16),
            CommandButton(label: 'I deserved that', tone: Tone.hostile, onPressed: () => Navigator.pop(ctx)),
          ],
        ),
      ),
    ),
  );
}

class _Tape extends StatelessWidget {
  const _Tape();

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.android) return const SizedBox.shrink();
    return AndroidView(
      viewType: 'hexmonarch/tape',
      creationParams: const {'video': _kTape},
      creationParamsCodec: const StandardMessageCodec(),
      // The player keeps its own taps (pause, volume) inside the dialog.
      gestureRecognizers: {Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new)},
    );
  }
}
