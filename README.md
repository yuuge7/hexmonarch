# HexMonarch

**An offline-first, location-based empire game for Android.** Plant turfs where you
physically stand, turn stations into Anchor Hubs, link towns with relays, and keep
scaling forever. There is no server and no account: the whole game lives in a local
SQLite file on your phone and keeps running while the app is closed.

Built with Flutter. Android only (8.0 and newer), portrait.

- [Download](#download)
- [Features](#features)
- [How it plays](#how-it-plays)
- [Development setup](#development-setup)
- [Project layout](#project-layout)
- [Architecture](#architecture)
- [Releases and versioning](#releases-and-versioning)
- [Release signing](#release-signing)
- [Contributing](#contributing)
- [Saves and data safety](#saves-and-data-safety)
- [Credits and licence](#credits-and-licence)

## Download

Get the latest APK from the [Releases page](../../releases/latest) and open it on
your phone. Android asks once for permission to install apps from that source.

- Every release is signed with the same key, so a newer release installs over an
  older one and keeps your save.
- Builds made before the first GitHub release were signed with a development key.
  Android refuses to install a release over one of those. Export your save first
  (**Network > Move to another phone > Export save**), uninstall, install the release,
  then import the save.
- The game needs precise location. Internet is only used to download map tiles the
  first time you look at an area.

The player manual is [GUIDE.md](GUIDE.md). The same file is shown in the game under
**Network > Field manual**.

## Features

- **Point turfs, Turf Wars style.** A turf is a circle planted at your exact GPS
  position, or on any open ground you tap within plant range. No visible grid, no
  adjacency rule; turfs only need to sit 100 m apart.
- **Stations as a backbone.** Turfs are named after the nearest station, landmark or
  street, read from the offline map. A turf at a transit station earns more, survives
  without a hub and relays farther. Auto-plant can claim every station you ride past.
- **Anchor Hubs and relays.** A hub supplies every turf within 2.5 km and up, enough
  for a whole town with one turf per neighbourhood. Relays link hubs in different
  towns; every linked district multiplies income.
- **Rivals that keep up.** Three AI factions hold turfs, raid yours every hour, expand
  next to you and launch offensives. Their strength follows your best hub, with no cap.
- **Jobs, perks, loot.** Energy-based jobs with mastery, permanent street perks (plant
  range, turf spacing, relay range and more), procedural modules to socket into turfs.
- **A daily Event Deck.** Lockdowns, convoys, dead drops, market swings, surges.
- **Prestige.** Network Liquidation sells the empire for permanent upgrades and rolls a
  new world.
- **Plays offline, for years.** Deterministic catch-up simulation, tamper-resistant
  game clock, save export and import for phone changes.
- **Built for outdoors.** A white high-contrast map for direct sunlight, a map-only
  mode, a roster of every turf, haptics when you cross a turf border.

## How it plays

| | |
| --- | --- |
| **Turf** | Circle zone at a point. Plant range is spacing + 250 m (350 m by default), more with the Long Arm perk. Abandon removes a turf; delete also keeps rivals and auto-plant off the spot. |
| **Station turf** | Within 250 m of a train, metro or tram station: +30% credits, relay range x1.5 as a hub, runs at 70% with no hub. One per station. |
| **Anchor Hub** | Any turf can become one. Supply sphere `2.0 + 0.5 x sqrt(level)` km. Each extra hub costs x1.4 more. Unsupplied ordinary turfs yield 40% and wear down to a floor; they are never deleted by decay. |
| **Relay** | One outbound link per hub, range `10 + 2.5 x level` km, x1.5 from a station hub, +20% per Signal Boost rank. Trade multiplier `1 + 0.30 x extra districts + 0.04 x relays`. |
| **Jobs** | Energy 15/h, cap 30. x1.5 pay inside your own turf, mastery every 10 runs. |
| **Street perks** | Long Arm, Deep Reach, Close Quarters, Signal Boost, Muscle, Deep Bench, Second Wind, Street Smarts, Safehouses. Kept through prestige. |
| **Event Deck** | 2 to 4 cards every 24 h: lockdown, convoy, dead drop, market, surge, offensive. |
| **Prestige** | 1,000 turfs, 3 regions linked by relays, a level 30 hub. Pays Offshore Cryptokeys for infinite vault upgrades. |

Player levels move the story through three tiers (Grounded Start, Corporate Syndicate,
Sci-Fi Escalation), then a new Epoch every 50 levels.

## Development setup

These steps take a fresh machine (Windows, macOS or Linux) to a running build.

### 1. Install the tools

| Tool | Version | Notes |
| --- | --- | --- |
| [Flutter](https://docs.flutter.dev/get-started/install) | 3.47 stable (Dart 3.13) | CI builds with exactly 3.47.0 |
| JDK | 17 or newer | CI uses Temurin 21 |
| Android SDK | a recent platform, build-tools, platform-tools | Easiest through Android Studio. Missing pieces (platform, NDK, CMake) download on the first build. |
| Git | any recent | |

Run `flutter doctor` and fix whatever it reports for the Android toolchain. No API
keys, no accounts and no `.env` file are needed.

### 2. Get the code and run it

```
git clone https://github.com/<owner>/hexmonarch.git
cd hexmonarch
flutter pub get
flutter run
```

`flutter run` needs a phone with USB debugging or a running emulator
(`flutter emulators --launch <name>`). The first build takes several minutes: it
also builds the native parts (SQLite, H3).

### 3. Everyday commands

```
flutter analyze                    # must report no issues
flutter test                       # 43 engine tests, no device needed
flutter build apk --release        # release APK in build/app/outputs/flutter-apk/
dart run build_runner build        # only after editing lib/data/schema.drift
dart format <files you changed>    # page width 120, set in analysis_options.yaml
```

A release build works without the signing key: it falls back to your local debug key
(see [Release signing](#release-signing)).

### 4. Testing on an emulator

The game is driven by GPS, so set a position by hand:

```
adb emu geo fix <longitude> <latitude>     # longitude first
```

The location provider only reports when the position changes, so nudge the coordinates
after launching the app. Debug builds add two tools that release builds do not have:

- Long-press the map to teleport there.
- **Network > Debug** warps the game clock by 1, 8 or 24 hours to exercise offline
  catch-up, raids and the Event Deck.

Vector tiles for a dense city are large; the first render after a cold start can take
around ten seconds on an emulator.

## Project layout

```
lib/
  core/        theme tokens (Palette, MapInk), number formatting, deterministic RNG
  data/        schema.drift and the drift database (WAL, batched writes)
  geo/         HexGrid abstraction and its H3 implementation (FFI)
  domain/      pure game rules, no Flutter imports
    balance.dart     every tunable number
    world.dart       in-memory state and the derived index (supply, networks, yields)
    simulation.dart  catch-up engine, raids, Event Deck director
    actions.dart     player commands with quotes (cost and blocker)
    perks.dart, jobs.dart, loot.dart, tiers.dart, vault.dart, genetics.dart
    time_guard.dart  anti-tamper clock verdict
  game/        GameController (clock, GPS, persistence), Repository, SaveFile
  platform/    native channel, location service, vector tile cache, place namer
  ui/          home screen, map painters, console panels, turf roster, manual
test/          engine tests on a pure-Dart grid stand-in (no device, no H3)
assets/map/    two vector map styles: dark, and white for sunlight
android/       Gradle project, MainActivity.kt (clock and haptics channel)
.github/       release workflow and its version script
GUIDE.md       player manual, bundled into the app
```

## Architecture

- **The domain is pure Dart.** Everything under `lib/domain` runs without Flutter or a
  device, which is what lets `flutter test` cover the game rules. Numbers live in
  `balance.dart` and `perks.dart`, not scattered through the code.
- **One simulation for foreground and offline.** Income accrues continuously inside
  each hour; raids, pressure and the Event Deck roll on hour boundaries seeded by
  `(world seed, hour index)`. Catching up after a week away replays the same loop.
- **The game keeps its own clock.** Between sessions it advances by Android's monotonic
  timer while the boot count is unchanged, so changing the device date earns nothing.
  After a reboot the wall clock is checked against the last sync and against network
  time when available.
- **H3 is underneath, never drawn.** Resolution 11 cell is the turf key, resolution 9
  the "block" that decides biome, anomaly and rival spawns, resolution 5 the district
  (town-sized, drives trade and lockdowns), resolution 4 the region (prestige gate).
- **Persistence is batched.** The `World` marks what changed; `Repository.flush` writes
  it in one transaction. Settings and small lists (for example deleted-turf spots) live
  in the player row's JSON, so they need no schema change.
- **The map is offline after first sight.** `flutter_map` with `vector_map_tiles`,
  OpenMapTiles schema served by OpenFreeMap with no API key. Tiles are stored for good
  under app support `vtiles/z/x/y.pbf`; the place namer reads station and street names
  from the same tiles. Everything painted over the basemap takes its colours from
  `MapInk`, which has a dark set and a sunlight set.

## Releases and versioning

Releases are automatic. [.github/workflows/release.yml](.github/workflows/release.yml)
runs on every push to `main`:

1. Picks the version ([.github/scripts/next-version.sh](.github/scripts/next-version.sh)).
2. Runs `flutter analyze` and `flutter test`.
3. Builds the release APK and checks that it is signed with the project key.
4. Commits the version bump to `main`, if there was one.
5. Publishes a GitHub release named **HexMonarch vX.Y** with tag `vX.Y` and
   `HexMonarch-vX.Y.apk` attached.

The version comes from `version: X.Y.Z+BUILD` in `pubspec.yaml`:

- If `vX.Y` has not been released yet, that version is released as it is. This covers
  the first release and a version raised by hand.
- If `vX.Y` already exists, the minor goes up (`0.4` to `0.5`) until the tag is free.
- The build number (Android `versionCode`) always ends up higher than in the previous
  release, so every release installs as an update.

A push can therefore never overwrite an existing release. What this means in practice:

- **Do not edit the version for normal work.** The workflow does it.
- **For a new major version**, set `version: 1.0.0+<build>` in `pubspec.yaml` yourself
  and push; it is released as `v1.0`, then `v1.1`, `v1.2` and so on.
- **Pull after pushing.** The bump is a commit made by `github-actions[bot]` on `main`
  (message `chore: release vX.Y ... [skip ci]`).
- If the build or a test fails, nothing is published and no version is used up.
- Branch protection that blocks pushes to `main` also blocks the bump commit: allow
  GitHub Actions to bypass it, or releases after the first will fail.

The Flutter version used by CI is pinned in the workflow (`FLUTTER_VERSION`). Raise it
there when the project moves to a newer Flutter.

## Release signing

Android only installs an update when it is signed with the same key as the installed
app. HexMonarch releases are signed with one key, kept **outside git**:

| File (project root) | What it is |
| --- | --- |
| `hexmonarch-release.jks` | the keystore: one RSA 4096 key, alias `hexmonarch`, valid until 2056 |
| `key.properties` | the keystore file name, alias and passwords, read by `android/app/build.gradle.kts` |

Both are listed in `.gitignore`. Certificate SHA-256, for anyone who wants to check
that an APK is genuine:

```
7F:73:74:3E:9A:72:4A:7B:55:1C:FF:D2:A2:22:64:44:95:06:FF:E1:02:67:98:86:73:51:34:D7:6B:D3:DD:FD
```

### Contributors

You do not need the key. Without `key.properties`, release builds are signed with your
local debug key. Such a build runs fine but cannot be installed over an official
release; uninstall first, or just use `flutter run`.

### Maintainer: keeping the key

Losing these two files means no future build can update an existing install; every
player would have to export the save, uninstall and reinstall. So:

- Back up `hexmonarch-release.jks` and `key.properties` in at least two private places
  (a password manager that stores files, an encrypted drive). Never in the repository,
  an issue, a chat or an email.
- Never regenerate the keystore. A new key is a different app as far as Android cares.

### Maintainer: using the key on another machine

1. Set the project up as in [Development setup](#development-setup).
2. Copy `hexmonarch-release.jks` and `key.properties` from your backup into the project
   root, next to `pubspec.yaml`. Keep the file names.
3. Build and check the signature:

   ```
   flutter build apk --release
   keytool -list -v -keystore hexmonarch-release.jks
   ```

   `keytool` asks for the store password from `key.properties` and must print the
   SHA-256 shown above. `git status` must not list either file.

### Maintainer: giving the key to GitHub Actions

The release workflow rebuilds both files from four repository secrets
(**Settings > Secrets and variables > Actions > New repository secret**):

| Secret | Value |
| --- | --- |
| `KEYSTORE_BASE64` | the keystore file, base64-encoded on one line |
| `KEYSTORE_PASSWORD` | `storePassword` from `key.properties` |
| `KEY_ALIAS` | `keyAlias` from `key.properties` (`hexmonarch`) |
| `KEY_PASSWORD` | `keyPassword` from `key.properties` |

To put the base64 text on the clipboard:

```
# Windows PowerShell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("hexmonarch-release.jks")) | Set-Clipboard

# Git Bash or Linux
base64 -w 0 hexmonarch-release.jks

# macOS
base64 -i hexmonarch-release.jks | pbcopy
```

With the [GitHub CLI](https://cli.github.com/), from the project root:

```
base64 -w 0 hexmonarch-release.jks | gh secret set KEYSTORE_BASE64
gh secret set KEYSTORE_PASSWORD
gh secret set KEY_ALIAS --body hexmonarch
gh secret set KEY_PASSWORD
```

The workflow stops with a clear error when a secret is missing, and refuses to publish
an APK whose certificate does not match the SHA-256 above.

## Contributing

Issues and pull requests are welcome.

1. Fork, then branch from `main` (`feature/<short-name>` or `fix/<short-name>`).
2. Make the change. Keep `flutter analyze` clean and `flutter test` green; add or
   update a test in `test/engine_test.dart` for any rule or number you touch.
3. Run `dart format` on the files you changed (not on the whole tree: older files
   are not formatter-clean yet) and open a pull request that says what changed for
   the player and how you tested it. A merge to `main` ships a release.

House rules:

- **Game rules go in `lib/domain`**, with no Flutter imports. Tunable numbers go in
  `balance.dart` or `perks.dart`.
- **Update [GUIDE.md](GUIDE.md) with every gameplay change**, numbers included, and add
  a line under "What's new". It is shown in the game, so stale text reaches players.
  Its renderer understands `#`, `##`, `- ` bullets, paragraphs and `**bold**` only.
- **Never break a save.** No destructive database migration: add columns and tables in
  `database.dart` `onUpgrade`, and give new columns a default in
  `Repository._columnDefaults` so older save files still import.
- **Territory stays point-based.** Do not draw the H3 grid or add grid-cell claiming.
- **Map painters use `MapInk`**, never `Palette` directly, so both map styles keep
  working. Give a new map style its own `id`, or the tile layer will not restyle.
- **Do not change the version or the signing setup** in a pull request.

## Saves and data safety

- **Export and import** (Network tab) write the whole database as gzip-JSON rows
  (`.hexsave`) through the system file picker, with no storage permission. Rows rather
  than a raw SQLite file, so a save from an older version still imports.
- **Schema upgrades keep the save** from schema version 2 on.
- Android Auto Backup and device-to-device transfer carry the database as well. Map
  tiles are excluded; they download again.

## Credits and licence

- Map data © [OpenStreetMap](https://www.openstreetmap.org/copyright) contributors
  (ODbL). Tile schema © [OpenMapTiles](https://openmaptiles.org/) (CC-BY 4.0). Tiles
  hosted by [OpenFreeMap](https://openfreemap.org/). The attribution is shown on the map.
- Fonts: Chakra Petch and JetBrains Mono, both under the SIL Open Font License
  (`assets/fonts/OFL-*.txt`).
- Spatial index: [H3](https://h3geo.org/) by Uber (Apache 2.0).

No licence has been chosen for the project's own code yet. Until a `LICENSE` file is
added, the source is published for reading and for contributions to this repository.
