# STATE — Kalıcı Proje Hafızası

> Bu dosya yürütücünün (Cursor) kalıcı hafızasıdır. Her iş başında oku, iş bitince güncelle.

| Alan | Değer |
|---|---|
| Faz | 0 — Altyapı |
| Durum | GATE 0 bekleniyor (PR açık, CI kontrol ediliyor) |
| Kod adı | ShiftGrid (paket: `com.aktasilyas.shiftgrid`) |
| Son commit | phase-0 scaffold |
| Aktif branch | `phase-0-bootstrap` |

## Ortam
- Flutter 3.38.5 · Dart 3.10.4 (Windows)
- gh 2.95.0 (aktasilyas), git 2.54.0
- Platform hedefi: Android (minSdk 24, target/compile 36)

## Tamamlananlar
- FAZ 0: flutter create, Clean Architecture klasörleri, strict lint, l10n (TR/EN),
  Riverpod iskeleti, docs, .cursor/rules, .gitignore (secrets), CI workflow.

## Sıradaki
- GATE 0 onayı sonrası FAZ 1 — Çekirdek mekanik (Direction/Arrow/Board/rayEscapes/tryFire).

## Açık riskler / notlar
- `hive_generator` analyzer 6.x'e pinliyor; ileride codegen ihtiyacı olursa sürüm çakışması izlenecek.
- Branch protection'ın kişisel private repoda uygulanıp uygulanmadığı GATE 0'da doğrulanacak.
