# FAZ 0 — Envanter

Tarih: 2026-07-27 · Dal: `chore/claude-setup` (kaynak: `feat/sfx-and-density`)

## 1. Komut çıktıları

| Komut | Çıktı |
|---|---|
| `claude --version` | 2.1.70 (Claude Code) |
| `git rev-parse --abbrev-ref HEAD` | `feat/sfx-and-density` (kurulum için `chore/claude-setup` açıldı) |
| `git status --short` | `?? CLAUDE_SETUP_BRIEF.md` (tek takipsiz dosya) |
| `flutter --version` | Flutter **3.41.3** · stable · Dart 3.11.1 · DevTools 2.54.1 |
| `dart --version` | Dart SDK **3.11.1** (stable) · windows_x64 |
| `ls -la .claude/` | Yalnızca `settings.local.json` (8.7 KB, izin listesi) |
| `wc -l CLAUDE.md` | **CLAUDE.md yok** |
| `claude mcp list` | `No MCP servers configured` |
| `ls .github/workflows/` | `ci.yml` |

`pubspec.yaml` başı: `name: shiftgrid`, `version: 1.1.0+2`, `environment.sdk: ^3.10.4`.

## 2. Repo tespitleri

### Katman yapısı (Clean Architecture, feature-first)

```
lib/
  core/            ads, audio, constants, di, l10n, monetization, settings, theme, utils
  features/game/
    domain/        entities, repositories (arayüz), usecases     ← saf Dart, Flutter importu yok
    data/          datasources, models, repositories (impl)
    presentation/  painters, providers, screens, widgets
```

Bağımlılık yönü: `presentation → domain ← data`. `core/di/providers.dart` tüm
repository provider'larını tek yerden kurar; `sharedPreferencesProvider` ve
`progressStoreProvider` `main`'de `overrides` ile doldurulan `UnimplementedError`
tohum provider'larıdır.

### State yönetimi

- **flutter_riverpod ^3.3.2** (pubspec), Riverpod 3.x API'si.
- Oyun durumu: `lib/features/game/presentation/providers/game_notifier.dart` →
  `class GameNotifier extends Notifier<GameState>` + `NotifierProvider`.
  Kod üretimi (`@riverpod` annotation / build_runner) **kullanılmıyor**; provider'lar elle yazılıyor.
- `GameState` elle yazılmış immutable sınıf (`copyWith`), freezed yok.
- Bilinen tuzak (kodda yorumlanmış): Riverpod 3, widget yaşam döngüsü içinde
  (ör. `initState`) provider mutasyonunu yasaklıyor → `addPostFrameCallback` ile erteleniyor.

### Test türleri

13 test dosyası, tamamı `flutter_test`:

- **Unit / domain** (8): `board_test`, `direction_test`, `position_test`,
  `ray_escapes_test`, `try_fire_test`, `daily_challenge_test`,
  `progress_repository_test`, `streak_repository_test`.
- **Property/invariant** (1): `level_generator_property_test.dart` — zorluk başına
  seed taraması, üretilen her seviyenin çözülebilirliğini kanıtlıyor (projenin
  "kırmızıysa hiçbir şey merge olmaz" testi).
- **Provider/state** (1): `game_notifier_test.dart` — `ProviderContainer` ile.
- **Politika** (2): `ad_gate_policy_test`, `entitlement_repository_test`.
- **Widget** (1): `widget_test.dart`.
- **Golden test yok**, coverage eşiği zorlayan bir yapı yok.

### Lint yapılandırması (`analysis_options.yaml`)

`package:flutter_lints/flutter.yaml` üzerine:
- `strict-casts`, `strict-inference`, `strict-raw-types` **açık**.
- `missing_required_param` / `missing_return` → **error**, `todo` → warning.
- Ek kurallar: `always_declare_return_types`, `avoid_dynamic_calls`, `avoid_print`,
  `directives_ordering`, `prefer_const_constructors`, `prefer_const_declarations`,
  `prefer_final_locals`, `require_trailing_commas`, `unawaited_futures`,
  `use_super_parameters`.
- Hariç: `*.g.dart`, `*.freezed.dart`, `lib/core/l10n/app_localizations*.dart`.

### CI ↔ yerel sürüm uyumu

`.github/workflows/ci.yml` iki job'da da `flutter-version: 3.41.3` sabitliyor;
yerel Flutter da **3.41.3**. **Uyuşmazlık yok.** CI akışı:

- `analyze · test · domain-purity` job'ı: `pub get → gen-l10n → domain saflık kontrolü
  (`lib/features/*/domain` içinde `package:flutter` grep'i, bulursa exit 1) → analyze → test`
- `build-apk (release)` job'ı: `pub get → gen-l10n → build apk --release → artifact yükle`
- **CI'da `dart format` adımı yok** — biçimlendirme yalnızca yerelde/hook ile sağlanabilir
  (FAZ 5 format hook'unun gerekçesi).

### Dokümantasyon durumu

- `BOOTSTRAP.md` (kök) ile `docs/BOOTSTRAP.md` **byte-byte aynı** (218 satır) — kök kopya gereksiz.
- `TASKS_REVIZYON.md` (kök, 127 satır): tamamlanmış bir revizyon turunun görev listesi.
- `docs/`: BACKLOG, DECISIONS (ADR günlüğü), LEGAL, LICENSES, PRIVACY, RELEASE, SPEC, STATE.

## 3. Sonraki fazlara etkisi

- CLAUDE.md sıfırdan yazılacak (mevcut yok); BOOTSTRAP'taki kalıcı kurallar oraya süzülecek.
- Rules kapsamları hazır: `presentation/providers`, `presentation/painters`, `test/`.
- Skill'lerdeki komutlar CI'dan birebir alınacak (uydurma yok).
- Dart SDK 3.11.1 ≥ 3.9 → **dart MCP sunucusu kurulabilir** (FAZ 4 ön koşulu sağlandı).
- Golden test ve coverage eşiği yok → `/ship-check` bunları "mevcut değil" olarak raporlayacak,
  var gibi davranmayacak.
