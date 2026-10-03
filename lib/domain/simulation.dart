import 'dart:math' as math;

import 'package:latlong2/latlong.dart' show LatLng;

import '../core/format.dart';
import '../core/rng.dart';
import '../geo/hex_grid.dart';
import 'balance.dart';
import 'loot.dart';
import 'models.dart';
import 'tiers.dart';
import 'world.dart';

class SimReport {
  SimReport(this.from, this.to);
  final int from;
  int to;
  Resources earned = const Resources();
  int raidsRepelled = 0;
  int raidsLost = 0;
  int turfsCaptured = 0;
  int eventsRolled = 0;
  int levelsGained = 0;
  int modulesFound = 0;
  final headlines = <String>[];

  Duration get span => Duration(milliseconds: to - from);

  bool get eventful =>
      !earned.isZero ||
      raidsRepelled + raidsLost + turfsCaptured + eventsRolled + levelsGained + modulesFound > 0;

  void headline(String s) {
    if (headlines.length < 40) headlines.add(s);
  }
}

// ------------------------------------------------------------ progression

/// Adds XP, processes any level-ups. Returns levels gained.
int grantXp(World w, int amount, int ts, [SimReport? r]) {
  final p = w.player;
  final tierBefore = tierFor(p.level);
  p.xp += (amount * w.perks.xpMult).round();
  var gained = 0;
  while (p.xp >= xpToNext(p.level)) {
    p.xp -= xpToNext(p.level);
    p.level++;
    gained++;
    final bonus = levelUpBonus(p.level);
    p.credits += bonus;
    w.log(ts, 'gain', 'Promoted to level ${p.level} · +${fmtNum(bonus)} credits');
  }
  if (gained > 0) {
    r?.levelsGained += gained;
    final tierAfter = tierFor(p.level);
    if (tierAfter != tierBefore) {
      w.log(ts, 'event', 'Threat tier ${tierAfter.index1}: ${tierAfter.title}. ${tierAfter.blurb}');
      r?.headline('Threat tier ${tierAfter.index1}: ${tierAfter.title}');
    } else if (epochFor(p.level) > epochFor(p.level - gained)) {
      w.log(ts, 'event', 'Epoch ${roman(epochFor(p.level))} begins. Enemy designations upgraded.');
    }
    w.reindex(); // level multiplies yields
  }
  return gained;
}

Module dropModule(
  World w,
  Rng rng,
  int ts, {
  Rarity minRarity = Rarity.common,
  int levelBonus = 0,
  double extraLuck = 0,
}) {
  final m = LootTable.roll(
    rng,
    playerLevel: w.player.level,
    maxHubLevel: w.index.maxHubLevel,
    now: ts,
    luck: w.vault.luck + extraLuck,
    minRarity: minRarity,
    levelBonus: levelBonus,
  );
  w.stash.add(m);
  w.modulesDirty = true;
  return m;
}

/// The player abandons or deletes a turf: it is gone, its modules go back to
/// the stash.
void collapseTurf(World w, Turf t, int ts) {
  final mods = w.installed.remove(t.id);
  if (mods != null && mods.isNotEmpty) {
    for (final m in mods) {
      m.hexId = null;
      m.socket = -1;
      w.stash.add(m);
    }
    w.modulesDirty = true;
  }
  for (final other in w.turfs.values) {
    if (other.relayTarget == t.id) {
      other.relayTarget = null;
      w.markTurf(other);
    }
  }
  w.deleteTurf(t.id);
}

/// A faction takes a player turf. Hub level and modules stay on it, so
/// retaking it restores the investment.
void captureTurf(World w, Turf t, Faction f, int ts) {
  t.owner = factionOwner(f.id);
  t.integrity = 60;
  t.lastTick = ts;
  w.markTurf(t);
  for (final other in w.turfs.values) {
    if (other.relayTarget == t.id) {
      other.relayTarget = null;
      w.markTurf(other);
    }
  }
}

// ------------------------------------------------------------ simulator

/// Deterministic time engine. Foreground ticks and offline catch-up run the
/// exact same code: continuous accrual inside each hour, discrete RNG rolls
/// (raids, heat, Event Deck) on hour boundaries seeded by (WorldSeed, hour).
class Simulator {
  Simulator(this.w);
  final World w;
  double _xpCarry = 0;

