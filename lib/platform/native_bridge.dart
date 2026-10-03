import 'package:flutter/services.dart';

import '../domain/actions.dart';
import '../domain/time_guard.dart';

/// Thin wrapper over the "hexmonarch/native" channel in MainActivity.kt.
class NativeBridge {
  NativeBridge._();
  static final instance = NativeBridge._();

  static const _channel = MethodChannel('hexmonarch/native');
  final _fallbackStart = DateTime.now().millisecondsSinceEpoch;
  final _fallbackWatch = Stopwatch()..start();

  bool hapticsEnabled = true;

  Future<ClockSample> clock() async {
    try {
      final m = await _channel.invokeMapMethod<String, Object?>('clock');
      if (m != null) {
        return ClockSample(
          wall: (m['wall'] as num).toInt(),
          elapsed: (m['elapsed'] as num).toInt(),
          bootCount: (m['bootCount'] as num?)?.toInt() ?? -1,
          networkTime: (m['networkTime'] as num?)?.toInt(),
        );
      }
    } on MissingPluginException {
      // Tests / non-Android hosts.
    } on PlatformException {
      // Fall through to the Dart clock.
    }
    return ClockSample(
      wall: DateTime.now().millisecondsSinceEpoch,
      elapsed: _fallbackStart + _fallbackWatch.elapsedMilliseconds,
      bootCount: -1,
    );
  }

  Future<void> haptic(Buzz kind) async {
    if (!hapticsEnabled || kind == Buzz.none) return;
    final type = switch (kind) {
      Buzz.click => 'click',
      Buzz.capture => 'capture',
      Buzz.warn => 'warn',
      Buzz.surge => 'surge',
      Buzz.none => 'tick',
    };
    await _send(type);
  }

  /// Opens the system "save as" dialog and writes [bytes] to the chosen file.
  /// Returns false when the user cancels. Throws [PlatformException] on I/O errors.
  Future<bool> exportFile(String name, Uint8List bytes) async =>
      await _channel.invokeMethod<bool>('exportFile', {'name': name, 'bytes': bytes}) ?? false;

  /// Opens the system file picker and returns the chosen file's bytes, or null
  /// when the user cancels.
  Future<Uint8List?> importFile() => _channel.invokeMethod<Uint8List>('importFile');

  /// Crisp tick on every turf border crossing.
  Future<void> borderTick() => hapticsEnabled ? _send('tick') : Future.value();

  Future<void> _send(String type) async {
    try {
      await _channel.invokeMethod<void>('haptic', {'type': type});
    } on MissingPluginException {
      await HapticFeedback.selectionClick();
    } on PlatformException {
      await HapticFeedback.selectionClick();
    }
  }
}
