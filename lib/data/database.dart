import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

@DriftDatabase(include: {'schema.drift'})
class HexDatabase extends _$HexDatabase {
  HexDatabase(super.e);

  /// On-device database tuned for batched simulation writes: WAL journal,
  /// relaxed fsync, in-memory temp tables, 8 MB page cache.
  static Future<HexDatabase> open() async {
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'hexmonarch.sqlite'));
    final executor = NativeDatabase.createInBackground(
      file,
      setup: (raw) {
        raw.execute('PRAGMA journal_mode = WAL;');
        raw.execute('PRAGMA synchronous = NORMAL;');
        raw.execute('PRAGMA temp_store = MEMORY;');
        raw.execute('PRAGMA cache_size = -8000;');
        raw.execute('PRAGMA foreign_keys = ON;');
      },
    );
    return HexDatabase(executor);
  }

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // v1 used grid-cell territory; v2 is point turfs. Pre-release data
            // is not migrated: rebuild every table.
            for (final name in const [
              'event_log', 'vault_upgrades', 'factions', 'player_state',
              'active_world_events', 'module_stash', 'installed_modules', 'hex_nodes',
            ]) {
              await m.deleteTable(name);
            }
            await m.createAll();
            return;
          }
          // From here on every upgrade keeps the save.
          if (from < 3) {
            await m.createTable(streetPerks);
            await m.createTable(jobProgress);
            await m.addColumn(playerState, playerState.energy);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
