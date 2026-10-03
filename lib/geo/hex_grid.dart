import 'dart:math' as math;

import 'package:h3_flutter/h3_flutter.dart';
import 'package:latlong2/latlong.dart';

/// Resolution of the genetics block every turf inherits from (street level).
const kPlayRes = 9;

/// Resolution of the unique turf key (~25 m cells; turfs are 60-100 m apart).
const kTurfKeyRes = 11;

/// Macro Districts: town-sized cells (~17 km across). Trade multiplier and
/// lockdowns work on these.
const kDistrictRes = 5;

/// Regions: county-scale cells (~45 km across). The prestige gate counts these.
const kRegionRes = 4;

/// Spatial index abstraction. Production uses Uber H3 via FFI; tests use a
/// pure-Dart axial grid so the engine can be verified off-device.
abstract class HexGrid {
  String cellAt(double lat, double lng, [int res = kPlayRes]);
  String parent(String cell, int res);

  /// Rings around [cell]: index i holds every cell at grid distance i.
  List<List<String>> diskRings(String cell, int k);

  List<String> disk(String cell, int k) => [for (final r in diskRings(cell, k)) ...r];

  LatLng center(String cell);
  List<LatLng> boundary(String cell);

  double km(String a, String b) => haversineKm(center(a), center(b));
}

double haversineKm(LatLng a, LatLng b) {
  const r = 6371.0088;
  final dLat = (b.latitude - a.latitude) * math.pi / 180;
  final dLng = (b.longitude - a.longitude) * math.pi / 180;
  final la1 = a.latitude * math.pi / 180;
  final la2 = b.latitude * math.pi / 180;
  final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(la1) * math.cos(la2) * math.sin(dLng / 2) * math.sin(dLng / 2);
  return 2 * r * math.asin(math.min(1, math.sqrt(h)));
}

double metersBetween(double lat1, double lng1, double lat2, double lng2) =>
    haversineKm(LatLng(lat1, lng1), LatLng(lat2, lng2)) * 1000;

/// Point [distanceM] away from [p] along [bearing] (radians, 0 = north).
LatLng offsetLatLng(LatLng p, double bearing, double distanceM) {
  const r = 6371008.8;
  final d = distanceM / r;
  final la1 = p.latitude * math.pi / 180;
  final lo1 = p.longitude * math.pi / 180;
  final la2 = math.asin(math.sin(la1) * math.cos(d) + math.cos(la1) * math.sin(d) * math.cos(bearing));
  final lo2 = lo1 + math.atan2(math.sin(bearing) * math.sin(d) * math.cos(la1), math.cos(d) - math.sin(la1) * math.sin(la2));
  return LatLng(la2 * 180 / math.pi, lo2 * 180 / math.pi);
}

class _Lru<K, V> {
  _Lru(this.capacity);
  final int capacity;
  final _map = <K, V>{}; // insertion-ordered (LinkedHashMap)

  V putIfAbsent(K key, V Function() build) {
    final existing = _map.remove(key);
    if (existing != null) {
      _map[key] = existing;
      return existing;
    }
    final v = build();
    _map[key] = v;
    if (_map.length > capacity) _map.remove(_map.keys.first);
    return v;
  }
}

class H3Grid extends HexGrid {
  H3Grid() : _h3 = const H3Factory().load();

  final H3 _h3;
  final _centers = _Lru<String, LatLng>(8000);
  final _bounds = _Lru<String, List<LatLng>>(6000);
  final _parents = _Lru<String, String>(20000);

  static BigInt _idx(String s) => BigInt.parse(s, radix: 16);
  static String _str(BigInt b) => b.toRadixString(16);

  @override
  String cellAt(double lat, double lng, [int res = kPlayRes]) =>
      _str(_h3.geoToCell(GeoCoord(lat: lat, lon: lng), res));

  @override
  String parent(String cell, int res) =>
      _parents.putIfAbsent('$cell/$res', () => _str(_h3.cellToParent(_idx(cell), res)));

  @override
  List<List<String>> diskRings(String cell, int k) {
    final rings = _h3.gridDiskDistances(_idx(cell), k);
    return [
      for (final r in rings) [for (final c in r) if (c != BigInt.zero) _str(c)],
    ];
  }

  @override
  LatLng center(String cell) => _centers.putIfAbsent(cell, () {
        final g = _h3.cellToGeo(_idx(cell));
        return LatLng(g.lat, g.lon);
      });

  @override
  List<LatLng> boundary(String cell) => _bounds.putIfAbsent(cell, () {
        return [for (final g in _h3.cellToBoundary(_idx(cell))) LatLng(g.lat, g.lon)];
      });
}
