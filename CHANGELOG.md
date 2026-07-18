# Changelog

All notable changes to Snake Shift (formerly ShiftGrid) are documented here.
Format loosely follows [Keep a Changelog](https://keepachangelog.com/);
versioning is `marketingVersion+buildNumber` (pubspec `version:`).

## [1.1.0+2] — 2026-07-18

Rebrand to **Snake Shift** + the "real snakes" overhaul.

### Changed
- Naturalistic snake rendering: tapered bodies with rounded bends, dorsal
  blotches, viper-shaped heads (amber slit-pupil eyes, nostrils, flicking
  forked tongue). Heads always face the actual slide direction.
- Slides are slower and serpentine — duration scales with travel distance,
  and the body follows a fixed wavy track like a real slither.
- Difficulty is now decided by the game, not the player: one 120-level
  ladder — levels 1–5 easy, then medium / hard / very hard mixed in a fixed
  deterministic pattern. Difficulty label shown under the level title.
- Denser boards: medium 9×9/13 snakes, hard 13×13/26 snakes.
- New **Very Hard** difficulty: 36×36 grid with ~160–190 interlocked snakes.
- Escapes apply instantly: tap the next snake while the previous one is
  still gliding out (each departure animates independently).
- Hint now highlights a whole currently-escapable snake (glow pulse) instead
  of flashing a cell; Undo button removed.
- Collided snakes flush red for the shake duration.
- Pinch-to-zoom (up to 4×) with pan; snake detail level adapts to the
  on-screen cell size so zooming restores full detail on dense boards.
- New snake launcher icon + splash; app renamed to **Snake Shift** with a
  matching package id (`com.aktasilyas.snakeshift` — changed before the
  first Play upload, while it was still free to change).

## [1.0.0+1] — 2026-07-17

First release candidate — feature complete, entering closed testing.

### Added
- Core mechanic: tap a multi-cell snake to let it glide off the grid when its
  path is clear; collisions hiss and cost a life (pure-Dart domain: `Snake`,
  `Board`, `tryFire`, `rayEscapes`).
- Reverse-generation level generator — variable-length intertwined snakes,
  every level guaranteed solvable (1000-seed property test per difficulty).
- 120 levels (40 each across Easy / Medium / Hard) with sequential unlock and
  best-move tracking (Hive).
- Original chain-combo mechanic: consecutive escapes refund a life every 4th;
  collisions reset the combo.
- Daily challenge with a persisted day-streak.
- Undo history and a hint that can never lead to a dead end.
- Full navigation: menu → difficulty → level select → game; settings.
- Localization: Turkish & English (system / manual override).
- Dark theme with an original palette and `flutter_animate` micro-interactions.
- Sound & haptics via `SystemSound` (no third-party audio assets).
- Monetization scaffold (TEST ads only): banner, interstitial (every 3rd win),
  rewarded "watch-ad-to-revive"; `remove_ads` IAP skeleton + entitlement.
- Release readiness: original adaptive icon, native splash, R8/shrink,
  Play App Signing-ready signing config, `--dart-define` ad IDs.

### Notes
- Ships with Google **test** AdMob IDs. Real IDs, the `remove_ads` product,
  a public privacy-policy URL and UMP consent are required before production
  (see `docs/RELEASE.md` §3).
