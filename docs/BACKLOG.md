# BACKLOG — Ertelenen İşler / Teknik Borç

Yapılamayan veya sonraya bırakılan işler burada; placeholder/TODO yerine buraya yaz.

## Açık
- [ ] **Branch protection (Pro gerekli)** — private repoda classic protection ve rulesets 403
      veriyor (bkz. DECISIONS 0006). GitHub Pro'ya geçilince veya repo public olunca etkinleştir.
- [ ] **Lisanslı/özgün ses efektleri** — `audioplayers` ile escape/hiss/win sfx
      (özellikle gerçek tıslama); lisanslar `docs/LICENSES.md`'ye
      (şu an SystemSound + haptik stand-in, bkz. DECISIONS #0009 / #0014).
- [ ] **Widget/entegrasyon testleri** — menü→seviye seçim→oyun akışı ve overlay'ler için.
- [ ] **Gerçek AdMob ID'leri** — `AdConfig` + manifest `APPLICATION_ID` test ID'leri yayından önce
      gerçek onaylı birimlerle değiştir; `AdConfig.useTestIds=false` (bkz. DECISIONS #0012).
- [ ] **IAP ürün konfigürasyonu** — Play Console'da `remove_ads` non-consumable ürünü tanımla; uçtan
      uca satın alma/geri yükleme testi.
- [ ] **UMP / rıza (GDPR/UMP consent form)** — reklam kişiselleştirme rızası entegrasyonu.
- [ ] **iOS reklam kimliği** — iOS eklenirse `Info.plist` `GADApplicationIdentifier` + SKAdNetwork.

## Kapandı
- [x] **Özgün mekanik seçimi** — Zincir-kombo + günlük seri seçildi ve DECISIONS #0011'e yazıldı.
- [x] **Store/marketing nihai ad** — ShiftGrid olarak kesinleşti.
- [x] **hive_generator sürüm yükseltmesi** — Codegen kullanılmadığı için `hive_generator`/`build_runner`
      kaldırıldı; Flutter 3.41.3 bağımlılık çözümü temiz.
- [x] **Yerel APK derleme** — JDK 21 ile API 36 emülatörde debug APK derlendi ve çalıştırıldı.
