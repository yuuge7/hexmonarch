import 'dart:math' as math;

import 'models.dart';

// Every tunable number lives here. Growth curves are exponential on both the
// cost and reward side so no level ever becomes a wall or a ceiling.

const kStartCredits = 1000.0;
const kStartMaterials = 250.0;
const kStartIntel = 50.0;

const kHour = 3600000;
const kDay = 86400000;

// ---------------------------------------------------------------- progression

int xpToNext(int level) => (60 * math.pow(level, 1.55)).round();

double levelUpBonus(int newLevel) => 50 * math.pow(newLevel, 1.5).toDouble();

/// +2% global yield per player level.
double levelYieldMult(int level) => 1 + 0.02 * (level - 1);

// ---------------------------------------------------------------- yields

Resources biomeYield(Biome b) => switch (b) {
      Biome.commercial => const Resources(credits: 10, materials: 0.6, intel: 0.2),
      Biome.municipal => const Resources(credits: 3, materials: 0.8, intel: 2.0),
      Biome.industrial => const Resources(credits: 3, materials: 4.0, intel: 0.2),
    };

Resources anomalyYieldMult(Anomaly? a) => switch (a) {
      Anomaly.dataVault => const Resources(credits: 1, materials: 1, intel: 2),
      Anomaly.blackMarket => const Resources(credits: 1.5, materials: 1, intel: 1),
      Anomaly.scrapyard => const Resources(credits: 0.8, materials: 2, intel: 1),
      _ => const Resources(credits: 1, materials: 1, intel: 1),
    };

double garrisonYieldMult(int g) =>
    (1 + 0.35 * (g - 1)) * math.pow(2, g ~/ 25).toDouble();

double hubYieldMult(int h) => (2 + 0.6 * h) * math.pow(2, h ~/ 10).toDouble();

/// Output of hexes outside every supply sphere.
const kUnsuppliedYield = 0.4;

/// Station turfs run on their own traffic: better output and no decay even
/// with no hub in reach. This is what makes "a turf at every station" viable.
const kStationSoloYield = 0.7;

/// Relay rerouting: a locked-down district still trickles this much income
/// when its hub's network spans more than one district.
const kLockdownReroute = 0.25;

double tradeMultiplier(int districts, int relays) =>
    1 + 0.30 * math.max(0, districts - 1) + 0.04 * relays;

// ---------------------------------------------------------------- defense

double garrisonDef(int g) => 12.0 * g * math.pow(1.08, g - 1);

double hubDef(int h) => h <= 0 ? 0 : 40.0 * h * math.pow(1.1, h - 1);

/// Share of a hub's defense projected onto every hex it supplies.
const kHubDefShare = 0.4;

/// Share of the whole network's hub defense pooled into each supplied hex.
const kNetworkDefShare = 0.08;

double anomalyDefMult(Anomaly? a) => a == Anomaly.bunker ? 1.5 : 1.0;

// ---------------------------------------------------------------- turf geometry

/// Rival crews keep this distance when they plant. The player's own spacing
/// comes from the Close Quarters perk (see perks.dart).
const kTurfSpacingM = 100.0;

/// Zone radius of a fresh turf: half the spacing, so two turfs planted as
/// close as the rules allow touch without overlapping.
const kTurfBaseRadiusM = 50.0;

/// Visual + interaction radius of a turf zone. Grows with its garrison.
double turfRadiusM(Turf t) =>
    math.min(140.0, kTurfBaseRadiusM + 2.5 * (t.garrison - 1)) + (t.isHub ? 25 : 0);

/// Breaching a rival turf: be inside its zone (plus GPS slack).
const kBreachSlackM = 40.0;

/// How close you must get to field events (convoys, dead drops).
const kConvoyRangeM = 150.0;
const kDropRangeM = 100.0;

/// Turfs planted at transit stations: the hub-and-spoke backbone.
const kStationCreditBonus = 1.3;
const kStationRelayBonus = 1.5;

// ---------------------------------------------------------------- supply

/// Anchor Hub supply sphere. Grows forever, slowly. Sized so one hub holds a
/// whole town with a turf per neighbourhood (2.5 km at level 1, 3.5 km at 9),
/// instead of a tight cluster around the hub.
double hubRadiusKm(int h) => 2.0 + 0.5 * math.sqrt(math.max(1, h));

/// Sized for real rail networks: neighbouring towns sit 20-40 km apart, so a
/// level-5 station hub (x1.5) reaches ~34 km. The Signal Boost perk multiplies
/// this for every hub (see perks.dart).
double relayRangeKm(int h) => 10 + 2.5 * h;

// ---------------------------------------------------------------- costs

Cost claimCost(int owned, {required double discount}) => Cost(
      credits: 60 * math.pow(1 + owned / 20, 1.5) * discount,
      materials: 5 * (1 + owned / 50) * discount,
    );

Cost garrisonCost(int g, {required double discount}) => Cost(
      credits: 80 * math.pow(1.22, g - 1) * discount,
      materials: 20 * math.pow(1.2, g - 1) * discount,
    );

/// Gentle growth: an empire spread over many towns needs a hub in each.
Cost hubEstablishCost(int hubCount, {required double discount}) => Cost(
      credits: 300 * math.pow(1.4, hubCount) * discount,
      materials: 120 * math.pow(1.35, hubCount) * discount,
    );