  SimReport run(int from, int to, {required bool offline, SimReport? into}) {
    final r = into ?? SimReport(from, to);
    r.to = to;
    var t = from;
    while (t < to) {
      final nextHour = (t ~/ kHour + 1) * kHour;
      final end = math.min(nextHour, to);
      _segment(t, end, offline, r);
      if (end == nextHour) _hourly(end, r);
      t = end;
    }
    return r;
  }

  void _segment(int a, int b, bool offline, SimReport r) {
    final dtH = (b - a) / kHour;
    if (dtH <= 0) return;
    final p = w.player;
    final ix = w.index;
    final mult = offline ? kOfflineBase * w.vault.offlineMult : 1.0;
    final gain = ix.hourly * (dtH * mult);
    p.credits += gain.credits;
    p.materials += gain.materials;
    p.intel += gain.intel;
    p.lifetimeCredits += gain.credits;
    r.earned = r.earned + gain;

    _xpCarry += ix.passiveXpPerHour * dtH;
    if (_xpCarry >= 1) {
      final whole = _xpCarry.floor();
      _xpCarry -= whole;
      grantXp(w, whole, b, r);
    }

    // Energy for jobs.
    final fx = w.perks;
    if (p.energy < fx.energyMax) p.energy = math.min(fx.energyMax, p.energy + fx.energyPerHour * dtH);

    // Structural integrity: supplied turfs regenerate, station turfs hold on
    // their own traffic, every other hub-less turf wears down to the
    // Safehouse floor. Nothing vanishes by decay alone: weak turfs get raided.
    var structural = false;
    final floor = fx.decayFloor;
    for (final t in w.turfs.values) {
      if (!t.isPlayer) continue;
      final before = t.integrity;
      final repair = _perk(t.id, Perk.autoRepair);
      if (ix.supplier.containsKey(t.id)) {
        if (t.integrity < 100) t.integrity = math.min(100, t.integrity + (kSuppliedRegen + repair) * dtH);
      } else if (t.isStation) {
        if (t.integrity < 100) t.integrity = math.min(100, t.integrity + (kSuppliedRegen * 0.25 + repair) * dtH);
      } else if (t.integrity > floor) {
        t.integrity = math.max(floor, t.integrity - math.max(0, decayPerHour(t) - repair) * dtH);
      } else if (repair > 0 && t.integrity < floor) {
        t.integrity = math.min(floor, t.integrity + repair * dtH);
      }
      if (before.floor() != t.integrity.floor()) w.markTurf(t);
    }

    if (_expireEvents(b, r)) structural = true;
    if (structural) w.reindex();
  }

  double _perk(String turfId, Perk perk) {
    final list = w.installed[turfId];
    if (list == null) return 0;
    var s = 0.0;
    for (final m in list) {
      if (m.perk == perk) s += m.perkValue;
    }
    return s;
  }

  void _hourly(int ts, SimReport r) {
    final p = w.player;
    final hourIdx = ts ~/ kHour;
    final rng = Rng(seedOf([p.worldSeed, hourIdx, 0x70C]));

    final day = ts ~/ kDay;
    if (day > p.lastEventDay) {
      p.lastEventDay = day;
      EventDirector(w).rollDay(day, ts, rng, r);
      _factionsExpand(ts, rng);
    }

    if (w.index.owned == 0) return;

    // Heat: pressure builds fastest when everything is locked down.
    p.heat += kHeatBase + kHeatSecured * w.index.suppliedRatio;

    var structural = false;
    for (final f in w.factions) {
      if (!rng.chance(raidChancePerHour(f.aggression, p.heat))) continue;
      final target = w.index.pickRaidTarget(rng.nextDouble());
      if (target == null) break;
      final t = w.turfs[target];
      if (t == null || !t.isPlayer) continue;
      final attack = w.threatOf(f) * rng.range(0.6, 1.6) * (1 + 0.5 * p.heat);
      final def = w.index.turfDefense[target] ?? 0;
      final name = factionName(f, p.level);
      if (attack > def) {
        f.wins++;
        p.heat = math.max(0, p.heat - 0.4);
        r.raidsLost++;
        final dmg = math.min(100.0, 30 * attack / math.max(1, def));
        t.integrity -= dmg;
        w.markTurf(t);
        if (t.integrity <= 0) {
          captureTurf(w, t, f, ts);
          r.turfsCaptured++;
          w.log(ts, 'loss', '$name seized ${t.isHub ? 'hub ' : ''}${t.name}');
          r.headline('$name seized ${t.name}');
        } else {
          w.log(ts, 'loss', '$name hit ${t.name} · -${dmg.round()}% integrity');
        }
        structural = true;
        if (f.wins >= (f.nemesisRank + 1) * 25) {
          f.nemesisRank++;
          w.log(ts, 'event', '$name upgraded its arsenal (nemesis rank ${f.nemesisRank})');
        }
      } else {
        f.losses++;
        p.heat = math.max(0, p.heat - 0.05);
        r.raidsRepelled++;
        grantXp(w, 5 + p.level, ts, r);
        if (rng.chance(0.04)) {
          final m = dropModule(w, rng, ts);
          r.modulesFound++;
          w.log(ts, 'gain', 'Repelled $name at ${t.name} · salvaged ${m.name}');
        }
      }
      w.factionsDirty = true;
    }

    if (p.heat >= kHeatOffensiveTrigger &&
        p.level >= kOffensiveMinLevel &&
        !w.events.any((e) => e.type == EventType.offensive) &&
        w.index.hubs.isNotEmpty) {
      if (EventDirector(w).spawnOffensive(ts, rng, r)) p.heat -= 1.5;
    }

    if (structural) w.reindex();
  }

