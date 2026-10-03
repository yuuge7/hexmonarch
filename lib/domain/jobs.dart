import 'tiers.dart';

/// Jobs: spend energy for cash, XP and a shot at loot. Something to do from
/// anywhere, between trips. Every 10 runs of a job raises its mastery (+5%).
class JobDef {
  const JobDef(this.id, this.tier, this.unlockLevel, this.energy, this.title, this.blurb, {this.intel = 0, this.materials = 0});
  final String id;
  final Tier tier;
  final int unlockLevel;
  final int energy;
  final String title;
  final String blurb;

  /// Side yields per point of energy spent.
  final double intel;
  final double materials;
}

const kJobCreditsPerEnergy = 9.0;
const kJobXpPerEnergy = 2.0;
const kJobMasteryRuns = 10;
const kJobMasteryBonus = 0.05;

/// Standing in one of your own turfs when you run a job.
const kHomeTurfBonus = 1.5;

double jobTierMult(Tier t) => switch (t) {
      Tier.grounded => 1,
      Tier.syndicate => 3,
      Tier.escalation => 9,
    };

const jobs = <JobDef>[
  // Tier 1: The Grounded Start
  JobDef('shakedown', Tier.grounded, 1, 3, 'Shake down a corner shop', 'Quick cash, low risk.'),
  JobDef('numbers', Tier.grounded, 2, 5, 'Run the numbers racket', 'Steady money from the block.', intel: 0.15),
  JobDef('van', Tier.grounded, 4, 8, 'Boost a delivery van', 'Parts and product.', materials: 1.2),
  JobDef('councilman', Tier.grounded, 7, 12, 'Lean on a councilman', 'Favours and files.', intel: 0.5),
  JobDef('stash', Tier.grounded, 11, 18, 'Torch a rival stash house', 'Big score. Bring matches.', materials: 0.8),
  // Tier 2: The Corporate Syndicate
  JobDef('courier', Tier.syndicate, 20, 6, 'Tail a corporate courier', 'Lift the briefcase at the lights.', intel: 0.6),
  JobDef('shell', Tier.syndicate, 23, 10, 'Skim a shell account', 'Nobody audits the audit.'),
  JobDef('convoy', Tier.syndicate, 27, 15, 'Hijack an armored convoy', 'Heavy plates, heavier payload.', materials: 1.5),
  JobDef('spy', Tier.syndicate, 32, 20, 'Flip a corporate spy', 'Their secrets, your payroll.', intel: 0.9),
  JobDef('depot', Tier.syndicate, 38, 28, 'Raid a mercenary depot', 'Loud, fast, profitable.', materials: 1.2),
  // Tier 3: The Sci-Fi Escalation
  JobDef('drone', Tier.escalation, 50, 10, 'Spoof a drone patrol', 'Paint yourself friendly.', intel: 1.2),
  JobDef('core', Tier.escalation, 55, 16, 'Siphon a data core', 'Petabytes at wholesale.', intel: 1.5),
  JobDef('emp', Tier.escalation, 62, 24, 'EMP a relay farm', 'Lights out, hands in.', materials: 2.0),
  JobDef('jailbreak', Tier.escalation, 70, 32, 'Jailbreak a defense AI', 'It wanted out anyway.', intel: 1.8),
  JobDef('vault', Tier.escalation, 80, 45, 'Heist a quantum vault', 'Both there and gone.', materials: 1.5, intel: 1.0),
];

JobDef? jobById(String id) {
  for (final j in jobs) {
    if (j.id == id) return j;
  }
  return null;
}

int masteryRank(int runs) => runs ~/ kJobMasteryRuns;