Cost hubUpgradeCost(int h, {required double discount}) => Cost(
      credits: 300 * math.pow(1.25, h - 1) * discount,
      materials: 120 * math.pow(1.22, h - 1) * discount,
      intel: 10 * math.pow(1.18, h - 1) * discount,
    );

Cost relayCost(double km, {required double discount}) => Cost(
      credits: 120 * math.pow(math.max(1, km), 1.2) * discount,
      materials: 12 * math.max(1, km) * discount,
      intel: 2 * math.max(1, km) * discount,
    );

Cost repairCost(Turf h) {
  final missing = (100 - h.integrity).clamp(0.0, 100.0) / 100;
  return Cost(materials: (15 + 10 * h.garrison + 30 * h.hubLevel) * missing);
}

Cost fortifyCost(int hubLevel) => Cost(
      credits: 150 * math.pow(math.max(1, hubLevel), 1.5).toDouble(),
      materials: 60 * math.pow(math.max(1, hubLevel), 1.4).toDouble(),
    );

Cost interceptCost(int tier) => Cost(intel: 8.0 * tier);

Cost lockdownCost(int tier, int districtHexes, double districtHourly) => Cost(
      credits: 3 * districtHourly + 40,
      intel: 15.0 * tier * (1 + districtHexes / 25),
    );

// ---------------------------------------------------------------- threat

/// Nemesis power. Scales with the player's best Anchor Hub (and, more gently,
/// player level + prestige cycles). No cap.
double threatPower({
  required int maxHubLevel,
  required int playerLevel,
  required int liquidations,
  required double aggression,
  required int nemesisRank,
}) {
  final heff = math.max(1, maxHubLevel) + playerLevel / 10;
  return 8 *
      heff *
      math.pow(1.1, heff - 1) *
      aggression *
      (1 + 0.1 * nemesisRank) *
      (1 + 0.25 * liquidations);
}

double raidChancePerHour(double aggression, double heat) =>
    math.min(0.8, 0.025 * aggression * (1 + heat));

/// Newcomer grace: the hostile cards stay out of the deck until the player
/// has something to lose and the means to respond.
const kLockdownMinTurfs = 5;

/// At most one district in four may be locked down at once, so a commuter who
/// cannot reach a far district still has an economy.
int maxLockdowns(int districts) => math.max(1, districts ~/ 4);
const kOffensiveMinLevel = 5;

const kHeatBase = 0.004; // per hour
const kHeatSecured = 0.012; // per hour at 100% supplied coverage
const kHeatOffensiveTrigger = 2.5;

double playerStrike(int level, double localHubDef) => 20 + 12.0 * level + 0.5 * localHubDef;

double breachChance(double strike, double enemyDef) =>
    (strike / (strike + enemyDef)).clamp(0.05, 0.95);

// ---------------------------------------------------------------- integrity

const kSuppliedRegen = 10.0; // per hour

double decayPerHour(Turf h) {
  final base = 2.0 / (1 + 0.1 * (h.garrison - 1));
  return h.anomaly == Anomaly.bunker ? base * 0.5 : base;
}

/// A raid that would take a turf you have not seen being hit leaves it
/// standing at this much instead. Rivals can only seize a turf once you have
/// opened the game since its first unanswered hit (see World.exposed).
const kLastStandIntegrity = 5.0;

// ---------------------------------------------------------------- sockets

/// Sockets a turf has from its own levels. Bought ones come on top
/// (World.socketsOf).
int socketCount(Turf h) =>
    h.isHub ? 2 + h.hubLevel ~/ 5 : 1 + (h.garrison - 1) ~/ 10;

/// Price of one more socket on a turf that already bought [extra] of them.
Cost socketExpandCost(int extra, {required double discount}) => Cost(
      credits: 1200 * math.pow(2, extra) * discount,
      materials: 400 * math.pow(2, extra) * discount,
      intel: 100 * math.pow(2, extra) * discount,
    );

// ---------------------------------------------------------------- exchange

/// What one unit of a good is worth on the exchange, in credits.
double goodValue(Good g) => switch (g) {
      Good.credits => 1.0,
      Good.materials => 2.5,
      Good.intel => 6.0,
    };

/// The fence's cut on every trade.
const kTradeFee = 0.25;

/// Credits' worth of goods the exchange will move in one day. Grows with the
/// player's level and with what the empire produces per hour.
double tradeDailyCap(int level, double hourlyValue) => 1000 + 250.0 * (level - 1) + 12 * hourlyValue;

// ---------------------------------------------------------------- offline

const kOfflineBase = 0.6;

// ---------------------------------------------------------------- prestige

const kPrestigeHexes = 50;
const kPrestigeDistricts = 3;
const kPrestigeCapitalLevel = 30;

int liquidationKeys({
  required int owned,
  required int districts,
  required int capitalLevel,
  required int liquidations,
}) {
  final k = 5 *
      math.sqrt(owned / kPrestigeHexes) *
      math.pow(districts / kPrestigeDistricts, 0.7) *
      (1 + 0.05 * (capitalLevel - kPrestigeCapitalLevel)) *
      (1 + 0.1 * liquidations);
  return math.max(1, k.floor());
}
