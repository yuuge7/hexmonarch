/// Anti-tamper for the offline catch-up engine.
///
/// The game keeps its own clock ("game time"). Between sessions it advances by
/// a *trusted* delta: Android's elapsedRealtime (monotonic, counts deep sleep,
/// immune to the user editing the date) whenever the device has not rebooted.
/// After a reboot only the wall clock is available, so it is cross-checked
/// against the last sync point and, when the OS has one, network time.
class ClockSample {
  const ClockSample({
    required this.wall,
    required this.elapsed,
    required this.bootCount,
    this.networkTime,
  });

  final int wall;
  final int elapsed;
  final int bootCount; // -1 when unknown
  final int? networkTime;
}

class SyncAnchor {
  const SyncAnchor({
    required this.gameTime,
    required this.wallAtSync,
    required this.elapsedAtSync,
    required this.bootCount,
  });

  final int gameTime;
  final int wallAtSync;
  final int elapsedAtSync;
  final int bootCount;
}

class TimeVerdict {
  const TimeVerdict({required this.deltaMs, required this.gameNow, this.tamperReason, this.skewMs = 0});

  final int deltaMs;
  final int gameNow;
  final String? tamperReason;

  /// How far the device clock runs ahead of the time the game trusts
  /// (negative: behind). Only meaningful when [tampered].
  final int skewMs;

  bool get tampered => tamperReason != null;

  /// The clock was pushed well forward: someone fishing for offline income,
  /// not a phone tidying up a slow clock.
  bool get fastForward => tampered && skewMs > kCheatSkewMs;
}

const kCheatSkewMs = 15 * 60 * 1000;

/// Offline time credited when a save is imported, at most.
const kImportMaxOfflineMs = 3 * 24 * 60 * 60 * 1000;

/// A save carries the clock anchor of the phone that wrote it (uptime, boot
/// count). On another phone those numbers are meaningless and could look like
/// tampering, so the anchor is rebuilt on this device: the time since the save
/// was written (capped, never negative) becomes plain offline time.
SyncAnchor reanchorForImport(SyncAnchor saved, ClockSample here) {
  final sinceSave = (here.wall - saved.wallAtSync).clamp(0, kImportMaxOfflineMs);
  return SyncAnchor(
    gameTime: saved.gameTime,
    wallAtSync: here.wall - sinceSave,
    elapsedAtSync: here.elapsed - sinceSave,
    bootCount: here.bootCount,
  );
}

const kClockTolerance = 2 * 60 * 1000;
const kNetworkTolerance = 5 * 60 * 1000;

TimeVerdict evaluateClock(SyncAnchor anchor, ClockSample now) {
  final wallDelta = now.wall - anchor.wallAtSync;
  final knownBoot = anchor.bootCount >= 0 && now.bootCount >= 0;
  final sameBoot = now.elapsed >= anchor.elapsedAtSync &&
      (!knownBoot || now.bootCount == anchor.bootCount);

  if (sameBoot) {
    final mono = now.elapsed - anchor.elapsedAtSync;
    final drift = wallDelta - mono;
    final allowed = kClockTolerance + mono ~/ 100;
    String? reason;
    // A jump that lands on network time is an OS clock correction, not a cheat.
    final corrected = now.networkTime != null && (now.wall - now.networkTime!).abs() <= kNetworkTolerance;
    if (drift.abs() > allowed && !corrected) {
      final mins = (drift / 60000).round();
      reason = 'Device clock shifted ${mins > 0 ? '+' : ''}$mins min against the hardware timer';
    }
    return TimeVerdict(
      deltaMs: mono,
      gameNow: anchor.gameTime + mono,
      tamperReason: reason,
      skewMs: reason == null ? 0 : drift,
    );
  }

  // Rebooted: wall clock is all we have.
  if (now.networkTime != null && (now.wall - now.networkTime!).abs() > kNetworkTolerance) {
    final trusted = now.networkTime! - anchor.wallAtSync;
    final d = trusted < 0 ? 0 : trusted;
    return TimeVerdict(
      deltaMs: d,
      gameNow: anchor.gameTime + d,
      tamperReason: 'Device clock disagrees with network time',
      skewMs: now.wall - now.networkTime!,
    );
  }
  if (wallDelta < -kClockTolerance) {
    return TimeVerdict(
      deltaMs: 0,
      gameNow: anchor.gameTime,
      tamperReason: 'Device clock is behind the last sync',
      skewMs: wallDelta,
    );
  }
  final d = wallDelta < 0 ? 0 : wallDelta;
  return TimeVerdict(deltaMs: d, gameNow: anchor.gameTime + d);
}