  /// Rival crews plant new turfs on open ground near yours: the map breathes.
  void _factionsExpand(int ts, Rng rng) {
    final players = w.playerTurfs.toList();
    if (players.isEmpty) return;
    var changed = false;
    for (final f in w.factions) {
      if (!rng.chance(0.35 * f.aggression)) continue;
      final anchor = rng.pick(players);
      final p = offsetLatLng(
        LatLng(anchor.lat, anchor.lng),
        rng.range(0, 2 * math.pi),
        rng.range(260, 650),
      );
      if (w.turfsNear(p.latitude, p.longitude, kTurfSpacingM).isNotEmpty) continue;
      final name = factionName(f, w.player.level);
      final t = w.makeTurf(lat: p.latitude, lng: p.longitude, name: '$name post', owner: factionOwner(f.id), now: ts)
        ..integrity = 80;
      if (w.turfs.containsKey(t.id)) continue;
      w.addTurf(t);
      changed = true;
      w.log(ts, 'event', '$name set up a turf ${fmtKm(w.kmBetween(anchor, t))} from ${anchor.name}');
    }
    if (changed) w.reindex();
  }

  /// Returns true when the structure changed.
  bool _expireEvents(int now, SimReport r) {
    if (w.events.isEmpty) return false;
    var changed = false;
    final expired = [
      for (final e in w.events)
        if (e.expiresAt <= now) e,
    ];
    for (final e in expired) {
      w.events.remove(e);
      w.eventsDirty = true;
      changed = true;
      final lvl = w.player.level;
      switch (e.type) {
        case EventType.lockdown:
          w.log(e.expiresAt, 'event', '${lockdownCopy(lvl).title} lifted on its own');
        case EventType.convoy:
          w.log(e.expiresAt, 'event', '${convoyCopy(lvl).title} slipped away');
        case EventType.deadDrop:
          w.log(e.expiresAt, 'event', '${deadDropCopy(lvl).title} went cold');
        case EventType.surge:
        case EventType.market:
          w.log(e.expiresAt, 'info', 'Market conditions normalised');
        case EventType.offensive:
          _resolveOffensive(e, r);
      }
    }
    return changed;
  }

