# STATE — Kalıcı Proje Hafızası

> Bu dosya yürütücünün (Cursor) kalıcı hafızasıdır. Her iş başında oku, iş bitince güncelle.

| Alan | Değer |
|---|---|
| Faz | 3 — Oyun döngüsü ve UI |
| Durum | PR açık (phase-3-gameloop), CI bekleniyor |
| Kod adı | ShiftGrid (paket: `com.aktasilyas.shiftgrid`) |
| Son commit | phase-3 game loop & UI |
| Aktif branch | `phase-3-gameloop` |

## Ortam
- Flutter 3.38.5 · Dart 3.10.4 (Windows)
- gh 2.95.0 (aktasilyas), git 2.54.0
- Platform hedefi: Android (minSdk 24, target/compile 36)

## Tamamlananlar
- FAZ 0: flutter create, Clean Architecture klasörleri, strict lint, l10n (TR/EN),
  Riverpod iskeleti, docs, .cursor/rules, .gitignore (secrets), CI workflow. (PR #1 merged)
- FAZ 1: Domain (Direction/Position/Arrow/Board, rayEscapes/tryFire) saf Dart + 19 birim test;
  BoardPainter (CustomPainter) + BoardGeometry (tap→grid); Riverpod GameNotifier + GameState;
  oynanabilir GameScreen (kayma animasyonu + shake/haptic + kalp/can + kazan/kaybet overlay).
  Toplam 24 test yeşil, analyze temiz. (PR #2 merged)
- FAZ 2: Ters-üretim `LevelGenerator` (deterministik, seed'li) + `Difficulty` profilleri
  (easy/medium/hard) + açık-atış kapısı (>oran → üret-ve-at). Property test: 1000 seed × 3 zorluk
  hepsi çözülebilir + determinizm testi. Generator GameNotifier'a bağlandı (elle demo kaldırıldı);
  "Yeni bölüm" akışı. Toplam 30 test yeşil. (PR #3 merged)
- FAZ 3: Menü → zorluk → seviye seçim → oyun navigasyonu; Hive ilerleme (tamamlanma + en iyi hamle,
  sıralı kilit açma); ayarlar (shared_preferences: ses + dil TR/EN/sistem); SoundController
  (SystemSound + haptik, lisanssız asset yok); undo (history) + ipucu (max-id invariantı);
  flutter_animate mikro-etkileşimler. 39 test yeşil, analyze temiz.

## Sıradaki
- FAZ 4 — Farklılaştırma ve içerik (özgün mekanik, günlük görev, 100+ seviye) → GATE 2 (LEGAL).

## Açık riskler / notlar
- `hive_generator` analyzer 6.x'e pinliyor; ileride codegen ihtiyacı olursa sürüm çakışması izlenecek.
- Yerelde JDK yok → APK yerelde derlenemiyor; APK CI'da (temurin 17) derlenip artifact olarak
  yükleniyor (bkz. DECISIONS #0008).
