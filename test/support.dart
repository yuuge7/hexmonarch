import 'dart:math' as math;

import 'package:hexmonarch/domain/balance.dart';
import 'package:hexmonarch/domain/models.dart';
import 'package:hexmonarch/domain/world.dart';
import 'package:hexmonarch/geo/hex_grid.dart';
import 'package:latlong2/latlong.dart';

/// Lattice stand-in for H3 so the engine runs in plain `flutter test`.
/// Cells are `r<res>/<q>:<r>`; each coarser resolution is 3x wider, with
/// res 9 at ~330 m like the real thing.
class FakeGrid extends HexGrid {
  static double _step(int res) => 0.003 * math.pow(3, kPlayRes - res);

  (int, int, int) _parse(String c) {
    final slash = c.indexOf('/');
    final res = int.parse(c.substring(1, slash));
    final p = c.substring(slash + 1).split(':');
    return (res, int.parse(p[0]), int.parse(p[1]));
  }

  String _id(int res, int q, int r) => 'r$res/$q:$r';

  @override
  String cellAt(double lat, double lng, [int res = kPlayRes]) {
    final s = _step(res);
    return _id(res, (lng / s).round(), (lat / s).round());
  }

  @override
  String parent(String cell, int res) {
    final c = center(cell);
    return cellAt(c.latitude, c.longitude, res);
  }

  @override
  List<List<String>> diskRings(String cell, int k) {
    final (res, q0, r0) = _parse(cell);
    final rings = List.generate(k + 1, (_) => <String>[]);
    for (var dq = -k; dq <= k; dq++) {
      for (var dr = -k; dr <= k; dr++) {
        rings[math.max(dq.abs(), dr.abs())].add(_id(res, q0 + dq, r0 + dr));
      }
    }
    return rings;
  }

  @override
  LatLng center(String cell) {
    final (res, q, r) = _parse(cell);
    final s = _step(res);
    return LatLng(r * s, q * s);
  }

  @override
  List<LatLng> boundary(String cell) {
    final c = center(cell);
    final (res, _, _) = _parse(cell);
    final h = _step(res) / 2;
    return [
      LatLng(c.latitude - h, c.longitude - h),
      LatLng(c.latitude - h, c.longitude + h),
      LatLng(c.latitude + h, c.longitude + h),
      LatLng(c.latitude + h, c.longitude - h),
    ];
  }
}

PlayerData freshPlayer({int seed = 42, int now = 0}) => PlayerData(
      credits: kStartCredits,
      materials: kStartMaterials,
      intel: kStartIntel,
      keys: 0,
      level: 1,
      xp: 0,
      lastLat: null,
      lastLng: null,
      lastSync: now,
      monotonic: 0,
      worldSeed: seed,
      bootCount: 1,
      wallAtSync: now,
      tamperStrikes: 0,
      blueprints: 0,
      liquidations: 0,
      lifetimeCredits: 0,
      lastEventDay: now ~/ kDay,
      heat: 0,
      createdAt: now,
      settings: {},
    );

World freshWorld({int seed = 42, int now = 0}) => World(
      grid: FakeGrid(),
      player: freshPlayer(seed: seed, now: now),
      turfs: {},
      installed: {},
      stash: [],
      events: [],
      factions: [
        for (var i = 0; i < 3; i++) Faction(id: 'rival$i', archetype: i, aggression: 1.0),
      ],
      vaultRanks: {},
    );

/// First point (walking east from [lat],[lng]) with no turf within spacing.
(double, double) openSpot(World w, [double lat = 0, double lng = 0]) {
  for (var i = 0; i < 4000; i++) {
    final ln = lng + i * 0.0005;
    if (w.nearest(lat, ln, withinM: kTurfSpacingM) == null) return (lat, ln);
  }
  throw StateError('no open ground');
}

/// Nearest day-one rival turf around a point.
Turf firstRival(World w, [double lat = 0, double lng = 0]) {
  for (final t in w.turfsNear(lat, lng, 5000)) {
    if (t.isHostile) return t;
  }
  throw StateError('no rival turf nearby');
}
