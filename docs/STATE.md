# STATE — Kalıcı Proje Hafızası

> Bu dosya yürütücünün (Cursor) kalıcı hafızasıdır. Her iş başında oku, iş bitince güncelle.

| Alan | Değer |
|---|---|
| Faz | 7+ — Snake mekaniği (çekirdek yeniden konumlandırma) |
| Durum | feat/snake-mechanics: çok hücreli yılan + property test yeşil |
| Kod adı | ShiftGrid (paket: `com.aktasilyas.snakeshift`) |
| Son commit | (snake PR bekliyor) |
| Aktif branch | `feat/snake-mechanics` |

## Ortam
- Flutter 3.41.3 · Dart 3.11.1 (Windows) · JDK 21.0.8
- gh 2.95.0 (aktasilyas), git 2.54.0
- Platform hedefi: Android (minSdk 24, target/compile 36)

## Tamamlananlar
- FAZ 0–7: bkz. önceki STATE (kod tamamlandı, Play Console kullanıcıda).
- **Snake pivot (DECISIONS #0014):** `Arrow` → `Snake` (değişken uzunluk, kıvrımlı gövde);
  Board occupancy çok hücreli; üreteç ters-üretim + escape-ray self-block koruması;
  BoardPainter teal gövde + amber gözlü baş; `SoundEffect.hiss`; l10n/RELEASE/SPEC güncel.
  58 test yeşil (1000 seed × 3 zorluk), analyze temiz.

## Proje durumu
Snake mekaniği kod + test tamam. Kalan yayın işleri: RELEASE.md §9-10 + gerçek AdMob/IAP/UMP/
ekran görüntüleri. Lisanslı tıslama SFX → BACKLOG.

## Açık riskler / notlar
- Yerel Android debug derleme API 36 emülatörde doğrulanmıştı; snake PR sonrası yeniden smoke test önerilir.
