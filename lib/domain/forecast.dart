import 'balance.dart';
import 'simulation.dart';
import 'world.dart';

/// Something worth a notification while the game is closed.
class Alert {
  const Alert(this.at, this.title, this.body, {required this.urgent});

  /// Game time it happens at.
  final int at;
  final String title;
  final String body;

  /// Attacks and losses ring; opportunities arrive quietly.
  final bool urgent;
}

/// How far ahead alerts are scheduled, and how many at most.
const kAlertHorizonMs = 72 * kHour;
const kAlertMax = 24;

/// The simulation is deterministic, so what happens while the game is closed
/// is known the moment it closes. This runs the coming hours on a copy of the
/// world and returns the moments worth waking the player for. [w] is not
/// touched. Pass the live simulator's [xpCarry] so both level up in step.
List<Alert> forecastAlerts(World w, int now, {int horizonMs = kAlertHorizonMs, double xpCarry = 0}) {
  final out = <Alert>[];

  final p = w.player;
  final fx = w.perks;
  if (p.energy < fx.energyMax - 0.5) {
    final ms = ((fx.energyMax - p.energy) / fx.energyPerHour * kHour).round();
    if (ms >= 10 * 60 * 1000 && ms <= horizonMs) {
      out.add(Alert(now + ms, 'Energy full', '${fx.energyMax.round()} energy ready. Run jobs before it goes to waste.',
          urgent: false));
    }
  }

  if (w.index.owned > 0) {
    final ghost = w.clone();
    Simulator(ghost, xpCarry: xpCarry).run(now, now + horizonMs, offline: true);
    // Everything that lands at the same moment shares one notification.
    final groups = <(int, bool), List<LogEntry>>{};
    for (final l in ghost.pendingLog) {
      if (l.alert == null || l.ts <= now) continue;
      (groups[(l.ts, l.kind == 'loss')] ??= []).add(l);
    }
    groups.forEach((key, lines) {
      final title = lines.length == 1 ? lines.first.alert! : '${lines.first.alert!} · ${lines.length - 1} more';
      out.add(Alert(key.$1, title, [for (final l in lines.take(4)) l.message].join('\n'), urgent: key.$2));
    });
  }

  out.sort((a, b) => a.at.compareTo(b.at));
  return out.length > kAlertMax ? out.sublist(0, kAlertMax) : out;
}