  void _resolveOffensive(WorldEvent e, SimReport r) {
    final ts = e.expiresAt;
    final hub = w.turfs[e.target];
    final f = w.factionById(e.payload['faction'] as String? ?? '');
    if (hub == null || !hub.isPlayer || f == null) return;
    final rng = Rng(seedOf([w.player.worldSeed, ts, 0x0FF]));
    final fortified = e.payload['fortified'] == true;
    final attack = w.threatOf(f) * 4 * rng.range(0.8, 1.3) * (1 + 0.5 * w.player.heat);
    final def = (w.index.turfDefense[hub.id] ?? 0) * (fortified ? 2.5 : 1);
    final name = factionName(f, w.player.level);
    final title = offensiveCopy(w.player.level).title;
    if (attack > def) {
      final ratio = attack / math.max(1, def);
      hub.integrity -= math.min(100, 50 * ratio);
      w.markTurf(hub);
      // Splash damage on everything within 400 m of the hub.
      for (final n in w.turfsNear(hub.lat, hub.lng, 400)) {
        if (n.id == hub.id || !n.isPlayer || !w.turfs.containsKey(n.id)) continue;
        n.integrity -= 40;
        w.markTurf(n);
        if (n.integrity <= 0) {
          captureTurf(w, n, f, ts);
          r.turfsCaptured++;
        }
      }
      if (hub.integrity <= 0) {
        captureTurf(w, hub, f, ts);
        r.turfsCaptured++;
        w.log(ts, 'loss', '$title: $name overran ${hub.name}');
        r.headline('$name overran ${hub.name}');
      } else {
        w.log(ts, 'loss', '$title: ${hub.name} held, badly damaged');
        r.headline('$title: ${hub.name} damaged');
      }
      f.wins++;
    } else {
      f.losses++;
      final m = dropModule(w, rng, ts, minRarity: Rarity.rare, levelBonus: 3);
      r.modulesFound++;
      grantXp(w, 100 + 10 * w.player.level, ts, r);
      w.log(ts, 'gain', '$title repelled at ${hub.name} · captured ${m.name}');
      r.headline('$title repelled · ${m.rarity.label} module captured');
    }
    w.factionsDirty = true;
  }
}

// ------------------------------------------------------------ event deck

/// Local AI Director. Once per in-game day it deals 2-4 cards.
class EventDirector {
  EventDirector(this.w);
  final World w;

  HexGrid get grid => w.grid;

  void rollDay(int day, int ts, Rng rng, SimReport r) {
    final players = w.playerTurfs.toList();
    if (players.isEmpty) return;
    final hubs = players.where((t) => t.isHub).toList();
    final count = 2 + rng.nextInt(3);

    final weights = <EventType, double>{
      EventType.surge: 2,
      EventType.market: 1.5,
      EventType.deadDrop: 2,
      if (hubs.isNotEmpty) EventType.convoy: 3,
      if (players.length >= kLockdownMinTurfs &&
          w.events.where((e) => e.type == EventType.lockdown).length <
              maxLockdowns({for (final t in players) t.district}.length))
        EventType.lockdown: 2,
      if (hubs.isNotEmpty &&
          w.player.level >= kOffensiveMinLevel &&
          !w.events.any((e) => e.type == EventType.offensive))
        EventType.offensive: 0.8 + 0.5 * w.player.heat,
    };
    if (w.events.any((e) => e.type == EventType.surge)) weights.remove(EventType.surge);
    if (w.events.any((e) => e.type == EventType.market)) weights.remove(EventType.market);

    for (var i = 0; i < count && weights.isNotEmpty; i++) {
      final type = rng.weighted(weights);
      final ok = switch (type) {
        EventType.lockdown => _lockdown(ts, rng, players),
        EventType.convoy => _convoy(ts, rng, hubs),
        EventType.deadDrop => _deadDrop(ts, rng, players),
        EventType.surge => _surge(ts, rng, players),
        EventType.market => _market(ts, rng, players),
        EventType.offensive => spawnOffensive(ts, rng, r),
      };
      if (ok) r.eventsRolled++;
      if (type != EventType.convoy && type != EventType.deadDrop) weights.remove(type);
    }
    w.reindex();
  }

  String _id(Rng rng, EventType t) => '${t.key}-${rng.hexId(10)}';

  void _add(WorldEvent e) {
    w.events.add(e);
    w.eventsDirty = true;
  }

  LatLng _pointNear(Rng rng, double lat, double lng, double minM, double maxM) =>
      offsetLatLng(LatLng(lat, lng), rng.range(0, 2 * math.pi), rng.range(minM, maxM));

  bool _lockdown(int ts, Rng rng, List<Turf> players) {
    final locked = {
      for (final e in w.events)
        if (e.type == EventType.lockdown) e.district,
    };
    final options = players.where((t) => !locked.contains(t.district)).toList();
    if (options.isEmpty) return false;
    final t = rng.pick(options);
    _add(WorldEvent(
      id: _id(rng, EventType.lockdown),
      type: EventType.lockdown,
      target: t.id,
      expiresAt: ts + 7 * kDay,
      payload: {'created': ts, 'district': t.district, 'near': t.name},
    ));
    w.log(ts, 'event', '${lockdownCopy(w.player.level).title}: the district around ${t.name} is frozen');
    return true;
  }

