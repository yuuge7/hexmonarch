import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:vector_tile/vector_tile.dart';

import '../geo/hex_grid.dart';
import 'tile_cache.dart';

/// What a spot is called, read from the offline vector tiles.
class PlaceHit {
  const PlaceHit(this.name, {required this.isStation, required this.distanceM, this.localName});
  final String name;

  /// For station hits: what the exact spot is called (landmark or street), used
  /// when that station already has its station turf.
  final String? localName;

  /// True when the spot is at a transit station (rail, metro, tram, bus or
  /// ferry terminal, airport): those turfs get the station bonus.
  final bool isStation;
  final double distanceM;
}

const _kindStation = 0; // rail, metro, tram, airport
const _kindTransit = 4; // bus station, ferry terminal, cable car
const _kindPoi = 1;
const _kindStreet = 2;
const _kindPlace = 3;

class _Named {
  const _Named(this.name, this.kind, this.lat, this.lng);
  final String name;
  final int kind;
  final double lat;
  final double lng;
}

/// Names turfs after the nearest station, landmark, street or neighbourhood.
/// Works fully offline once the surrounding tile is cached.
class PlaceNamer {
  PlaceNamer(this.cache);
  final TileCache cache;

  static const stationRangeM = 250.0;
  static const _z = kVectorMaxZoom;

  final _parsed = <String, List<_Named>>{}; // tiny LRU of decoded tiles

  Future<PlaceHit?> lookup(double lat, double lng, {bool network = true}) async {
    // The point's tile plus any neighbour within ~300 m (stations sit on edges too).
    const dLat = 0.0027, dLng = 0.0045;
    final keys = <(int, int)>{
      for (final la in [lat - dLat, lat + dLat])
        for (final ln in [lng - dLng, lng + dLng]) (_x(ln), _y(la)),
    };
    final all = <_Named>[];
    for (final (x, y) in keys) {
      all.addAll(await _tile(x, y, network));
    }
    if (all.isEmpty) return null;

    _Named? best(int kind, double maxM) {
      _Named? hit;
      var bestD = maxM;
      for (final n in all) {
        if (n.kind != kind) continue;
        final d = metersBetween(lat, lng, n.lat, n.lng);
        if (d <= bestD) {
          bestD = d;
          hit = n;
        }
      }
      return hit;
    }

    PlaceHit make(_Named n, {bool station = false, String? local}) => PlaceHit(
          n.name,
          isStation: station,
          distanceM: metersBetween(lat, lng, n.lat, n.lng),
          localName: local,
        );

    final local = best(_kindPoi, 70) ?? best(_kindStreet, 120);

    // Rail beats a bus stand that happens to be a few metres closer.
    final station = best(_kindStation, stationRangeM) ?? best(_kindTransit, 150);
    final place = best(_kindPlace, 2500);
    if (station != null) return make(station, station: true, local: (local ?? place)?.name);
    if (local != null) return make(local);
    if (place != null) return make(place);
    return null;
  }

  Future<List<_Named>> _tile(int x, int y, bool network) async {
    final key = '$x/$y';
    final cached = _parsed.remove(key);
    if (cached != null) return _parsed[key] = cached;
    final bytes = await cache.read(_z, x, y, network: network);
    if (bytes == null || bytes.isEmpty) return const [];
    List<_Named> list;
    try {
      final raw = await compute(_extract, (bytes, x, y));
      list = [for (final r in raw) _Named(r.$1, r.$2, r.$3, r.$4)];
    } catch (_) {
      list = const [];
    }
    _parsed[key] = list;
    if (_parsed.length > 8) _parsed.remove(_parsed.keys.first);
    return list;
  }

  static int _x(double lng) => ((lng + 180) / 360 * (1 << _z)).floor();
  static int _y(double lat) {
    final r = lat * math.pi / 180;
    return ((1 - math.log(math.tan(r) + 1 / math.cos(r)) / math.pi) / 2 * (1 << _z)).floor();
  }
}

/// Runs in a background isolate: pulls named points out of an OpenMapTiles tile.
List<(String, int, double, double)> _extract((Uint8List, int, int) input) {
  final (bytes, tx, ty) = input;
  final tile = VectorTile.fromBytes(bytes: bytes);
  final out = <(String, int, double, double)>[];
  final n = (1 << kVectorMaxZoom).toDouble();

  (double, double) toLatLng(int px, int py, int extent) {
    final fx = (tx + px / extent) / n;
    final fy = (ty + py / extent) / n;
    final lng = fx * 360 - 180;
    final lat = math.atan(_sinh(math.pi * (1 - 2 * fy))) * 180 / math.pi;
    return (lat, lng);
  }

  for (final layer in tile.layers) {
    final lname = layer.name;
    if (lname != 'poi' && lname != 'transportation_name' && lname != 'place' && lname != 'aerodrome_label') {
      continue;
    }
    for (final f in layer.features) {
      final props = f.decodeProperties();
      final name = props['name']?.dartStringValue;
      if (name == null || name.isEmpty) continue;
      final cls = props['class']?.dartStringValue ?? '';
      final sub = props['subclass']?.dartStringValue ?? '';
      try {
        if (f.type == VectorTileGeomType.POINT) {
          final pts = f.decodePoint();
          if (pts.isEmpty) continue;
          final (lat, lng) = toLatLng(pts.first[0], pts.first[1], layer.extent);
          final int kind;
          if (lname == 'aerodrome_label') {
            kind = _kindStation;
          } else if (lname == 'place') {
            if (cls != 'suburb' && cls != 'neighbourhood' && cls != 'quarter' && cls != 'village' && cls != 'town') {
              continue;
            }
            kind = _kindPlace;
          } else if (lname == 'poi') {
            if (cls == 'railway' && sub != 'subway_entrance') {
              kind = _kindStation;
            } else if (sub == 'bus_station' || sub == 'ferry_terminal' || cls == 'aerialway') {
              kind = _kindTransit;
            } else {
              kind = _kindPoi;
            }
          } else {
            kind = _kindStreet;
          }
          out.add((name, kind, lat, lng));
        } else if (f.type == VectorTileGeomType.LINESTRING && lname == 'transportation_name') {
          for (final line in f.decodeLineString()) {
            // Every third vertex is plenty to find the nearest street.
            for (var i = 0; i < line.length; i += 3) {
              final (lat, lng) = toLatLng(line[i][0], line[i][1], layer.extent);
              out.add((name, _kindStreet, lat, lng));
            }
          }
        }
      } catch (_) {
        // Malformed geometry: skip the feature.
      }
    }
  }
  return out;
}

double _sinh(double x) => (math.exp(x) - math.exp(-x)) / 2;
