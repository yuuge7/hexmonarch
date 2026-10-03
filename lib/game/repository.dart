import 'dart:convert';

import 'package:drift/drift.dart';

import '../core/rng.dart';
import '../data/database.dart';
import '../domain/balance.dart';
import '../domain/models.dart';
import '../domain/world.dart';
import '../geo/hex_grid.dart';

/// Maps drift rows <-> in-memory World and flushes dirty state in one batch.
class Repository {
  Repository(this.db);
  final HexDatabase db;

  late HexGrid _grid;

  Future<World> load(HexGrid grid, {required int now, required int seed, required int elapsed}) async {
    _grid = grid;
    var row = await (db.select(db.playerState)..where((t) => t.id.equals(1))).getSingleOrNull();
    if (row == null) {
      await db.into(db.playerState).insert(PlayerStateCompanion.insert(
            id: const Value(1),
            lastSyncTimestamp: now,
            monotonicUptime: elapsed,
            worldSeed: seed,
            createdAt: now,
            wallAtSync: Value(now),
            lastEventDay: Value(now ~/ kDay - 1),
          ));
      final rng = Rng(seed ^ 0xFAC7);
      await db.batch((b) {
        for (var i = 0; i < 3; i++) {
          b.insert(
            db.factions,
            FactionsCompanion.insert(
              factionId: 'rival$i',
              archetype: i,
              aggression: rng.range(0.75, 1.3),
            ),
          );
        }
      });
      row = await (db.select(db.playerState)..where((t) => t.id.equals(1))).getSingle();
    }

    final hexRows = await db.select(db.hexNodes).get();
    final modRows = await db.allInstalled().get();
    final stashRows = await db.allStash().get();
    final eventRows = await db.allEvents().get();
    final factionRows = await db.select(db.factions).get();
    final vaultRows = await db.select(db.vaultUpgrades).get();
    final perkRows = await db.select(db.streetPerks).get();
    final jobRows = await db.select(db.jobProgress).get();

    final turfs = <String, Turf>{for (final r in hexRows) r.h3Index: _turf(r)};
    final installed = <String, List<Module>>{};
    for (final r in modRows) {
      (installed[r.hexH3Index] ??= []).add(Module(
        id: r.id,
        name: r.moduleName,
        rarity: Rarity.fromKey(r.rarity),
        cashMult: r.statCashMult,
        defMult: r.statDefMult,
        itemLevel: r.itemLevel,
        perk: Perk.fromKey(r.specialPerk),
        perkValue: r.perkValue,
        hexId: r.hexH3Index,
        socket: r.socketIndex,
      ));
    }
    final stash = [
      for (final r in stashRows)
        Module(
          id: r.id,
          name: r.moduleName,
          rarity: Rarity.fromKey(r.rarity),
          cashMult: r.statCashMult,
          defMult: r.statDefMult,
          itemLevel: r.itemLevel,
          perk: Perk.fromKey(r.specialPerk),
          perkValue: r.perkValue,
          acquiredAt: r.acquiredAt,
        ),
    ];
    final events = <WorldEvent>[];
    for (final r in eventRows) {
      final t = EventType.fromKey(r.eventType);
      if (t == null) continue;
      events.add(WorldEvent(
        id: r.eventId,
        type: t,
        target: r.targetH3Index,
        expiresAt: r.expiresAt,
        payload: (jsonDecode(r.payloadJson) as Map).cast<String, dynamic>(),
      ));
    }

    final world = World(
      grid: grid,
      player: _player(row),
      turfs: turfs,
      installed: installed,
      stash: stash,
      events: events,
      factions: [
        for (final f in factionRows)
          Faction(
            id: f.factionId,
            archetype: f.archetype,
            aggression: f.aggression,
            nemesisRank: f.nemesisRank,
            wins: f.wins,
            losses: f.losses,
          ),
      ],
      vaultRanks: {for (final v in vaultRows) v.upgradeId: v.rank},
      perkRanks: {for (final r in perkRows) r.perkId: r.rank},
      jobRuns: {for (final r in jobRows) r.jobId: r.runs},
    );

    // Districts are derived from the turf's point. If the district resolution
    // changed since the row was written, rewrite it and drop stale lockdowns.
    final stale = [
      for (final r in hexRows)
        if (r.districtRes6 != world.turfs[r.h3Index]!.district) r.h3Index,
    ];
    if (stale.isNotEmpty) {
      for (final id in stale) {
        world.markTurf(world.turfs[id]!);
      }
      world.events.removeWhere((e) => e.type == EventType.lockdown);
      world.eventsDirty = true;
      world.reindex();
    }
    return world;
  }

