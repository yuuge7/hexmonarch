import 'dart:math' as math;

const _suffixes = ['', 'K', 'M', 'B', 'T', 'Qa', 'Qi', 'Sx', 'Sp', 'Oc', 'No', 'Dc'];

/// Compact number for unbounded idle-scale values: 950, 12.4K, 3.21M ... 1.2e39.
String fmtNum(num value) {
  final v = value.toDouble();
  if (v.isNaN) return '0';
  if (v.isInfinite) return v > 0 ? '∞' : '-∞';
  final sign = v < 0 ? '-' : '';
  final a = v.abs();
  if (a < 10) {
    final s = a.toStringAsFixed(a == a.roundToDouble() ? 0 : 1);
    return '$sign$s';
  }
  if (a < 1000) return '$sign${a.floor()}';
  final tier = (math.log(a) / math.ln10 / 3).floor();
  if (tier >= _suffixes.length) {
    final exp = (math.log(a) / math.ln10).floor();
    final mant = a / math.pow(10, exp);
    return '$sign${mant.toStringAsFixed(2)}e$exp';
  }
  final scaled = a / math.pow(1000, tier);
  final digits = scaled < 10 ? 2 : (scaled < 100 ? 1 : 0);
  return '$sign${scaled.toStringAsFixed(digits)}${_suffixes[tier]}';
}

/// "+12.4%" from a 0.124 multiplier.
String fmtPct(double mult, {bool sign = true}) {
  final p = mult * 100;
  final body = p.abs() >= 1000
      ? fmtNum(p.abs())
      : p.abs() >= 100
          ? p.abs().toStringAsFixed(0)
          : p.abs().toStringAsFixed(1);
  final s = p < 0 ? '-' : (sign ? '+' : '');
  return '$s$body%';
}

String fmtDuration(Duration d) {
  if (d.isNegative) return '0s';
  if (d.inDays >= 1) return '${d.inDays}d ${d.inHours % 24}h';
  if (d.inHours >= 1) return '${d.inHours}h ${d.inMinutes % 60}m';
  if (d.inMinutes >= 1) return '${d.inMinutes}m ${d.inSeconds % 60}s';
  return '${d.inSeconds}s';
}

String fmtKm(double km) =>
    km < 1 ? '${(km * 1000).round()} m' : '${km.toStringAsFixed(km < 10 ? 1 : 0)} km';

String roman(int n) {
  if (n <= 0) return '0';
  const map = [
    [1000, 'M'], [900, 'CM'], [500, 'D'], [400, 'CD'], [100, 'C'], [90, 'XC'],
    [50, 'L'], [40, 'XL'], [10, 'X'], [9, 'IX'], [5, 'V'], [4, 'IV'], [1, 'I'],
  ];
  final b = StringBuffer();
  var r = n;
  for (final e in map) {
    final v = e[0] as int;
    while (r >= v) {
      b.write(e[1]);
      r -= v;
    }
  }
  return b.toString();
}

String clockTime(int ms) {
  final d = DateTime.fromMillisecondsSinceEpoch(ms);
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(d.hour)}:${two(d.minute)}';
}