  bool _convoy(int ts, Rng rng, List<Turf> hubs) {
    final hub = rng.pick(hubs);
    final p = _pointNear(rng, hub.lat, hub.lng, 350, 1200);
    final reward = math.max(500.0, w.index.hourly.credits * 3);
    _add(WorldEvent(
      id: _id(rng, EventType.convoy),
      type: EventType.convoy,
      target: grid.cellAt(p.latitude, p.longitude, kTurfKeyRes),
      expiresAt: ts + 4 * kHour,
      payload: {
        'created': ts,
        'lat': p.latitude,
        'lng': p.longitude,
        'hub': hub.id,
        'blueprints': rng.chance(0.3) ? 2 : 1,
        'credits': reward,
      },
    ));
    w.log(ts, 'event', '${convoyCopy(w.player.level).title} spotted near ${hub.name} · 4h window');
    return true;
  }

  bool _deadDrop(int ts, Rng rng, List<Turf> players) {
    final p = w.player;
    double lat, lng;
    if (p.lastLat != null && p.lastLng != null) {
      lat = p.lastLat!;
      lng = p.lastLng!;
    } else {
      final t = rng.pick(players);
      lat = t.lat;
      lng = t.lng;
    }
    final spot = _pointNear(rng, lat, lng, 300, 950);
    _add(WorldEvent(
      id: _id(rng, EventType.deadDrop),
      type: EventType.deadDrop,
      target: grid.cellAt(spot.latitude, spot.longitude, kTurfKeyRes),
      expiresAt: ts + kDay,
      payload: {
        'created': ts,
        'lat': spot.latitude,
        'lng': spot.longitude,
        'materials': 80 + 25.0 * p.level * rng.range(0.8, 1.4),
        'intel': 20 + 6.0 * p.level * rng.range(0.8, 1.4),
        'module': rng.chance(0.6),
      },
    ));
    w.log(ts, 'event', '${deadDropCopy(p.level).title} planted within a kilometre of your last position');
    return true;
  }

  bool _surge(int ts, Rng rng, List<Turf> players) {
    final biome = rng.pick(Biome.values);
    final ofBiome = players.where((t) => t.biome == biome).toList();
    final target = (ofBiome.isEmpty ? rng.pick(players) : rng.pick(ofBiome)).id;
    _add(WorldEvent(
      id: _id(rng, EventType.surge),
      type: EventType.surge,
      target: target,
      expiresAt: ts + 12 * kHour,
      payload: {'created': ts, 'biome': biome.key},
    ));
    w.log(ts, 'gain', '${surgeTitle(biome)}: ${biome.label} output x2 for 12h');
    return true;
  }

  bool _market(int ts, Rng rng, List<Turf> players) {
    final boom = rng.chance(0.6);
    _add(WorldEvent(
      id: _id(rng, EventType.market),
      type: EventType.market,
      target: rng.pick(players).id,
      expiresAt: ts + kDay,
      payload: {'created': ts, 'mult': boom ? 1.5 : 0.6, 'boom': boom},
    ));
    w.log(ts, boom ? 'gain' : 'loss',
        boom ? 'Street prices spiking: credits x1.5 for 24h' : 'Market crash: credits x0.6 for 24h');
    return true;
  }

  bool spawnOffensive(int ts, Rng rng, SimReport r) {
    final hubs = w.playerTurfs.where((t) => t.isHub).toList();
    if (hubs.isEmpty || w.factions.isEmpty) return false;
    hubs.sort((a, b) => b.hubLevel.compareTo(a.hubLevel));
    final hub = rng.chance(0.6) ? hubs.first : rng.pick(hubs);
    final f = rng.pick(w.factions);
    _add(WorldEvent(
      id: _id(rng, EventType.offensive),
      type: EventType.offensive,
      target: hub.id,
      expiresAt: ts + 10 * kHour,
      payload: {'created': ts, 'faction': f.id, 'fortified': false},
    ));
    final msg = '${offensiveCopy(w.player.level).title}: ${factionName(f, w.player.level)} '
        'massing on ${hub.name} · 10h';
    w.log(ts, 'loss', msg);
    r.headline(msg);
    return true;
  }
}