  Turf _turf(HexRow r) => Turf(
        id: r.h3Index,
        block: _grid.parent(r.h3Index, kPlayRes),
        district: _grid.cellAt(r.turfLat, r.turfLng, kDistrictRes),
        lat: r.turfLat,
        lng: r.turfLng,
        name: r.turfName,
        biome: Biome.fromKey(r.biomeType),
        anomaly: Anomaly.fromKey(r.anomalyTrait),
        owner: r.owner,
        isStation: r.isStation,
        garrison: r.garrisonLevel,
        integrity: r.structuralIntegrity,
        isHub: r.isAnchorHub,
        hubLevel: r.hubLevel,
        relayTarget: r.connectedRelayTarget,
        lastTick: r.lastTickTimestamp,
        capturedAt: r.capturedAt,
      );

  PlayerData _player(PlayerRow r) => PlayerData(
        credits: r.credits,
        materials: r.materials,
        intel: r.intel,
        keys: r.prestigeKeys,
        level: r.level,
        xp: r.xp,
        lastLat: r.lastKnownLat,
        lastLng: r.lastKnownLng,
        lastSync: r.lastSyncTimestamp,
        monotonic: r.monotonicUptime,
        worldSeed: r.worldSeed,
        bootCount: r.bootCount,
        wallAtSync: r.wallAtSync,
        tamperStrikes: r.tamperStrikes,
        blueprints: r.blueprints,
        liquidations: r.liquidations,
        lifetimeCredits: r.lifetimeCredits,
        lastEventDay: r.lastEventDay,
        heat: r.threatHeat,
        createdAt: r.createdAt,
        settings: (jsonDecode(r.settingsJson) as Map).cast<String, dynamic>(),
        energy: r.energy,
      );

  InstalledModulesCompanion _installedRow(Module m) => InstalledModulesCompanion.insert(
        id: m.id,
        hexH3Index: m.hexId!,
        socketIndex: m.socket,
        moduleName: m.name,
        rarity: m.rarity.key,
        statCashMult: Value(m.cashMult),
        statDefMult: Value(m.defMult),
        specialPerk: Value(m.perk?.key),
        perkValue: Value(m.perkValue),
        itemLevel: Value(m.itemLevel),
      );

  ModuleStashCompanion _stashRow(Module m) => ModuleStashCompanion.insert(
        id: m.id,
        moduleName: m.name,
        rarity: m.rarity.key,
        statCashMult: Value(m.cashMult),
        statDefMult: Value(m.defMult),
        specialPerk: Value(m.perk?.key),
        perkValue: Value(m.perkValue),
        itemLevel: Value(m.itemLevel),
        acquiredAt: m.acquiredAt,
      );

