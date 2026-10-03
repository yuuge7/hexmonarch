import '../core/format.dart';
import 'models.dart';

/// Thematic tiers. The UI never changes; lore, enemies and loot do.
///
/// Pacing (see balance.dart xpToNext): Tier 2 lands after roughly 3-5 weeks of
/// regular play, Tier 3 after ~4 months. Beyond level 50 a new Epoch begins
/// every 50 levels, bumping enemy designations so late game never plateaus.
enum Tier {
  grounded(1, 'The Grounded Start', 'Rival crews, loan sharks and bent officials.'),
  syndicate(2, 'The Corporate Syndicate', 'Mercenaries and corporate spies.'),
  escalation(3, 'The Sci-Fi Escalation', 'Autonomous grids and black-ops AI.');

  const Tier(this.index1, this.title, this.blurb);
  final int index1;
  final String title;
  final String blurb;
}

const kTier2Level = 20;
const kTier3Level = 50;
const kEpochSpan = 50;

Tier tierFor(int level) {
  if (level >= kTier3Level) return Tier.escalation;
  if (level >= kTier2Level) return Tier.syndicate;
  return Tier.grounded;
}

/// 1 before the late game; 2, 3, ... for each Epoch past level 50.
int epochFor(int level) => level < kTier3Level ? 1 : 1 + (level - kTier3Level) ~/ kEpochSpan;

String tierBadge(int level) {
  final t = tierFor(level);
  final e = epochFor(level);
  return e > 1 ? 'T${t.index1} · EPOCH ${roman(e)}' : 'T${t.index1}';
}

const _factionNames = {
  Tier.grounded: ['Southside Vipers', 'Iron Row Loan Sharks', 'City Hall Ring'],
  Tier.syndicate: ['Blackwater Kinetic', 'Helix Dynamics Intel', 'Obsidian Holdings'],
  Tier.escalation: ['AEGIS Defense Grid', 'Project Chimera', 'NULL//SIGNAL'],
};

const _factionKinds = {
  Tier.grounded: ['rival crew', 'loan sharks', 'corrupt officials'],
  Tier.syndicate: ['mercenary company', 'corporate spies', 'shell conglomerate'],
  Tier.escalation: ['autonomous defense grid', 'experimental tech cell', 'black-ops AI'],
};

String factionName(Faction f, int level) {
  final base = _factionNames[tierFor(level)]![f.archetype % 3];
  final ep = epochFor(level);
  final mk = f.nemesisRank + ep;
  return mk > 1 ? '$base Mk.${roman(mk)}' : base;
}

String factionKind(Faction f, int level) => _factionKinds[tierFor(level)]![f.archetype % 3];

/// Base module designs per tier: (name, cash bias, defense bias, favored perk).
class ModuleBase {
  const ModuleBase(this.name, this.cash, this.def, this.perk);
  final String name;
  final double cash;
  final double def;
  final Perk perk;
}

const moduleBases = {
  Tier.grounded: [
    ModuleBase('Reinforced Padlocks', 0.1, 1.0, Perk.bulwark),
    ModuleBase('Bribed Informants', 0.6, 0.3, Perk.intelSiphon),
    ModuleBase('Smuggled Cash', 1.0, 0.0, Perk.materialForge),
    ModuleBase('Street Lookouts', 0.2, 0.8, Perk.autoRepair),
    ModuleBase('Burner Phone Net', 0.5, 0.4, Perk.relayRange),
    ModuleBase('Chop Shop', 0.7, 0.2, Perk.materialForge),
  ],
  Tier.syndicate: [
    ModuleBase('Drone Surveillance', 0.2, 1.0, Perk.bulwark),
    ModuleBase('Encrypted Comm Relays', 0.4, 0.5, Perk.relayRange),
    ModuleBase('Armored Convoys', 0.7, 0.6, Perk.autoRepair),
    ModuleBase('Offshore Shell Co.', 1.1, 0.0, Perk.intelSiphon),
    ModuleBase('Private Contractors', 0.1, 1.1, Perk.supplyRadius),
    ModuleBase('Signal Jammers', 0.3, 0.8, Perk.bulwark),
  ],
  Tier.escalation: [
    ModuleBase('Overclocked Cores', 1.2, 0.1, Perk.materialForge),
    ModuleBase('EMP Disruptors', 0.1, 1.2, Perk.bulwark),
    ModuleBase('Quantum Data Links', 0.6, 0.4, Perk.relayRange),
    ModuleBase('Neural Firewall', 0.2, 1.0, Perk.autoRepair),
    ModuleBase('Fusion Microcell', 0.9, 0.3, Perk.materialForge),
    ModuleBase('Graviton Lattice', 0.3, 0.9, Perk.supplyRadius),
  ],
};

const rarityPrefix = {
  Rarity.common: '',
  Rarity.uncommon: 'Tuned ',
  Rarity.rare: 'Hardened ',
  Rarity.epic: 'Prototype ',
  Rarity.legendary: 'Black-Label ',
  Rarity.mythic: 'Monarch-Class ',
};

/// Event copy per tier.
class EventCopy {
  const EventCopy(this.title, this.action);
  final String title;
  final String action;
}

EventCopy lockdownCopy(int level) => switch (tierFor(level)) {
      Tier.grounded => const EventCopy('Police Lockdown', 'Bribe the chief'),
      Tier.syndicate => const EventCopy('Corporate Security Cordon', 'Pay off the contractors'),
      Tier.escalation => const EventCopy('Grid Blackout', 'Reboot the grid'),
    };

EventCopy convoyCopy(int level) => switch (tierFor(level)) {
      Tier.grounded => const EventCopy('Armored Cash Van', 'Intercept the van'),
      Tier.syndicate => const EventCopy('Executive Motorcade', 'Ambush the motorcade'),
      Tier.escalation => const EventCopy('Autonomous Data Hauler', 'Hijack the hauler'),
    };

EventCopy deadDropCopy(int level) => switch (tierFor(level)) {
      Tier.grounded => const EventCopy('Dead Drop', 'Collect the drop'),
      Tier.syndicate => const EventCopy('Encrypted Cache', 'Crack the cache'),
      Tier.escalation => const EventCopy('Orphaned Satellite Core', 'Salvage the core'),
    };

EventCopy offensiveCopy(int level) => switch (tierFor(level)) {
      Tier.grounded => const EventCopy('Turf War', 'Fortify the hub'),
      Tier.syndicate => const EventCopy('Hostile Takeover', 'Deploy countermeasures'),
      Tier.escalation => const EventCopy('Swarm Incursion', 'Raise the shield lattice'),
    };

String surgeTitle(Biome b) => switch (b) {
      Biome.commercial => 'Rush Hour Surge',
      Biome.municipal => 'Records Leak',
      Biome.industrial => 'Freight Glut',
    };

String hubClass(int hubLevel) {
  if (hubLevel >= 30) return 'Capital';
  if (hubLevel >= 20) return 'Terminal';
  if (hubLevel >= 10) return 'Station';
  return 'Outpost';
}
