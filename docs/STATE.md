# STATE — Kalıcı Proje Hafızası

> Bu dosya yürütücünün (Cursor) kalıcı hafızasıdır. Her iş başında oku, iş bitince güncelle.

| Alan | Değer |
|---|---|
| Faz | 1 — Çekirdek mekanik |
| Durum | PR açık (phase-1-core), CI bekleniyor |
| Kod adı | ShiftGrid (paket: `com.aktasilyas.shiftgrid`) |
| Son commit | phase-1 core mechanic |
| Aktif branch | `phase-1-core` |

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
  Toplam 24 test yeşil, analyze temiz.

## Sıradaki
- FAZ 2 — Seviye üreteci (ters-üretim + 1000-seed property test) → GATE 1.

## Açık riskler / notlar
- `hive_generator` analyzer 6.x'e pinliyor; ileride codegen ihtiyacı olursa sürüm çakışması izlenecek.
- Branch protection'ın kişisel private repoda uygulanıp uygulanmadığı GATE 0'da doğrulanacak.
