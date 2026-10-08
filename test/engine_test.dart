import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hexmonarch/core/format.dart';
import 'package:hexmonarch/core/rng.dart';
import 'package:hexmonarch/domain/actions.dart';
import 'package:hexmonarch/domain/balance.dart';
import 'package:hexmonarch/domain/forecast.dart';
import 'package:hexmonarch/domain/genetics.dart';
import 'package:hexmonarch/domain/jobs.dart';
import 'package:hexmonarch/domain/loot.dart';
import 'package:hexmonarch/domain/models.dart';
import 'package:hexmonarch/domain/perks.dart';
import 'package:hexmonarch/domain/simulation.dart';
import 'package:hexmonarch/domain/time_guard.dart';
import 'package:hexmonarch/domain/tiers.dart';
import 'package:hexmonarch/domain/vault.dart';
import 'package:hexmonarch/domain/world.dart';
import 'package:hexmonarch/game/save_file.dart';
import 'package:hexmonarch/geo/hex_grid.dart';

import 'support.dart';

void main() {
  group('hex genetics', () {
    test('deterministic per (cell, seed) and seed-sensitive', () {
      final a = genomeFor('89194ad14d7ffff', '88194ad14dfffff', 7);
      final b = genomeFor('89194ad14d7ffff', '88194ad14dfffff', 7);
      expect(a.biome, b.biome);
      expect(a.anomaly, b.anomaly);
      var differs = 0;
      for (var i = 0; i < 200; i++) {
        final c = 'cell$i';
        if (genomeFor(c, 'n${i ~/ 7}', 1).biome != genomeFor(c, 'n${i ~/ 7}', 2).biome) differs++;
      }
      expect(differs, greaterThan(40));
    });

    test('anomaly rate ~15%', () {
      var n = 0;
      const total = 20000;
      for (var i = 0; i < total; i++) {
        if (genomeFor('c$i', 'n${i ~/ 7}', 99).anomaly != null) n++;
      }
      expect(n / total, closeTo(kAnomalyChance, 0.015));
    });
  });

  group('loot', () {
    test('same seed, same module', () {
      final a = LootTable.roll(Rng(5), playerLevel: 10, maxHubLevel: 4, now: 0);
      final b = LootTable.roll(Rng(5), playerLevel: 10, maxHubLevel: 4, now: 0);
      expect(a.name, b.name);
      expect(a.cashMult, b.cashMult);
    });

    test('rarity distribution is sane and luck shifts it upward', () {
      int rarePlus(double luck) {
        final rng = Rng(11);
        var n = 0;
        for (var i = 0; i < 20000; i++) {
          if (LootTable.rollRarity(rng, luck: luck).index >= Rarity.rare.index) n++;
        }
        return n;
      }

      final base = rarePlus(0);
      expect(base / 20000, closeTo(0.18, 0.02));
      expect(rarePlus(0.5), greaterThan(base));
    });

    test('no stat ceiling: power keeps rising with item level', () {
      double best(int level) {
        final rng = Rng(level);
        var m = 0.0;
        for (var i = 0; i < 300; i++) {
          final mod = LootTable.roll(rng, playerLevel: level, maxHubLevel: level, now: 0);
          if (mod.cashMult + mod.defMult > m) m = mod.cashMult + mod.defMult;
        }
        return m;
      }

      expect(best(200), greaterThan(best(50)));
      expect(best(1000), greaterThan(best(200)));
    });

    test('minimum rarity respected', () {
      final rng = Rng(3);
      for (var i = 0; i < 500; i++) {
        expect(LootTable.rollRarity(rng, min: Rarity.rare).index, greaterThanOrEqualTo(Rarity.rare.index));
      }
    });
  });

  group('time guard', () {
    const anchor = SyncAnchor(gameTime: 1000000, wallAtSync: 5000000, elapsedAtSync: 200000, bootCount: 3);

    test('same boot trusts the monotonic clock', () {
      final v = evaluateClock(anchor, const ClockSample(wall: 5000000 + 3600000, elapsed: 200000 + 3600000, bootCount: 3));
      expect(v.tampered, isFalse);
      expect(v.deltaMs, 3600000);
      expect(v.gameNow, 1000000 + 3600000);
    });

    test('forward clock spoof is detected and ignored', () {
      final v = evaluateClock(
          anchor, const ClockSample(wall: 5000000 + 3 * kDay, elapsed: 200000 + 600000, bootCount: 3));
      expect(v.tampered, isTrue);
      expect(v.deltaMs, 600000);
      expect(v.fastForward, isTrue, reason: 'the clock was pushed ahead');

      // Five minutes of drift is still an anomaly, but nobody cheats for five minutes.
      final small = evaluateClock(
          anchor, const ClockSample(wall: 5000000 + 600000 + 5 * 60000, elapsed: 200000 + 600000, bootCount: 3));
      expect(small.tampered, isTrue);
      expect(small.fastForward, isFalse);
    });

    test('OS clock correction confirmed by network time is not a strike', () {
      const wall = 5000000 + 2 * kDay;
      final v = evaluateClock(
          anchor, const ClockSample(wall: wall, elapsed: 200000 + 600000, bootCount: 3, networkTime: wall + 900));
      expect(v.tampered, isFalse);
      expect(v.fastForward, isFalse);
      expect(v.deltaMs, 600000, reason: 'still only the monotonic delta is credited');
    });

    test('a save imported on another phone is re-anchored, never a strike', () {
      // Old phone: boot 12, up for 3 days. New phone happens to share the boot
      // count and has been up longer: without re-anchoring this reads as a
      // 2-day monotonic jump against a 10-minute wall delta.
      const saved = SyncAnchor(gameTime: 9000000, wallAtSync: 50000000, elapsedAtSync: 3 * kDay, bootCount: 12);
      const here = ClockSample(wall: 50000000 + 600000, elapsed: 5 * kDay, bootCount: 12);
      expect(evaluateClock(saved, here).tampered, isTrue, reason: 'the raw anchor would misfire');

      final v = evaluateClock(reanchorForImport(saved, here), here);
      expect(v.tampered, isFalse);
      expect(v.deltaMs, 600000);
      expect(v.gameNow, 9000000 + 600000);

      // Save "from the future" (new phone clock behind): no time, no strike.
      const behind = ClockSample(wall: 50000000 - kDay, elapsed: 1000, bootCount: 2);
      final v2 = evaluateClock(reanchorForImport(saved, behind), behind);
      expect(v2.tampered, isFalse);
      expect(v2.deltaMs, 0);

      // A very old save is capped.
      const later = ClockSample(wall: 50000000 + 400 * kDay, elapsed: 7 * kHour, bootCount: 40);
      expect(evaluateClock(reanchorForImport(saved, later), later).deltaMs, kImportMaxOfflineMs);
    });

    test('after reboot, a clock behind last sync is rejected', () {
      final v = evaluateClock(anchor, const ClockSample(wall: 5000000 - kDay, elapsed: 50000, bootCount: 4));
      expect(v.tampered, isTrue);
      expect(v.fastForward, isFalse, reason: 'a clock set back earns nothing to begin with');
      expect(v.deltaMs, 0);
    });

    test('after reboot, network time overrides a spoofed wall clock', () {
      final v = evaluateClock(
          anchor,
          const ClockSample(
              wall: 5000000 + 10 * kDay, elapsed: 50000, bootCount: 4, networkTime: 5000000 + 2 * kHour));
      expect(v.tampered, isTrue);
      expect(v.fastForward, isTrue);
      expect(v.deltaMs, 2 * kHour);
    });

    test('after an honest reboot, wall delta is accepted', () {
      final v = evaluateClock(anchor, const ClockSample(wall: 5000000 + 5 * kHour, elapsed: 50000, bootCount: 4));
      expect(v.tampered, isFalse);
      expect(v.deltaMs, 5 * kHour);
    });
  });

  group('turfs: plant, spacing, supply', () {
    test('a turf is planted at the exact spot, anywhere, with no adjacency rule', () {
      final w = freshWorld();
      final cmd = Commands(w);
      final (lat, lng) = openSpot(w);
      final out = cmd.claim(lat, lng, 0, name: 'Central Station', isStation: true);
      expect(out.ok, isTrue, reason: out.message);
      final t = w.playerTurfs.single;
      expect(t.lat, lat);
      expect(t.lng, lng);
      expect(t.name, 'Central Station');
      expect(t.isStation, isTrue);

      // A second turf 40 km away, unconnected: the hub-and-spoke promise.
      final (lat2, lng2) = openSpot(w, 0.36, 0.1);
      expect(cmd.claim(lat2, lng2, 0).ok, isTrue);
      expect(w.index.owned, 2);
    });

    test('turfs must keep their distance: 100 m', () {
      final w = freshWorld();
      final cmd = Commands(w);
      final (lat, lng) = openSpot(w);
      cmd.claim(lat, lng, 0);
      expect(kBaseSpacingM, 100);
      expect(kTurfSpacingM, 100);
      // ~55 m and ~89 m east: blocked.
      expect(cmd.claimQuote(lat, lng + 0.0005).blocker, isNotNull);
      expect(cmd.claimQuote(lat, lng + 0.0008).blocker, isNotNull);
      // ~111 m east is enough, as long as no rival crew sits there.
      final (lat2, lng2) = openSpot(w, lat, lng + 0.001);
      expect(metersBetween(lat, lng, lat2, lng2), greaterThanOrEqualTo(100));
      expect(cmd.claimQuote(lat2, lng2).blocker, isNull);
      // Two fresh turfs at minimum spacing touch, they do not overlap.
      expect(turfRadiusM(w.playerTurfs.single) * 2, lessThanOrEqualTo(kBaseSpacingM));
    });

    test('duplicate names get a numeral', () {
      final w = freshWorld();
      final cmd = Commands(w);
      final (lat, lng) = openSpot(w);
      cmd.claim(lat, lng, 0, name: 'High Street');
      final (lat2, lng2) = openSpot(w, lat, lng + 0.003);
      cmd.claim(lat2, lng2, 0, name: 'High Street');
      expect(w.playerTurfs.map((t) => t.name).toSet(), {'High Street', 'High Street II'});
    });

    test('a hub supplies turfs inside its sphere, not beyond', () {
      final w = freshWorld();
      final cmd = Commands(w);
      w.player.credits = 1e6;
      w.player.materials = 1e6;
      final (lat, lng) = openSpot(w);
      cmd.claim(lat, lng, 0);
      final hub = w.playerTurfs.single;
      expect(w.index.supplier.containsKey(hub.id), isFalse);
      expect(cmd.establishHub(hub.id, 0).ok, isTrue);
      expect(w.index.supplier[hub.id], hub.id);

      final (nLat, nLng) = openSpot(w, lat, lng + 0.004); // ~450 m
      cmd.claim(nLat, nLng, 0);
      final (fLat, fLng) = openSpot(w, lat, lng + 0.05); // ~5.5 km
      cmd.claim(fLat, fLng, 0);
      final near = w.playerTurfs.firstWhere((t) => t.lng == nLng);
      final far = w.playerTurfs.firstWhere((t) => t.lng == fLng);
      expect(w.index.supplier[near.id], hub.id);
      expect(w.index.supplier.containsKey(far.id), isFalse);
    });

    test('one hub holds a town: 2.5 km sphere at level 1, and hubs stay affordable', () {
      expect(hubRadiusKm(1), closeTo(2.5, 1e-9));
      expect(hubRadiusKm(9), closeTo(3.5, 1e-9));
      final w = freshWorld();
      final cmd = Commands(w);
      w.player.credits = 1e6;
      w.player.materials = 1e6;
      final (lat, lng) = openSpot(w);
      cmd.claim(lat, lng, 0);
      final hub = w.playerTurfs.single;
      cmd.establishHub(hub.id, 0);
      // A turf 2 km out, the other side of town, is still supplied.
      final (zLat, zLng) = openSpot(w, lat, lng + 0.018);
      cmd.claim(zLat, zLng, 0);
      final zone = w.playerTurfs.firstWhere((t) => t.id != hub.id);
      expect(w.kmBetween(hub, zone), inInclusiveRange(1.9, 2.4));
      expect(w.index.supplier[zone.id], hub.id);

      expect(hubEstablishCost(0, discount: 1).credits, 300);
      expect(hubEstablishCost(9, discount: 1).credits, lessThan(7000), reason: 'tenth hub');
      expect(hubEstablishCost(19, discount: 1).credits, lessThan(200000), reason: 'twentieth hub');
    });

    test('abandon lets the crew back in; delete clears the spot for good', () {
      final w = freshWorld(seed: 4);
      final cmd = Commands(w);
      final rival = firstRival(w);
      w.player.credits = 1e9;
      w.player.intel = 1e9;
      w.player.level = 200;
      var now = 0;
      void seize() {
        var ok = false;
        for (var i = 0; i < 60 && !ok; i++) {
          ok = cmd.breach(rival.id, rival.lat, rival.lng, now++, name: 'Old Depot').ok;
        }
        expect(ok, isTrue);
        expect(w.turfs[rival.id]!.isPlayer, isTrue);
      }

      // Abandon: the turf is gone and the crew that lived there returns.
      seize();
      expect(cmd.abandon(rival.id, now).ok, isTrue);
      expect(w.turfs.containsKey(rival.id), isFalse);
      expect(w.presetRival(rival.block)?.isHostile, isTrue);

      // Delete: nothing is left and nothing comes back.
      seize();
      expect(cmd.delete(rival.id, now).ok, isTrue);
      expect(w.turfs.containsKey(rival.id), isFalse);
      expect(w.deletedTurfs, contains(rival.id));
      expect(w.presetRival(rival.block), isNull);
      expect(w.turfById(rival.id), isNull);
      expect(w.turfsNear(rival.lat, rival.lng, 30), isEmpty);
      expect(w.razedNear(rival.lat, rival.lng, w.perks.spacingM), isTrue, reason: 'auto-plant must skip it');
      expect(cmd.delete(rival.id, now).ok, isFalse, reason: 'already gone');

      // The mark lives in the settings, so it survives a restart and a save export.
      final saved = (jsonDecode(jsonEncode(w.player.settings)) as Map).cast<String, dynamic>();
      final again = freshWorld(seed: 4)..player.settings.addAll(saved);
      expect(again.presetRival(rival.block), isNull);
      expect(again.razedNear(rival.lat, rival.lng, 10), isTrue);

      // Planting there by hand reopens the spot.
      expect(cmd.claim(rival.lat, rival.lng, now, name: 'Back Again').ok, isTrue);
      expect(w.razed, isEmpty);
      expect(w.player.settings[kRazedKey], isEmpty);
    });

    test('deleting a turf returns its modules and cuts relays pointing at it', () {
      final w = freshWorld(seed: 8);
      final cmd = Commands(w);
      w.player.credits = 1e9;
      w.player.materials = 1e9;
      w.player.intel = 1e9;
      final (aLat, aLng) = openSpot(w, 0, 0);
      final (bLat, bLng) = openSpot(w, 0, 0.05);
      cmd.claim(aLat, aLng, 0, name: 'A');
      cmd.claim(bLat, bLng, 0, name: 'B');
      final a = w.playerTurfs.firstWhere((t) => t.name == 'A');
      final b = w.playerTurfs.firstWhere((t) => t.name == 'B');
      cmd.establishHub(a.id, 0);
      cmd.establishHub(b.id, 0);
      expect(cmd.buildRelay(a.id, b.id, 0).ok, isTrue);
      final m = dropModule(w, Rng(1), 0);
      expect(cmd.install(m.id, b.id, 0).ok, isTrue);
      expect(w.stash, isEmpty);

      expect(cmd.delete(b.id, 1).ok, isTrue);
      expect(w.index.owned, 1);
      expect(a.relayTarget, isNull);
      expect(w.stash.single.id, m.id);
      expect(w.installed.containsKey(b.id), isFalse);
    });

    test('station turfs earn the station bonus', () {
      final w = freshWorld(seed: 77);
      final cmd = Commands(w);
      final (lat, lng) = openSpot(w);
      cmd.claim(lat, lng, 0, isStation: true);
      final t = w.playerTurfs.single;
      cmd.establishHub(t.id, 0);
      final withBonus = w.index.turfHourly[t.id]!.credits;
      t.isStation = false;
      w.reindex();
      expect(withBonus / w.index.turfHourly[t.id]!.credits, closeTo(kStationCreditBonus, 1e-9));
    });

    test('only one turf per station gets the station bonus', () {
      final w = freshWorld(seed: 78);
      final cmd = Commands(w);
      final (lat, lng) = openSpot(w);
      cmd.claim(lat, lng, 0, name: 'Grand Central', isStation: true);
      final (lat2, lng2) = openSpot(w, lat, lng + 0.002);
      cmd.claim(lat2, lng2, 0, name: 'Grand Central', isStation: true);
      final turfs = w.playerTurfs.toList();
      expect(turfs.where((t) => t.isStation), hasLength(1));
      expect(turfs.map((t) => t.name).toSet(), {'Grand Central', 'Grand Central II'});
    });

    test('rival turfs block planting and can be breached from inside their zone', () {
      final w = freshWorld(seed: 4);
      final cmd = Commands(w);
      final rival = firstRival(w);
      expect(cmd.claimQuote(rival.lat, rival.lng).blocker, isNotNull);
      // Too far away to breach.
      expect(cmd.breachQuote(rival, rival.lat + 0.01, rival.lng).blocker, isNotNull);
      w.player.credits = 1e9;
      w.player.intel = 1e9;
      w.player.level = 200; // overwhelming strike: ~95% odds
      var seized = false;
      for (var now = 0; now < 40 && !seized; now++) {
        seized = cmd.breach(rival.id, rival.lat, rival.lng, now, name: 'Old Depot').ok;
      }
      expect(seized, isTrue);
      final mine = w.turfs[rival.id]!;
      expect(mine.isPlayer, isTrue);
      expect(mine.name, 'Old Depot');
      expect(w.presetRival(rival.block), isNull, reason: 'the crew is gone while you hold it');
    });
  });

  group('simulation', () {
    World seeded(int seed) {
      final w = freshWorld(seed: seed);
      final cmd = Commands(w);
      final (lat, lng) = openSpot(w);
      cmd.claim(lat, lng, 0);
      cmd.establishHub(w.playerTurfs.single.id, 0);
      return w;
    }

    test('income is deterministic: one big step == many small steps', () {
      int run(bool chunked) {
        final w = seeded(9);
        final sim = Simulator(w);
        const end = 30 * kHour + 1234;
        if (chunked) {
          const step = 7 * 60 * 1000 + 13;
          for (var t = 0; t < end; t += step) {
            sim.run(t, (t + step).clamp(0, end), offline: false);
          }
        } else {
          sim.run(0, end, offline: false);
        }
        return w.player.credits.round();
      }

      expect(run(true), run(false));
    });

    test('offline income uses the offline multiplier', () {
      double earn(bool offline) => Simulator(seeded(3)).run(0, kHour - 1, offline: offline).earned.credits;
      expect(earn(true) / earn(false), closeTo(kOfflineBase, 1e-9));
    });

    test('hub-less turfs wear down to the floor but never vanish; stations hold', () {
      final w = freshWorld(seed: 5);
      final cmd = Commands(w);
      w.player.credits = 1e6;
      final (lat, lng) = openSpot(w);
      cmd.claim(lat, lng, 0, name: 'Back Alley');
      final (sLat, sLng) = openSpot(w, lat, lng + 0.01);
      cmd.claim(sLat, sLng, 0, name: 'Gara de Nord', isStation: true);
      w.factions.clear(); // isolate decay from raids
      Simulator(w).run(0, 200 * kHour, offline: true);
      final alley = w.playerTurfs.firstWhere((t) => t.name == 'Back Alley');
      final station = w.playerTurfs.firstWhere((t) => t.name == 'Gara de Nord');
      expect(alley.integrity, closeTo(kBaseDecayFloor, 0.01));
      expect(station.integrity, 100);
      // Station output beats a plain hub-less turf of the same garrison.
      expect(kStationSoloYield, greaterThan(kUnsuppliedYield));
    });

    test('energy regenerates up to the cap, offline too', () {
      final w = seeded(12);
      w.player.energy = 0;
      Simulator(w).run(0, kHour, offline: true);
      expect(w.player.energy, closeTo(kBaseEnergyPerHour, 1e-6));
      Simulator(w).run(kHour, 20 * kHour, offline: true);
      expect(w.player.energy, kBaseEnergyMax);
    });

    test('event deck deals 2-4 cards per day once territory exists', () {
      final r = Simulator(seeded(21)).run(0, kDay + kHour, offline: false);
      expect(r.eventsRolled, inInclusiveRange(2, 4));
    });

    test('newcomers are never dealt a lockdown or an offensive', () {
      final w = seeded(44);
      final sim = Simulator(w);
      final seen = <EventType>{};
      for (var day = 0; day < 12; day++) {
        sim.run(day * kDay, (day + 1) * kDay, offline: true);
        seen.addAll(w.events.map((e) => e.type));
        w.player.level = 1; // stay a newcomer whatever XP trickled in
        w.player.xp = 0;
      }
      expect(seen, isNot(contains(EventType.lockdown)));
      expect(seen, isNot(contains(EventType.offensive)));
      expect(seen, isNotEmpty);
    });

    test('field events sit on real points and resolve by walking there', () {
      final w = seeded(31);
      final cmd = Commands(w);
      final hub = w.playerTurfs.single;
      w.events.add(WorldEvent(
        id: 'drop-1',
        type: EventType.deadDrop,
        target: 'x',
        expiresAt: kDay,
        payload: {
          'created': 0,
          'lat': hub.lat + 0.005,
          'lng': hub.lng,
          'materials': 100.0,
          'intel': 10.0,
          'module': true,
        },
      ));
      expect(cmd.eventQuote('drop-1', hub.lat, hub.lng).blocker, isNotNull);
      final mats = w.player.materials;
      final out = cmd.resolveEvent('drop-1', hub.lat + 0.005, hub.lng, 10);
      expect(out.ok, isTrue, reason: out.message);
      expect(w.player.materials, mats + 100);
      expect(w.stash, hasLength(1));
      expect(w.events, isEmpty);
    });

    test('relays form networks and multiply trade across districts', () {
      final w = freshWorld(seed: 8);
      final cmd = Commands(w);
      w.player.credits = 1e9;
      w.player.materials = 1e9;
      w.player.intel = 1e9;
      final (aLat, aLng) = openSpot(w, 0, 0);
      final (bLat, bLng) = openSpot(w, 0, 0.5); // ~55 km east: another district
      cmd.claim(aLat, aLng, 0, name: 'North Station', isStation: true);
      cmd.claim(bLat, bLng, 0, name: 'East Station', isStation: true);
      final a = w.playerTurfs.firstWhere((t) => t.name == 'North Station');
      final b = w.playerTurfs.firstWhere((t) => t.name == 'East Station');
      cmd.establishHub(a.id, 0);
      cmd.establishHub(b.id, 0);
      for (var i = 0; i < 30; i++) {
        cmd.upgradeHub(a.id, 0); // long relay needs a high-level hub
      }
      expect(a.district, isNot(b.district));
      final before = w.index.hourly.credits;
      final out = cmd.buildRelay(a.id, b.id, 0);
      expect(out.ok, isTrue, reason: out.message);
      expect(w.index.networks.length, 1);
      expect(w.index.networks.first.trade, greaterThan(1.3));
      expect(w.index.hourly.credits, greaterThan(before));
      expect(w.index.bestLinkedDistricts, 2);
    });

    test('nemesis threat scales with best hub level, uncapped', () {
      final w = freshWorld();
      final f = w.factions.first;
      final t1 = threatPower(maxHubLevel: 1, playerLevel: 1, liquidations: 0, aggression: 1, nemesisRank: 0);
      final t50 = threatPower(maxHubLevel: 50, playerLevel: 1, liquidations: 0, aggression: 1, nemesisRank: 0);
      final t500 = threatPower(maxHubLevel: 500, playerLevel: 1, liquidations: 0, aggression: 1, nemesisRank: 0);
      expect(t50, greaterThan(t1 * 50));
      expect(t500, greaterThan(t50 * 1000));
      expect(w.threatOf(f), greaterThan(0));
    });
  });

  group('perks and jobs', () {
    test('default plant range is 250 m past the no-plant gap; Long Arm extends it', () {
      final w = freshWorld(seed: 61);
      final cmd = Commands(w);
      w.player.credits = 1e9;
      w.player.intel = 1e9;
      expect(w.perks.plantReachM, kBasePlantReachM);
      expect(w.perks.plantRangeM, kBaseSpacingM + kBasePlantReachM);

      final (lat, lng) = openSpot(w);
      cmd.claim(lat, lng, 0, name: 'Home');

      // ~500 m out is past the default range, from the player and from Home...
      final (fLat, fLng) = openSpot(w, lat, lng + 0.0045);
      final farAway = metersBetween(lat, lng, fLat, fLng);
      expect(farAway, greaterThan(w.perks.plantRangeM + Commands.kPlantSlackM));
      final blocked = cmd.claimQuote(fLat, fLng, fromLat: lat, fromLng: lng);
      expect(blocked.blocker, 'Out of plant range');
      expect(blocked.note, contains('Long Arm'), reason: 'the limit says how to raise it');
      expect(cmd.claim(fLat, fLng, 0, fromLat: lat, fromLng: lng).ok, isFalse);

      // Standing on our own turf: the first 100 m are blocked by spacing, yet a
      // spot ~330 m out is fine with no perk at all.
      final (nLat, nLng) = openSpot(w, lat, lng + 0.0030);
      final nearAway = metersBetween(lat, lng, nLat, nLng);
      expect(nearAway, inInclusiveRange(kBaseSpacingM, kBaseSpacingM + kBasePlantReachM));
      expect(cmd.claimQuote(lat, lng + 0.0005, fromLat: lat, fromLng: lng).blocker, 'Too close to a turf');

      // ...until Long Arm stretches it.
      while (w.perks.plantRangeM + Commands.kPlantSlackM < farAway) {
        expect(cmd.buyPerk(StreetPerk.plantRange, 0).ok, isTrue);
      }
      expect(w.perks.plantReachM, greaterThan(kBasePlantReachM));
      final far = cmd.claim(fLat, fLng, 0, fromLat: lat, fromLng: lng);
      expect(far.ok, isTrue, reason: far.message);
      final near = cmd.claim(nLat, nLng, 0, fromLat: lat, fromLng: lng);
      expect(near.ok, isTrue, reason: near.message);
      expect(w.index.owned, 3);
    });

    test('Signal Boost stretches the relay range of every hub', () {
      final w = freshWorld(seed: 8);
      final cmd = Commands(w);
      w.player.credits = 1e9;
      w.player.materials = 1e9;
      w.player.intel = 1e9;
      final (aLat, aLng) = openSpot(w, 0, 0);
      final (bLat, bLng) = openSpot(w, 0, 0.18); // ~20 km east
      cmd.claim(aLat, aLng, 0, name: 'West');
      cmd.claim(bLat, bLng, 0, name: 'East');
      final a = w.playerTurfs.firstWhere((t) => t.name == 'West');
      final b = w.playerTurfs.firstWhere((t) => t.name == 'East');
      cmd.establishHub(a.id, 0);
      cmd.establishHub(b.id, 0);
      final km = w.kmBetween(a, b);
      expect(km, inInclusiveRange(19, 21));

      // A level 1 hub reaches 12.5 km: the link is out of range, and says how to fix it.
      final base = w.index.hubs[a.id]!.relayKm / (a.anomaly == Anomaly.signalTower ? 1.5 : 1);
      expect(base, closeTo(relayRangeKm(1), 1e-9));
      final blocked = cmd.relayQuote(a.id, b.id);
      expect(blocked.blocker, startsWith('Out of range'));
      expect(blocked.note, contains('Signal Boost'));
      expect(cmd.buildRelay(a.id, b.id, 0).ok, isFalse);

      var ranks = 0;
      while (w.index.hubs[a.id]!.relayKm < km) {
        expect(cmd.buyPerk(StreetPerk.relay, 0).ok, isTrue);
        ranks++;
      }
      expect(ranks, lessThanOrEqualTo(4));
      expect(w.perks.relayMult, closeTo(1 + kRelayPerkStep * ranks, 1e-9));
      expect(w.index.hubs[b.id]!.relayKm, greaterThan(relayRangeKm(1)), reason: 'every hub, not just one');
      final out = cmd.buildRelay(a.id, b.id, 0);
      expect(out.ok, isTrue, reason: out.message);
      expect(StreetPerk.relay.maxRank, isNull, reason: 'no ceiling');
    });

    test('Close Quarters shrinks the gap without eating into the reach', () {
      final w = freshWorld();
      final cmd = Commands(w);
      w.player.credits = 1e12;
      w.player.intel = 1e12;
      cmd.buyPerk(StreetPerk.spacing, 0);
      expect(w.perks.spacingM, lessThan(kBaseSpacingM));
      expect(w.perks.plantReachM, kBasePlantReachM);
      expect(w.perks.plantRangeM, closeTo(w.perks.spacingM + kBasePlantReachM, 1e-9));
    });

    test('perks cost credits + intel, escalate, and Close Quarters has a floor', () {
      final w = freshWorld();
      final cmd = Commands(w);
      w.player.credits = 1e12;
      w.player.intel = 1e12;
      final c0 = cmd.perkQuote(StreetPerk.muscle).cost;
      cmd.buyPerk(StreetPerk.muscle, 0);
      final c1 = cmd.perkQuote(StreetPerk.muscle).cost;
      expect(c1.credits, greaterThan(c0.credits));
      expect(c1.intel, greaterThan(c0.intel));
      expect(w.perks.strikeMult, closeTo(1.08, 1e-9));

      while (cmd.buyPerk(StreetPerk.spacing, 0).ok) {}
      expect(w.perks.rank(StreetPerk.spacing), StreetPerk.spacing.maxRank);
      expect(w.perks.spacingM, kMinSpacingM);
      expect(w.perks.spacingM, lessThan(kBaseSpacingM));
    });

    test('perks survive a liquidation', () {
      final w = freshWorld();
      final cmd = Commands(w);
      w.player.credits = 1e9;
      w.player.intel = 1e9;
      cmd.buyPerk(StreetPerk.plantRange, 0);
      Turf plant(double lat, double lng, String name) {
        final t = w.makeTurf(lat: lat, lng: lng, name: name, owner: kPlayer, now: 0);
        w.addTurf(t);
        return t;
      }

      final hubs = [plant(0.5, 0.5, 'A'), plant(0.5, 2.0, 'B'), plant(2.0, 0.5, 'C')];
      for (final h in hubs) {
        h
          ..isHub = true
          ..hubLevel = 60;
      }
      hubs[0].relayTarget = hubs[1].id;
      hubs[1].relayTarget = hubs[2].id;
      for (var i = 0; i < kPrestigeHexes - 3; i++) {
        plant(3.0 + (i ~/ 40) * 0.002, 3.0 + (i % 40) * 0.002, 'T$i');
      }
      w.reindex();
      expect(cmd.liquidate(0, 5).ok, isTrue);
      expect(w.perks.rank(StreetPerk.plantRange), 1);
    });

    test('jobs spend energy, pay out, and build mastery', () {
      final w = freshWorld(seed: 9);
      final cmd = Commands(w);
      final job = jobs.first;
      w.player.energy = 30;
      final before = w.player.credits;
      final out = cmd.runJob(job.id, 0);
      expect(out.ok, isTrue, reason: out.message);
      expect(w.player.energy, 30 - job.energy);
      expect(w.player.credits, greaterThan(before));

      // Home turf bonus and mastery both raise the payout.
      expect(cmd.jobPayout(job, atHome: true), closeTo(cmd.jobPayout(job, atHome: false) * kHomeTurfBonus, 1e-9));
      final base = cmd.jobPayout(job, atHome: false);
      w.jobRuns[job.id] = kJobMasteryRuns;
      expect(cmd.jobPayout(job, atHome: false), closeTo(base * (1 + kJobMasteryBonus), 1e-9));

      // Out of energy / locked jobs refuse.
      w.player.energy = 0;
      expect(cmd.runJob(job.id, 1).ok, isFalse);
      w.player.energy = 999;
      expect(cmd.runJob(jobs.last.id, 2).ok, isFalse);
    });
  });

  group('turf reach', () {
    test('plants, breaches and pickups reach out from every turf you hold', () {
      final w = freshWorld(seed: 4);
      final cmd = Commands(w);
      w.player
        ..credits = 1e9
        ..intel = 1e9
        ..level = 200;
      final rival = firstRival(w);
      // The player sits ~10 km away the whole time.
      final awayLat = rival.lat - 0.09, awayLng = rival.lng;
      final (sLat, sLng) = openSpot(w, rival.lat, rival.lng + 0.0018);
      expect(metersBetween(sLat, sLng, rival.lat, rival.lng), lessThan(cmd.turfStrikeRangeM));

      // Nothing of theirs in reach yet: no plant, no breach.
      expect(cmd.claimQuote(sLat, sLng, fromLat: awayLat, fromLng: awayLng, remote: true).blocker, 'Out of plant range');
      expect(cmd.claimQuote(sLat, sLng, remote: true).blocker, 'Out of plant range', reason: 'no GPS fix at all');
      final noReach = cmd.breachQuote(rival, awayLat, awayLng);
      expect(noReach.blocker, 'Out of reach');
      expect(noReach.note, contains('hold a turf within'));

      // One turf planted on the spot, in person.
      expect(cmd.claim(sLat, sLng, 0, name: 'Outpost').ok, isTrue);
      final outpost = w.playerTurfs.single;
      expect(cmd.turfStrikeRangeM, w.perks.plantRangeM, reason: 'no Deep Reach yet');

      // From then on it works from the sofa: plant next to it...
      final (nLat, nLng) = openSpot(w, sLat, sLng + 0.0015);
      expect(metersBetween(sLat, sLng, nLat, nLng), lessThanOrEqualTo(w.perks.plantRangeM));
      expect(cmd.claimVia(nLat, nLng, fromLat: awayLat, fromLng: awayLng)?.id, outpost.id);
      expect(cmd.claimVia(nLat, nLng, fromLat: nLat, fromLng: nLng), isNull, reason: 'on foot needs no turf');
      final planted = cmd.claim(nLat, nLng, 1, name: 'Annex', fromLat: awayLat, fromLng: awayLng, remote: true);
      expect(planted.ok, isTrue, reason: planted.message);
      expect(cmd.claim(sLat, sLng + 0.02, 1, remote: true).ok, isFalse, reason: '2 km out is nobody\'s reach');

      // ...breach the crew next door...
      expect(cmd.breachVia(rival, awayLat, awayLng), isNotNull);
      expect(cmd.breachVia(rival, rival.lat, rival.lng), isNull);
      expect(cmd.breachQuote(rival, awayLat, awayLng).blocker, isNull);
      expect(cmd.breachQuote(rival, null, null).blocker, isNull, reason: 'works with no GPS fix too');
      var seized = false;
      for (var now = 2; now < 60 && !seized; now++) {
        seized = cmd.breach(rival.id, awayLat, awayLng, now, name: 'Old Depot').ok;
      }
      expect(seized, isTrue);
      expect(w.turfs[rival.id]!.isPlayer, isTrue);

      // ...and pick up a dead drop that fell near a turf.
      WorldEvent drop(String id, double lat, double lng) => WorldEvent(
            id: id,
            type: EventType.deadDrop,
            target: 'x',
            expiresAt: kDay,
            payload: {'created': 0, 'lat': lat, 'lng': lng, 'materials': 100.0, 'intel': 10.0, 'module': false},
          );
      w.events.add(drop('near', outpost.lat + 0.002, outpost.lng)); // ~220 m from Outpost
      w.events.add(drop('far', outpost.lat + 0.02, outpost.lng)); // ~2.2 km from anything
      expect(cmd.eventVia(w.events.first, awayLat, awayLng), isNotNull);
      final mats = w.player.materials;
      expect(cmd.resolveEvent('near', awayLat, awayLng, 100).ok, isTrue);
      expect(w.player.materials, mats + 100);
      final tooFar = cmd.eventQuote('far', awayLat, awayLng);
      expect(tooFar.blocker, isNotNull);
      expect(tooFar.note, contains('hold a turf within'));
    });
  });

  group('sieges and alerts', () {
    World corner(int seed, {double aggression = 40}) {
      final w = freshWorld(seed: seed);
      final (lat, lng) = openSpot(w);
      Commands(w).claim(lat, lng, 0, name: 'Corner');
      for (final f in w.factions) {
        f.aggression = aggression; // raids nearly every hour, far stronger than the turf
      }
      return w;
    }

    test('a turf cannot be hit for the first time and lost in the same absence', () {
      final w = corner(5);
      final t = w.playerTurfs.single;
      final sim = Simulator(w);

      // The exact case: 12 hours away, raided early, raided again and again.
      final r = sim.run(0, 12 * kHour, offline: true);
      expect(r.raidsLost, greaterThan(1));
      expect(r.turfsCaptured, 0);
      expect(r.lastStands, greaterThan(0));
      expect(t.isPlayer, isTrue);
      expect(t.integrity, kLastStandIntegrity);
      expect(w.siegeSince(t.id), isNotNull);
      expect(w.exposed(t), isFalse);

      // However long the absence, it holds until the player has looked.
      expect(sim.run(12 * kHour, 20 * kDay, offline: true).turfsCaptured, 0);
      expect(t.isPlayer, isTrue);

      // They open the game, see it, and leave it broken: now it can fall.
      w.markSeen(20 * kDay);
      expect(w.exposed(t), isTrue);
      final after = sim.run(20 * kDay, 21 * kDay, offline: true);
      expect(after.turfsCaptured, 1);
      expect(t.isHostile, isTrue);
      expect(w.siegeSince(t.id), isNull);
    });

    test('repairing lifts the siege: the next raid starts from scratch', () {
      final w = corner(6);
      final cmd = Commands(w);
      final t = w.playerTurfs.single;
      final sim = Simulator(w);
      sim.run(0, 6 * kHour, offline: true);
      expect(w.siegeSince(t.id), isNotNull);

      w.markSeen(6 * kHour);
      w.player.materials = 1e6;
      expect(cmd.repair(t.id, 6 * kHour).ok, isTrue);
      expect(t.integrity, 100);
      expect(w.siegeSince(t.id), isNull);

      expect(sim.run(6 * kHour, 3 * kDay, offline: true).turfsCaptured, 0);
      expect(t.isPlayer, isTrue);
    });

    test('an offensive nobody saw announced wrecks the hub but cannot take it', () {
      Turf land({required int announced}) {
        final w = corner(7);
        final cmd = Commands(w);
        final hub = w.playerTurfs.single;
        cmd.establishHub(hub.id, 0);
        w.events.add(WorldEvent(
          id: 'off-1',
          type: EventType.offensive,
          target: hub.id,
          expiresAt: 10 * kHour,
          payload: {'created': announced, 'faction': 'rival0', 'fortified': false},
        ));
        Simulator(w).run(0, 10 * kHour + 1, offline: true);
        expect(w.events.where((e) => e.id == 'off-1'), isEmpty);
        return hub;
      }

      // Announced an hour after the player left: it lands, the hub survives.
      final unseen = land(announced: kHour);
      expect(unseen.isPlayer, isTrue);
      expect(unseen.integrity, lessThan(100));
      // Announced while they were still watching and ignored: the hub goes.
      expect(land(announced: -kHour).isHostile, isTrue);
    });

    test('the alert forecast matches what then happens, and leaves the world alone', () {
      final w = corner(9, aggression: 10);
      final cmd = Commands(w);
      final hub = w.playerTurfs.single;
      cmd.establishHub(hub.id, 0);
      w.player.energy = 0;
      w.pendingLog.clear();
      const span = 20 * kHour;

      final credits = w.player.credits;
      final alerts = forecastAlerts(w, 0, horizonMs: span);
      expect(w.player.credits, credits);
      expect(w.player.energy, 0);
      expect(hub.integrity, 100);
      expect(w.pendingLog, isEmpty);
      expect(w.events, isEmpty);

      final energy = alerts.firstWhere((a) => a.title == 'Energy full');
      expect(energy.at, 2 * kHour, reason: '30 energy at 15 an hour');
      expect(energy.urgent, isFalse);
      expect(alerts.any((a) => a.urgent), isTrue);
      expect(alerts.length, lessThanOrEqualTo(kAlertMax));
      for (var i = 1; i < alerts.length; i++) {
        expect(alerts[i].at, greaterThanOrEqualTo(alerts[i - 1].at));
      }

      // The real thing, hour for hour.
      Simulator(w).run(0, span, offline: true);
      final real = <(int, bool)>{
        for (final l in w.pendingLog)
          if (l.alert != null) (l.ts, l.kind == 'loss'),
      }.toList()
        ..sort((a, b) => a.$1 != b.$1 ? a.$1.compareTo(b.$1) : (a.$2 ? 1 : 0) - (b.$2 ? 1 : 0));
      final predicted = [
        for (final a in alerts)
          if (a.title != 'Energy full') (a.at, a.urgent),
      ]..sort((a, b) => a.$1 != b.$1 ? a.$1.compareTo(b.$1) : (a.$2 ? 1 : 0) - (b.$2 ? 1 : 0));
      expect(predicted, isNotEmpty);
      expect(predicted.toSet().difference(real.toSet()), isEmpty, reason: 'no alert for something that never happens');
      if (alerts.length < kAlertMax) expect(predicted, real);
    });
  });

  group('exchange and sockets', () {
    test('the exchange swaps goods at a fee, up to a daily limit', () {
      final w = freshWorld();
      final cmd = Commands(w);
      expect(kTradeFee, 0.25);
      expect(cmd.tradeRate(Good.materials, Good.credits), closeTo(2.5 * 0.75, 1e-9));
      expect(cmd.tradeRate(Good.credits, Good.intel), closeTo(0.75 / 6, 1e-9));
      expect(cmd.tradeRate(Good.credits, Good.materials) * cmd.tradeRate(Good.materials, Good.credits),
          closeTo(0.5625, 1e-9),
          reason: 'there and back loses to the fee twice');

      expect(cmd.tradeCap, 1000, reason: 'level 1, no income');
      final out = cmd.trade(Good.credits, Good.materials, 500, 0);
      expect(out.ok, isTrue, reason: out.message);
      expect(w.player.credits, kStartCredits - 500);
      expect(w.player.materials, closeTo(kStartMaterials + 150, 1e-9));
      expect(cmd.tradeLeft(0), 500);
      expect(cmd.tradeMax(Good.credits, 0), 500);
      expect(cmd.tradeMax(Good.intel, 0), kStartIntel, reason: 'capped by what you hold');

      expect(cmd.trade(Good.materials, Good.intel, 250, 0).ok, isFalse, reason: "625 credits' worth, 500 left");
      expect(cmd.trade(Good.credits, Good.credits, 10, 0).ok, isFalse);
      expect(cmd.trade(Good.intel, Good.credits, 60, 0).ok, isFalse, reason: 'only 50 intel');

      // A new day brings the limit back; level and income raise it.
      expect(cmd.tradeLeft(kDay), 1000);
      w.player.level = 5;
      expect(cmd.tradeCap, 2000);
      final (lat, lng) = openSpot(w);
      cmd.claim(lat, lng, kDay);
      expect(cmd.tradeCap, closeTo(2000 + 12 * cmd.hourlyValue, 1e-9));
      expect(cmd.hourlyValue, greaterThan(0));
    });

    test('a socket can be bought on any turf, each one at double the price', () {
      final w = freshWorld(seed: 13);
      final cmd = Commands(w);
      w.player
        ..credits = 1e9
        ..materials = 1e9
        ..intel = 1e9;
      final (lat, lng) = openSpot(w);
      cmd.claim(lat, lng, 0, name: 'Workshop');
      final t = w.playerTurfs.single;
      expect(w.socketsOf(t), 1);
      expect(cmd.socketQuote(t.id).cost.credits, 1200);
      expect(cmd.expandSocket(t.id, 0).ok, isTrue);
      expect(w.socketsOf(t), 2);
      expect(cmd.socketQuote(t.id).cost.credits, 2400);
      expect(cmd.socketQuote(t.id).cost.intel, 200);

      final mods = [for (var i = 1; i <= 3; i++) dropModule(w, Rng(i), 0)];
      expect(cmd.install(mods[0].id, t.id, 0).ok, isTrue);
      expect(cmd.install(mods[1].id, t.id, 0).ok, isTrue);
      expect(cmd.install(mods[2].id, t.id, 0).ok, isFalse, reason: 'two sockets, two modules');

      // Lives in the settings, so it travels with the save.
      final saved = (jsonDecode(jsonEncode(w.player.settings)) as Map).cast<String, dynamic>();
      expect((saved[kSocketsKey] as Map)[t.id], 1);

      expect(cmd.delete(t.id, 1).ok, isTrue);
      expect(w.extraSockets(t.id), 0);
      expect(w.stash, hasLength(3));
    });

    test('the breakdown of a turf multiplies out to what it pays', () {
      final w = freshWorld(seed: 77);
      final cmd = Commands(w);
      w.player
        ..credits = 1e9
        ..materials = 1e9;
      final (lat, lng) = openSpot(w);
      cmd.claim(lat, lng, 0, name: 'Gara', isStation: true);
      final hub = w.playerTurfs.single;
      cmd.establishHub(hub.id, 0);
      cmd.upgradeGarrison(hub.id, 0);
      final (fLat, fLng) = openSpot(w, lat, lng + 0.05); // ~5.5 km: no hub in reach
      cmd.claim(fLat, fLng, 0, name: 'Far');
      final far = w.playerTurfs.firstWhere((t) => t.name == 'Far');

      for (final t in w.playerTurfs) {
        final parts = w.index.turfYield[t.id]!;
        final y = w.index.turfHourly[t.id]!;
        expect(parts.total.credits, y.credits);
        expect(parts.total.materials, y.materials);
        expect(parts.total.intel, y.intel);
      }
      final h = w.index.turfYield[hub.id]!;
      expect(h.station, kStationCreditBonus);
      expect(h.hub, hubYieldMult(1));
      expect(h.garrison, garrisonYieldMult(2));
      expect(h.supply, 1);
      expect(w.index.turfYield[far.id]!.supply, kUnsuppliedYield);
      expect(w.index.turfYield[far.id]!.hub, 1);
    });
  });

  group('save file', () {
    test('round-trips and rejects foreign or newer files', () {
      final tables = {
        'player_state': [
          {'id': 1, 'credits': 12.5},
        ],
        'hex_nodes': [
          {'h3_index': 'abc', 'turf_name': 'Gara Târgoviște'},
        ],
      };
      final bytes = SaveFile.encode(tables: tables, schemaVersion: 3, exportedAt: 1700000000000);
      expect(bytes[0], 0x1f, reason: 'gzip magic');
      final back = SaveFile.decode(bytes, schemaVersion: 3);
      expect(back['hex_nodes'][0]['turf_name'], 'Gara Târgoviște');
      expect(back['player_state'][0]['credits'], 12.5);

      expect(() => SaveFile.decode(Uint8List.fromList(utf8.encode('{"hello":1}')), schemaVersion: 3),
          throwsA(isA<FormatException>()));
      expect(() => SaveFile.decode(Uint8List.fromList([1, 2, 3, 4]), schemaVersion: 3), throwsA(isA<FormatException>()));
      expect(() => SaveFile.decode(bytes, schemaVersion: 2), throwsA(isA<FormatException>()),
          reason: 'save from a newer schema must not load into an older game');
      expect(SaveFile.fileName(1700000000000), endsWith('.hexsave'));
    });
  });

  group('prestige', () {
    test('liquidation gated by empire size, then resets with keys', () {
      final w = freshWorld();
      final cmd = Commands(w);
      expect(cmd.prestigeStatus().ready, isFalse);
      expect(cmd.liquidate(0, 77).ok, isFalse);

      // Fabricate an empire at the threshold: 50 turfs, three L30 hubs in three regions.
      expect(kPrestigeHexes, 50);
      Turf plant(double lat, double lng, String name) {
        final t = w.makeTurf(lat: lat, lng: lng, name: name, owner: kPlayer, now: 0);
        w.addTurf(t);
        return t;
      }

      final hubs = [plant(0.5, 0.5, 'A'), plant(0.5, 1.5, 'B'), plant(1.5, 0.5, 'C')];
      for (final h in hubs) {
        h
          ..isHub = true
          ..hubLevel = 30;
      }
      hubs[0].relayTarget = hubs[1].id;
      hubs[1].relayTarget = hubs[2].id;
      for (var i = 0; i < kPrestigeHexes - 4; i++) {
        plant(3.0 + (i ~/ 40) * 0.002, 3.0 + (i % 40) * 0.002, 'T$i');
      }
      w.reindex();
      expect(cmd.prestigeStatus().hexesMet, isFalse, reason: 'one turf short');
      expect(cmd.liquidate(0, 77).ok, isFalse);
      plant(3.5, 3.5, 'Last');
      w.reindex();
      final s = cmd.prestigeStatus();
      expect(s.owned, kPrestigeHexes);
      expect(s.districts, greaterThanOrEqualTo(3));
      expect(s.ready, isTrue);

      final out = cmd.liquidate(0, 77);
      expect(out.ok, isTrue);
      expect(w.player.keys, s.keys);
      expect(w.turfs, isEmpty);
      expect(w.player.level, 1);
      expect(w.player.worldSeed, 77);
      expect(w.player.liquidations, 1);
    });

    test('vault upgrades are infinite and escalate in cost', () {
      final w = freshWorld();
      final cmd = Commands(w);
      w.player.keys = 100;
      for (var i = 0; i < 12; i++) {
        expect(cmd.buyVault(VaultUpgrade.offlineIncome, 0).ok, isTrue);
      }
      expect(w.vault.rank(VaultUpgrade.offlineIncome), 12);
      expect(w.vault.offlineMult, closeTo(1.24, 1e-9));
      expect(w.player.keys, 100 - (5 * 1 + 5 * 2 + 2 * 3));
    });
  });

  group('tiers & formatting', () {
    test('tier thresholds and epochs', () {
      expect(tierFor(1), Tier.grounded);
      expect(tierFor(kTier2Level), Tier.syndicate);
      expect(tierFor(kTier3Level), Tier.escalation);
      expect(epochFor(kTier3Level + kEpochSpan * 3), 4);
    });

    test('number formatting scales without limit', () {
      expect(fmtNum(950), '950');
      expect(fmtNum(12400), '12.4K');
      expect(fmtNum(3.21e6), '3.21M');
      expect(fmtNum(1e40), contains('e40'));
    });
  });
}
