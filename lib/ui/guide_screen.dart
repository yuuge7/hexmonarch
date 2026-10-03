import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme.dart';
import 'widgets/common.dart';

/// In-game field manual. Renders GUIDE.md (the same file that sits at the
/// repo root) so there is a single source of truth.
class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GuideScreen()));

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(value: kDarkBars, child: _page(context));

  Widget _page(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.carbon,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<String>(
                future: rootBundle.loadString('GUIDE.md'),
                builder: (context, snap) {
                  if (snap.hasError) {
                    return const Center(child: Text('Manual could not be loaded.', style: TextStyles.bodyDim));
                  }
                  if (!snap.hasData) return const SizedBox.shrink();
                  return ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 24), children: _render(snap.data!));
                },
              ),
            ),
            // Close control sits at the bottom, in thumb reach.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: CommandButton(label: 'Back to the map', onPressed: () => Navigator.of(context).pop()),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _render(String md) {
    final out = <Widget>[];
    final para = StringBuffer();

    void flush() {
      if (para.isEmpty) return;
      out.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text.rich(_inline(para.toString().trim()), style: TextStyles.body.copyWith(color: Palette.textDim)),
        ),
      );
      para.clear();
    }

    for (final raw in md.split('\n')) {
      final line = raw.trimRight();
      if (line.startsWith('# ')) {
        flush();
        out.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              line.substring(2).toUpperCase(),
              style: TextStyles.display.copyWith(fontSize: 26, letterSpacing: 2, color: Palette.mint),
            ),
          ),
        );
      } else if (line.startsWith('## ')) {
        flush();
        out.add(
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line.substring(3), style: TextStyles.display.copyWith(fontSize: 19)),
                const SizedBox(height: 6),
                Container(height: 1, width: 36, color: Palette.amber),
              ],
            ),
          ),
        );
      } else if (line.startsWith('- ')) {
        flush();
        out.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 7, right: 10),
                  child: Container(width: 5, height: 5, color: Palette.mint),
                ),
                Expanded(
                  child: Text.rich(_inline(line.substring(2)), style: TextStyles.body.copyWith(color: Palette.textDim)),
                ),
              ],
            ),
          ),
        );
      } else if (line.isEmpty) {
        flush();
      } else {
        para.write('$line ');
      }
    }
    flush();
    return out;
  }

  /// Supports **bold** only: that is all the manual uses.
  TextSpan _inline(String text) {
    final spans = <TextSpan>[];
    final parts = text.split('**');
    for (var i = 0; i < parts.length; i++) {
      if (parts[i].isEmpty) continue;
      spans.add(
        TextSpan(
          text: parts[i],
          style: i.isOdd ? const TextStyle(color: Palette.text, fontWeight: FontWeight.w700) : null,
        ),
      );
    }
    return TextSpan(children: spans);
  }
}
