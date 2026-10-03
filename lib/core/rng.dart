// Deterministic hashing + PRNG. Relies on the Dart VM's 64-bit wrapping ints,
// so the same seed yields the same world on every Android device.

import 'dart:math' as math;

/// SplitMix64 finalizer: avalanches all 64 bits.
int mix64(int z) {
  z = (z ^ (z >>> 30)) * 0xBF58476D1CE4E5B9;
  z = (z ^ (z >>> 27)) * 0x94D049BB133111EB;
  return z ^ (z >>> 31);
}

/// FNV-1a over UTF-16 code units.
int fnv1a64(String s) {
  var h = 0xcbf29ce484222325;
  for (var i = 0; i < s.length; i++) {
    h ^= s.codeUnitAt(i);
    h *= 0x100000001b3;
  }
  return h;
}

/// Folds several ints into one well-mixed seed.
int seedOf(List<int> parts) {
  var acc = 0x6A09E667F3BCC909;
  for (final p in parts) {
    acc = mix64(acc ^ p);
  }
  return acc;
}

/// Uniform [0,1) from the top 53 bits of a 64-bit hash.
double unitFromHash(int h) => (h >>> 11) / 9007199254740992.0;

class Rng {
  Rng(int seed) : _state = seed;

  int _state;

  int nextInt64() {
    _state += 0x9E3779B97F4A7C15;
    return mix64(_state);
  }

  double nextDouble() => unitFromHash(nextInt64());

  int nextInt(int max) {
    if (max <= 1) return 0;
    final v = (nextDouble() * max).floor();
    return v >= max ? max - 1 : v;
  }

  double range(double a, double b) => a + (b - a) * nextDouble();

  int rangeInt(int a, int bInclusive) => a + nextInt(bInclusive - a + 1);

  bool chance(double p) => nextDouble() < p;

  T pick<T>(List<T> items) => items[nextInt(items.length)];

  T weighted<T>(Map<T, double> weights) {
    var total = 0.0;
    for (final w in weights.values) {
      total += w;
    }
    var roll = nextDouble() * total;
    for (final e in weights.entries) {
      roll -= e.value;
      if (roll < 0) return e.key;
    }
    return weights.keys.last;
  }

  /// Heavy-tailed (Pareto) multiplier >= 1. Unbounded above: there is always
  /// a mathematically better roll.
  double pareto(double alpha) {
    final u = 1.0 - nextDouble(); // (0,1]
    return math.pow(u, -1.0 / alpha).toDouble();
  }

  String hexId([int len = 12]) {
    final a = nextInt64().toUnsigned(64).toRadixString(16).padLeft(16, '0');
    final b = nextInt64().toUnsigned(64).toRadixString(16).padLeft(16, '0');
    return (a + b).substring(0, len);
  }
}
