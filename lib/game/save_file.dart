import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// Portable save file: gzip(JSON). Tables are stored as plain rows, so a save
/// written by an older version of the game still loads after schema changes
/// (missing columns get defaults in Repository.importTables).
class SaveFile {
  static const appTag = 'hexmonarch';

  /// Bump only when the envelope itself changes shape.
  static const format = 1;

  static Uint8List encode({
    required Map<String, dynamic> tables,
    required int schemaVersion,
    required int exportedAt,
  }) {
    final json = jsonEncode({
      'app': appTag,
      'format': format,
      'schema': schemaVersion,
      'exportedAt': exportedAt,
      'tables': tables,
    });
    return Uint8List.fromList(gzip.encode(utf8.encode(json)));
  }

  /// Returns the tables map. Throws [FormatException] with a readable reason
  /// when the file is not a HexMonarch save or comes from a newer game.
  static Map<String, dynamic> decode(Uint8List bytes, {required int schemaVersion}) {
    if (bytes.length < 2) throw const FormatException('That file is empty');
    List<int> raw = bytes;
    if (bytes[0] == 0x1f && bytes[1] == 0x8b) {
      try {
        raw = gzip.decode(bytes);
      } catch (_) {
        throw const FormatException('That file is damaged');
      }
    }
    final Object? parsed;
    try {
      parsed = jsonDecode(utf8.decode(raw));
    } catch (_) {
      throw const FormatException('That file is not a HexMonarch save');
    }
    if (parsed is! Map || parsed['app'] != appTag || parsed['tables'] is! Map) {
      throw const FormatException('That file is not a HexMonarch save');
    }
    final fmt = (parsed['format'] as num?)?.toInt() ?? 0;
    final schema = (parsed['schema'] as num?)?.toInt() ?? 0;
    if (fmt > format || schema > schemaVersion) {
      throw const FormatException('This save comes from a newer version of the game. Update the app first.');
    }
    return (parsed['tables'] as Map).cast<String, dynamic>();
  }

  static String fileName(int wallMs) {
    final d = DateTime.fromMillisecondsSinceEpoch(wallMs);
    String two(int v) => v.toString().padLeft(2, '0');
    return 'hexmonarch-${d.year}${two(d.month)}${two(d.day)}-${two(d.hour)}${two(d.minute)}.hexsave';
  }
}
