# Changelog

All notable changes to ShiftGrid are documented here.
Format loosely follows [Keep a Changelog](https://keepachangelog.com/);
versioning is `marketingVersion+buildNumber` (pubspec `version:`).

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
