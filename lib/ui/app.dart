import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../game/game_controller.dart';
import 'home_screen.dart';
import 'map/tactical_map.dart' show HexGlyph;
import 'widgets/common.dart';

class HexMonarchApp extends StatefulWidget {
  const HexMonarchApp({super.key});

  @override
  State<HexMonarchApp> createState() => _HexMonarchAppState();
}

class _HexMonarchAppState extends State<HexMonarchApp> {
  final game = GameController();

  @override
  void initState() {
    super.initState();
    game.boot();
  }

  @override
  void dispose() {
    game.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HexMonarch',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: ListenableBuilder(
        listenable: game,
        builder: (context, _) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: game.stage == BootStage.ready
              ? HomeScreen(key: const ValueKey('home'), game: game)
              : _BootScreen(key: const ValueKey('boot'), game: game),
        ),
      ),
    );
  }
}

class _BootScreen extends StatelessWidget {
  const _BootScreen({super.key, required this.game});
  final GameController game;

  @override
  Widget build(BuildContext context) {
    final failed = game.stage == BootStage.failed;
    final line = switch (game.stage) {
      BootStage.starting => 'Opening local ledger',
      BootStage.syncing => 'Simulating time you were away',
      BootStage.failed => 'Boot failed: ${game.bootError}',
      BootStage.ready => '',
    };
    return Scaffold(
      backgroundColor: Palette.carbon,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 3),
              const HexGlyph(size: 64),
              const SizedBox(height: 24),
              Text('HEXMONARCH',
                  style: TextStyles.display.copyWith(fontSize: 34, letterSpacing: 6, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text('Plant turfs where you stand. Link the stations. Never stop.', style: TextStyles.bodyDim),
              const Spacer(flex: 4),
              Eyebrow(line, color: failed ? Palette.hostile : Palette.mint),
              const SizedBox(height: 10),
              if (!failed) const Meter(value: 0.6, height: 2),
              if (failed) ...[
                const SizedBox(height: 12),
                CommandButton(label: 'Retry', onPressed: game.boot),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