  /// Single transaction: player row + every dirty table.
  Future<void> flush(World w) async {
    final p = w.player;
    final dirty = [for (final id in w.dirtyTurfs) w.turfs[id]].whereType<Turf>().toList();
    final deleted = w.deletedTurfs.toList();
    final modulesDirty = w.modulesDirty;
    final eventsDirty = w.eventsDirty;
    final factionsDirty = w.factionsDirty;
    final vaultDirty = w.vaultDirty;
    final perksDirty = w.perksDirty;
    final jobsDirty = w.jobsDirty;
    final logs = List.of(w.pendingLog);
    final installed = modulesDirty ? [for (final l in w.installed.values) ...l] : const <Module>[];
    final stash = modulesDirty ? List.of(w.stash) : const <Module>[];
    final events = eventsDirty ? List.of(w.events) : const <WorldEvent>[];

    w.dirtyTurfs.clear();
    w.deletedTurfs.clear();
    w.modulesDirty = false;
    w.eventsDirty = false;
    w.factionsDirty = false;
    w.vaultDirty = false;
    w.perksDirty = false;
    w.jobsDirty = false;
    w.pendingLog.clear();

    await db.transaction(() async {
      await db.batch((b) {
        b.insertAllOnConflictUpdate(db.playerState, [
          PlayerStateCompanion.insert(
            id: const Value(1),
            credits: Value(p.credits),
            materials: Value(p.materials),
            intel: Value(p.intel),
            prestigeKeys: Value(p.keys),
            level: Value(p.level),
            xp: Value(p.xp),
            lastKnownLat: Value(p.lastLat),
            lastKnownLng: Value(p.lastLng),
            lastSyncTimestamp: p.lastSync,
            monotonicUptime: p.monotonic,
            worldSeed: p.worldSeed,
            bootCount: Value(p.bootCount),
            wallAtSync: Value(p.wallAtSync),
            tamperStrikes: Value(p.tamperStrikes),
            blueprints: Value(p.blueprints),
            liquidations: Value(p.liquidations),
            lifetimeCredits: Value(p.lifetimeCredits),
            lastEventDay: Value(p.lastEventDay),
            threatHeat: Value(p.heat),
            createdAt: p.createdAt,
            settingsJson: Value(jsonEncode(p.settings)),
            energy: Value(p.energy),
          ),
        ]);

        if (deleted.isNotEmpty) {
          b.deleteWhere(db.hexNodes, (t) => t.h3Index.isIn(deleted));
        }
        if (dirty.isNotEmpty) {
          b.insertAllOnConflictUpdate(db.hexNodes, [
            for (final h in dirty)
              HexNodesCompanion.insert(
                h3Index: h.id,
                districtRes6: h.district,
                biomeType: h.biome.key,
                anomalyTrait: Value(h.anomaly?.key),
                owner: Value(h.owner),
                garrisonLevel: Value(h.garrison),
                structuralIntegrity: Value(h.integrity),
                isAnchorHub: Value(h.isHub),
                connectedRelayTarget: Value(h.relayTarget),
                lastTickTimestamp: h.lastTick,
                turfLat: h.lat,
                turfLng: h.lng,
                turfName: h.name,
                isStation: Value(h.isStation),
                hubLevel: Value(h.hubLevel),
                capturedAt: Value(h.capturedAt),
              ),
          ]);
        }
        if (modulesDirty) {
          b.deleteAll(db.installedModules);
          b.deleteAll(db.moduleStash);
          b.insertAll(db.installedModules, [for (final m in installed) _installedRow(m)]);
          b.insertAll(db.moduleStash, [for (final m in stash) _stashRow(m)]);
        }
        if (eventsDirty) {
          b.deleteAll(db.activeWorldEvents);
          b.insertAll(db.activeWorldEvents, [
            for (final e in events)
              ActiveWorldEventsCompanion.insert(
                eventId: e.id,
                eventType: e.type.key,
                targetH3Index: e.target,
                expiresAt: e.expiresAt,
                payloadJson: jsonEncode(e.payload),
              ),
          ]);
        }
        if (factionsDirty) {
          b.insertAllOnConflictUpdate(db.factions, [
            for (final f in w.factions)
              FactionsCompanion.insert(
                factionId: f.id,
                archetype: f.archetype,
                aggression: f.aggression,
                nemesisRank: Value(f.nemesisRank),
                wins: Value(f.wins),
                losses: Value(f.losses),
              ),
          ]);
        }
        if (vaultDirty) {
          b.insertAllOnConflictUpdate(db.vaultUpgrades, [
            for (final e in w.vaultRanks.entries)
              VaultUpgradesCompanion.insert(upgradeId: e.key, rank: Value(e.value)),
          ]);
        }
        if (perksDirty) {
          b.insertAllOnConflictUpdate(db.streetPerks, [
            for (final e in w.perkRanks.entries) StreetPerksCompanion.insert(perkId: e.key, rank: Value(e.value)),
          ]);
        }
        if (jobsDirty) {
          b.insertAllOnConflictUpdate(db.jobProgress, [
            for (final e in w.jobRuns.entries) JobProgressCompanion.insert(jobId: e.key, runs: Value(e.value)),
          ]);
        }
        if (logs.isNotEmpty) {
          b.insertAll(db.eventLog, [
            for (final l in logs) EventLogCompanion.insert(ts: l.ts, kind: l.kind, message: l.message),
          ]);
        }
      });
      if (logs.isNotEmpty) await db.trimLog();
    });
  }

