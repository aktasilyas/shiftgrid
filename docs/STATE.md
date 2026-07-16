# STATE — Kalıcı Proje Hafızası

> Bu dosya yürütücünün (Cursor) kalıcı hafızasıdır. Her iş başında oku, iş bitince güncelle.

| Alan | Değer |
|---|---|
| Faz | 2 — Seviye üreteci |
| Durum | GATE 1 bekleniyor (PR açık: phase-2-generator; CI + APK artifact) |
| Kod adı | ShiftGrid (paket: `com.aktasilyas.shiftgrid`) |
| Son commit | phase-2 level generator |
| Aktif branch | `phase-2-generator` |

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
  "Yeni bölüm" akışı. Toplam 30 test yeşil.

## Sıradaki
- GATE 1 onayı sonrası FAZ 3 — Oyun döngüsü ve UI (menü, seviye seçim, Hive ilerleme, ses, tema).

## Açık riskler / notlar
- `hive_generator` analyzer 6.x'e pinliyor; ileride codegen ihtiyacı olursa sürüm çakışması izlenecek.
- Yerelde JDK yok → APK yerelde derlenemiyor; APK CI'da (temurin 17) derlenip artifact olarak
  yükleniyor (bkz. DECISIONS #0008).
