import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

/// OpenFreeMap: keyless OpenMapTiles vector tiles (OSM data, ODbL). The
/// TileJSON gives the current versioned URL template; tiles are stored under a
/// version-agnostic z/x/y key so the cache survives upstream rebuilds.
const kTileJsonUrl = 'https://tiles.openfreemap.org/planet';
const kUserAgent = 'HexMonarch/1.0 (offline vector tile cache)';

/// OpenMapTiles planet builds stop at z14; the renderer overzooms beyond.
const kVectorMaxZoom = 14;

/// Permanent on-disk vector tile store. Once a tile is fetched it is served
/// from disk forever, so gameplay and the map run fully offline afterwards.
class TileCache {
  TileCache._(this.root);
  final Directory root;
  final _client = http.Client();
  String? _template;
  Future<String?>? _resolving;

  static Future<TileCache> open() async {
    final base = await getApplicationSupportDirectory();
    final legacy = Directory(p.join(base.path, 'tiles'));
    if (legacy.existsSync()) legacy.deleteSync(recursive: true);
    final dir = Directory(p.join(base.path, 'vtiles'));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    final cache = TileCache._(dir);
    final saved = File(p.join(dir.path, 'template.txt'));
    if (saved.existsSync()) cache._template = saved.readAsStringSync().trim();
    return cache;
  }

  File fileFor(int z, int x, int y) => File(p.join(root.path, '$z', '$x', '$y.pbf'));

  /// Current URL template from TileJSON (refreshed once per session).
  Future<String?> template() {
    return _resolving ??= () async {
      try {
        final res = await _client
            .get(Uri.parse(kTileJsonUrl), headers: {'User-Agent': kUserAgent})
            .timeout(const Duration(seconds: 8));
        if (res.statusCode == 200) {
          final json = jsonDecode(res.body) as Map<String, dynamic>;
          final t = (json['tiles'] as List).first as String;
          _template = t;
          await File(p.join(root.path, 'template.txt')).writeAsString(t);
        }
      } catch (_) {
        // Offline: keep the last known template (or none).
      }
      return _template;
    }();
  }

  Future<Uint8List?> read(int z, int x, int y, {bool network = true}) async {
    final f = fileFor(z, x, y);
    if (f.existsSync()) return f.readAsBytes();
    if (!network) return null;
    final t = _template ?? await template();
    if (t == null) return null;
    try {
      final url = t.replaceAll('{z}', '$z').replaceAll('{x}', '$x').replaceAll('{y}', '$y');
      final res = await _client
          .get(Uri.parse(url), headers: {'User-Agent': kUserAgent})
          .timeout(const Duration(seconds: 12));
      if (res.statusCode == 404 || res.statusCode == 204) {
        // Legitimately empty tile (open sea etc).
        await f.parent.create(recursive: true);
        await f.writeAsBytes(const []);
        return Uint8List(0);
      }
      if (res.statusCode != 200) return null;
      await f.parent.create(recursive: true);
      await f.writeAsBytes(res.bodyBytes, flush: false);
      return res.bodyBytes;
    } catch (_) {
      return null;
    }
  }

  /// Tile coordinates covering a [radiusKm] circle for zooms [minZ]..[maxZ].
  static List<(int, int, int)> tilesAround(double lat, double lng, double radiusKm,
      {int minZ = 8, int maxZ = kVectorMaxZoom}) {
    final out = <(int, int, int)>[];
    final dLat = radiusKm / 110.574;
    final dLng = radiusKm / (111.320 * math.cos(lat * math.pi / 180));
    for (var z = minZ; z <= maxZ; z++) {
      final x0 = _lngToX(lng - dLng, z), x1 = _lngToX(lng + dLng, z);
      final y0 = _latToY(lat + dLat, z), y1 = _latToY(lat - dLat, z);
      for (var x = x0; x <= x1; x++) {
        for (var y = y0; y <= y1; y++) {
          out.add((z, x, y));
        }
      }
    }
    return out;
  }

  static int _lngToX(double lng, int z) => ((lng + 180) / 360 * (1 << z)).floor();
  static int _latToY(double lat, int z) {
    final r = lat * math.pi / 180;
    return ((1 - math.log(math.tan(r) + 1 / math.cos(r)) / math.pi) / 2 * (1 << z)).floor();
  }

  /// Downloads everything around a point on 4 lanes. Reports (done, total).
  Future<int> precache(double lat, double lng, double radiusKm, void Function(int, int) progress) async {
    await template();
    final tiles = tilesAround(lat, lng, radiusKm);
    var done = 0, ok = 0, cursor = 0;
    Future<void> lane() async {
      while (cursor < tiles.length) {
        final (z, x, y) = tiles[cursor++];
        if (await read(z, x, y) != null) ok++;
        done++;
        progress(done, tiles.length);
      }
    }

    await Future.wait([for (var i = 0; i < 4; i++) lane()]);
    return ok;
  }

  Future<(int, int)> stats() async {
    var count = 0, bytes = 0;
    if (!root.existsSync()) return (0, 0);
    await for (final e in root.list(recursive: true, followLinks: false)) {
      if (e is File && e.path.endsWith('.pbf')) {
        count++;
        bytes += await e.length();
      }
    }
    return (count, bytes);
  }
}

/// Feeds vector_map_tiles from the permanent disk cache (network on miss).
class OfflineVectorProvider extends VectorTileProvider {
  OfflineVectorProvider(this.cache);
  final TileCache cache;

  @override
  Future<Uint8List> provide(TileIdentity tile) async {
    final bytes = await cache.read(tile.z, tile.x, tile.y);
    if (bytes == null) {
      throw ProviderException(message: 'tile ${tile.z}/${tile.x}/${tile.y} not cached', retryable: Retryable.retry);
    }
    return bytes;
  }

  @override
  int get maximumZoom => kVectorMaxZoom;

  @override
  int get minimumZoom => 0;

  @override
  TileOffset get tileOffset => TileOffset.DEFAULT;
}

/// The custom monochrome styles bundled in assets/map: the dark tactical one,
/// or the white one for reading the screen in direct sunlight.
Future<vtr.Theme> loadTacticalTheme({bool light = false}) async {
  final raw = await rootBundle.loadString('assets/map/tactical_style${light ? '_light' : ''}.json');
  return vtr.ThemeReader().read(jsonDecode(raw) as Map<String, dynamic>);
}
