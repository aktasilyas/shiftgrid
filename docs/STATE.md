# STATE — Kalıcı Proje Hafızası

> Bu dosya yürütücünün (Cursor) kalıcı hafızasıdır. Her iş başında oku, iş bitince güncelle.

| Alan | Değer |
|---|---|
| Faz | 7 — Kapalı test ve yayın (kod tarafı tamam) |
| Durum | Kod tamamlandı; Play Console adımları kullanıcıda (RELEASE.md §9-10) |
| Kod adı | ShiftGrid (paket: `com.aktasilyas.shiftgrid`) |
| Son commit | phase-7 launch (CHANGELOG + kapalı test talimatları) |
| Aktif branch | `phase-7-launch` |

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
  flutter_animate mikro-etkileşimler. 39 test yeşil, analyze temiz. (PR #4 merged)
- FAZ 4: Özgün mekanik zincir-kombo (can iadesi) + günlük görev/seri (streak, pure logic + repo);
  120 seviye (zorluk başına 40); LEGAL.md §6 kontrol listesi. 51 test yeşil, analyze temiz. (GATE 2 onaylandı, PR #5 merged)
- FAZ 5: Monetizasyon — AdMob YALNIZCA test ID'leri (banner/interstitial/rewarded); interstitial
  cadence (AdGatePolicy, saf+test); rewarded ile "can için reklam izle" revive; IAP iskeleti
  (remove_ads non-consumable) + entitlement (ProgressStore); ayarlarda reklam kaldır/geri yükle.
  56 test yeşil, analyze temiz. (PR #6 merged)
- FAZ 6: Özgün ikon + adaptive launcher icons + native splash; release R8/shrink + proguard-rules;
  imzalama fallback (key.properties yoksa debug); AdConfig --dart-define; docs/RELEASE.md (store
  metni TR/EN, ASO, Data safety, IARC, Play adımları) + docs/PRIVACY.md. LEGAL 1-6,8 ✅. (PR #7 merged)
- FAZ 7: CHANGELOG.md (1.0.0); RELEASE.md §10 kapalı test tıkla-geç (12 testçi/14 gün, geri bildirim
  döngüsü, prod erişim, sürümleme). Kod tarafı TAMAM.

## Proje durumu: KOD TAMAMLANDI
Kalan tek iş kullanıcının Play Console'da manuel yapacağı adımlar (RELEASE.md §9-10) ve yayın öncesi
zorunlular (gerçek AdMob ID, remove_ads ürünü, privacy URL, UMP, ekran görüntüleri).

## Açık riskler / notlar
- `hive_generator` analyzer 6.x'e pinliyor; ileride codegen ihtiyacı olursa sürüm çakışması izlenecek.
- Yerelde JDK yok → APK yerelde derlenemiyor; APK CI'da (temurin 17) derlenip artifact olarak
  yükleniyor (bkz. DECISIONS #0008).
