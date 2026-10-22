---
name: release
description: Walks through the Snake Shift release workflow — version bump, CHANGELOG entry, quality gate, signed appbundle build and Play Console upload steps. Use when the user says "sürüm çıkaralım", "release al", "yeni versiyon", "Play'e yükleyelim", "AAB al" or asks to publish/ship a new build.
disable-model-invocation: true
argument-hint: [patch|minor|major]
---

# Release — Snake Shift yayın akışı

Yan etkili bir akış: sürüm numarasını değiştirir, imzalı paket üretir. Adımları sırayla yürüt,
her adımın çıktısını göster. **Kullanıcı onayı olmadan hiçbir şey Play'e yüklenmez.**

Referans: `docs/RELEASE.md` (store metinleri, Data Safety cevapları, kapalı test kuralları).

## 1. Ön koşullar

- Çalışma ağacı temiz olmalı (`git status --short` boş). Değilse dur ve söyle.
- Dal `main` olmamalı; değişiklikler PR ile gider.
- İmza için `android/key.properties` var mı bak. **Yoksa dur** — bu dosyayı kullanıcı
  oluşturur (şifre içerir, sen yazmazsın). Yoksa build debug anahtarıyla imzalanır ve
  Play kabul etmez.

## 2. Sürüm artır

`pubspec.yaml` içindeki `version: <marketing>+<build>` satırı tek doğruluk kaynağıdır.
Argüman verilmişse (`patch|minor|major`) ona göre artır, verilmemişse patch varsay.
**Build numarası her yüklemede mutlaka artar** — Play aynı build numarasını ikinci kez kabul etmez.

## 3. CHANGELOG

`CHANGELOG.md` başına Keep a Changelog biçiminde yeni sürüm bloğu ekle:
`## [<sürüm>] — <YYYY-AA-GG>` + `### Added/Changed/Fixed`. Maddeleri son sürümden bu yana
gelen commit'lerden çıkar (`git log --oneline <son-tag-veya-sürüm>..HEAD`), uydurma.

## 4. Kalite kapısı

Şunları çalıştır, hepsi yeşil olmadan devam etme:

```bash
flutter pub get
flutter gen-l10n
dart format lib test
flutter analyze
flutter test
```

Detaylı kapı için `/ship-check` skill'ini kullanabilirsin.

## 5. Paket üret

```bash
flutter build appbundle --release
```

Gerçek reklam kimlikleriyle üretim yapılıyorsa (bkz. `docs/RELEASE.md` §3):

```bash
flutter build appbundle --release \
  --dart-define=ADMOB_BANNER=... --dart-define=ADMOB_INTERSTITIAL=... --dart-define=ADMOB_REWARDED=...
```

Çıktı: `build/app/outputs/bundle/release/app-release.aab`.

## 6. İmzayı doğrula

```bash
keytool -printcert -jarfile build/app/outputs/bundle/release/app-release.aab
```

Sertifika sahibi kullanıcının upload anahtarı olmalı. `Owner: CN=Android Debug` görünüyorsa
**dur** — paket debug anahtarıyla imzalanmış, Play reddeder.

Paket kimliğinin doğru olduğunu da doğrula (`com.aktasilyas.snakeshift`); Play'de kilitlidir,
değişmiş olamaz.

## 7. Commit ve etiket

Sürüm artışını `chore(release): v<sürüm>` mesajıyla commit'le. Etiket atmayı kullanıcıya sor;
`main`'e doğrudan push yapma.

## 8. Play Console (kullanıcı yapar)

Bu adımlar tıkla-geçtir, `docs/RELEASE.md` §9–10'da ayrıntılı:

1. Testing → Closed testing → Create release → AAB yükle.
2. Sürüm notlarını CHANGELOG'dan `<tr-TR>` etiketleri içinde yapıştır.
3. Review → Rollout (geri alınamaz — kullanıcı basar).
4. Kapalı test kuralı: **en az 12 testçi, 14 gün kesintisiz**, sonra production erişimi.

## Yayın öncesi hatırlatmalar

Halen açık olan zorunluluklar (`docs/RELEASE.md` §3): gerçek AdMob kimlikleri ve manifest
`APPLICATION_ID`, `remove_ads` ürününün Play'de tanımlanması, herkese açık gizlilik
politikası URL'i, UMP rıza formu. Bunlar tamamlanmadan **production**'a çıkma; kapalı test
için test kimlikleri yeterli.