  Future<List<LogRow>> recentLog([int limit = 80]) => db.recentLog(lim: limit).get();

  // ------------------------------------------------------------ save transfer

  /// Every table as plain JSON rows. Call [flush] first.
  Future<Map<String, dynamic>> exportTables() async => {
        'player_state': [for (final r in await db.select(db.playerState).get()) r.toJson()],
        'hex_nodes': [for (final r in await db.select(db.hexNodes).get()) r.toJson()],
        'installed_modules': [for (final r in await db.select(db.installedModules).get()) r.toJson()],
        'module_stash': [for (final r in await db.select(db.moduleStash).get()) r.toJson()],
        'active_world_events': [for (final r in await db.select(db.activeWorldEvents).get()) r.toJson()],
        'factions': [for (final r in await db.select(db.factions).get()) r.toJson()],
        'vault_upgrades': [for (final r in await db.select(db.vaultUpgrades).get()) r.toJson()],
        'street_perks': [for (final r in await db.select(db.streetPerks).get()) r.toJson()],
        'job_progress': [for (final r in await db.select(db.jobProgress).get()) r.toJson()],
        'event_log': [for (final r in await db.recentLog(lim: 200).get()) r.toJson()],
      };

  /// Columns added after save format 1, with the value older saves get.
  static const _columnDefaults = <String, Map<String, Object?>>{
    'player_state': {'energy': 30.0},
  };

  /// Replaces the whole database with [tables] (from [exportTables]). All or
  /// nothing: a malformed save throws before anything is deleted.
  Future<void> importTables(Map<String, dynamic> tables) async {
    List<Map<String, dynamic>> rows(String name) => [
          for (final r in (tables[name] as List? ?? const []))
            {...?_columnDefaults[name], ...(r as Map).cast<String, dynamic>()},
        ];

    final players = [for (final r in rows('player_state')) PlayerRow.fromJson(r)];
    if (players.length != 1) throw const FormatException('Save has no player record');
    final hexes = [for (final r in rows('hex_nodes')) HexRow.fromJson(r)];
    final installed = [for (final r in rows('installed_modules')) InstalledModuleRow.fromJson(r)];
    final stash = [for (final r in rows('module_stash')) StashRow.fromJson(r)];
    final events = [for (final r in rows('active_world_events')) WorldEventRow.fromJson(r)];
    final factions = [for (final r in rows('factions')) FactionRow.fromJson(r)];
    final vault = [for (final r in rows('vault_upgrades')) VaultUpgradeRow.fromJson(r)];
    final perks = [for (final r in rows('street_perks')) StreetPerkRow.fromJson(r)];
    final jobs = [for (final r in rows('job_progress')) JobProgressRow.fromJson(r)];
    final logs = [for (final r in rows('event_log')) LogRow.fromJson(r)];

    await db.transaction(() async {
      await db.batch((b) {
        b.deleteAll(db.eventLog);
        b.deleteAll(db.jobProgress);
        b.deleteAll(db.streetPerks);
        b.deleteAll(db.vaultUpgrades);
        b.deleteAll(db.factions);
        b.deleteAll(db.activeWorldEvents);
        b.deleteAll(db.moduleStash);
        b.deleteAll(db.installedModules);
        b.deleteAll(db.hexNodes);
        b.deleteAll(db.playerState);
        b.insertAll(db.playerState, players);
        b.insertAll(db.hexNodes, hexes);
        b.insertAll(db.installedModules, installed);
        b.insertAll(db.moduleStash, stash);
        b.insertAll(db.activeWorldEvents, events);
        b.insertAll(db.factions, factions);
        b.insertAll(db.vaultUpgrades, vault);
        b.insertAll(db.streetPerks, perks);
        b.insertAll(db.jobProgress, jobs);
        b.insertAll(db.eventLog, logs);
      });
    });
  }
}
