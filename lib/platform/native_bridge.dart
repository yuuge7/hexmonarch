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

  /// Replaces the queued notifications with [alerts]: each fires [inMs] from
  /// now, whether or not the app is still alive.
  Future<void> scheduleAlerts(List<({int inMs, String title, String body, bool urgent})> alerts) => _quiet(
        () => _channel.invokeMethod<void>('scheduleAlerts', {
          'alerts': [
            for (final a in alerts) {'inMs': a.inMs, 'title': a.title, 'body': a.body, 'urgent': a.urgent},
          ],
        }),
      );

  /// Drops every queued notification and clears the ones already showing.
  Future<void> cancelAlerts() => _quiet(() => _channel.invokeMethod<void>('cancelAlerts'));

  Future<bool> notificationsAllowed() async =>
      await _quiet(() => _channel.invokeMethod<bool>('notifyAllowed')) ?? false;

  /// Shows the system permission dialog when it still can. True when allowed.
  Future<bool> requestNotifications() async =>
      await _quiet(() => _channel.invokeMethod<bool>('notifyRequest')) ?? false;

  Future<void> openNotificationSettings() => _quiet(() => _channel.invokeMethod<void>('notifySettings'));

  /// Null on hosts without the channel (tests) or when the platform call fails.
  Future<T?> _quiet<T>(Future<T?> Function() call) async {
    try {
      return await call();
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

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
