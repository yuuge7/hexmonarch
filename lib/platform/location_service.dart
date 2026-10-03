import 'dart:async';

import 'package:flutter/material.dart' show Color;
import 'package:geolocator/geolocator.dart';

enum LocStatus { unknown, searching, active, denied, deniedForever, serviceOff }

/// GPS feed with two battery profiles:
///  - field: app visible, 5 m / 2 s, best accuracy (border-crossing haptics).
///  - patrol: screen off, 25 m / 10 s, runs inside a foreground service so the
///    empire keeps scouting while the phone is pocketed.
class LocationService {
  StreamSubscription<Position>? _sub;
  bool _patrol = false;
  LocStatus status = LocStatus.unknown;

  Future<LocStatus> ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return status = LocStatus.serviceOff;
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    return status = switch (perm) {
      LocationPermission.deniedForever => LocStatus.deniedForever,
      LocationPermission.denied => LocStatus.denied,
      LocationPermission.unableToDetermine => LocStatus.denied,
      _ => LocStatus.searching,
    };
  }

  Future<Position?> lastKnown() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (_) {
      return null;
    }
  }

  bool get running => _sub != null;
  bool get patrol => _patrol;

  void start({required bool patrol, required void Function(Position) onFix, void Function(Object)? onError}) {
    if (_sub != null && _patrol == patrol) return;
    stop();
    _patrol = patrol;
    final settings = patrol
        ? AndroidSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 25,
            intervalDuration: const Duration(seconds: 10),
            foregroundNotificationConfig: const ForegroundNotificationConfig(
              notificationTitle: 'HexMonarch patrol active',
              notificationText: 'Scouting sectors while you move.',
              notificationChannelName: 'Patrol mode',
              enableWakeLock: true,
              setOngoing: true,
              color: Color(0xFF00FFA3),
            ),
          )
        : AndroidSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 5,
            intervalDuration: const Duration(seconds: 2),
          );
    _sub = Geolocator.getPositionStream(locationSettings: settings).listen(
      (pos) {
        status = LocStatus.active;
        onFix(pos);
      },
      onError: (Object e) {
        if (e is PermissionDeniedException) status = LocStatus.denied;
        if (e is LocationServiceDisabledException) status = LocStatus.serviceOff;
        onError?.call(e);
      },
    );
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
  }

  Future<void> openSettings() => Geolocator.openAppSettings();
  Future<void> openLocationSettings() => Geolocator.openLocationSettings();
}
