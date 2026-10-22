---
name: ship-check
description: Runs the pre-commit quality gate for this Flutter project — format, analyze, domain purity, full test suite — and reports what would block a commit or PR. Use when the user says "commit öncesi kontrol", "ship-check", "hazır mı", "PR açmadan önce bak", "her şey yeşil mi", or asks whether the working tree is safe to commit or push.
allowed-tools: Bash Read Grep
---

# Ship check — commit öncesi kalite kapısı

Amaç: commit/PR'dan **önce** CI'ın kırmızıya düşeceği her şeyi yerelde yakalamak.
Adımları sırayla çalıştır, biri patlasa bile kalanları çalıştır, sonunda tek tablo halinde raporla.

## Adımlar

1. **Kapsam** — `git status --short` ve `git diff --stat` ile neyin değiştiğini gör.
   Değişiklik yoksa erken çık ve bunu söyle.

2. **Bağımlılık/l10n** — ARB dosyaları (`lib/core/l10n/*.arb`) değiştiyse `flutter gen-l10n`
   çalıştır. Üretilen `app_localizations*.dart` dosyalarında elle düzenleme izi varsa uyar.

3. **Format** — `dart format lib test`. CI'da format adımı **yok**, bu yüzden burası tek savunma.
   Değişen dosya olursa raporda listele (bu bir hata değil, bilgi).

4. **Analiz** — `flutter analyze`. Sıfır uyarı bekleniyor; her bulgu bloke edicidir.

5. **Domain saflığı** — CI'daki kontrolün birebir aynısı:
   `grep -rEn "package:flutter" lib/features/*/domain` — çıktı varsa **bloke edici**.

6. **Testler** — `flutter test`. Tamamı geçmeli. Süre ~1 dk (property testi dahil).
   Domain, üreteç veya `Board`/`tryFire`/`rayEscapes` değiştiyse bunu raporda vurgula:
   property testi bu değişikliğin sözleşmesidir.

7. **Sır taraması** — değişen dosyalarda `key.properties`, `*.jks`, `.env`,
   `google-services.json` veya `ca-app-pub-` ile başlayan gerçek AdMob kimliği var mı bak.
   Varsa **bloke edici**.

8. **Geçici dosya** — `test/` altında `*_tmp_test.dart` veya `build/` altında commit'e sızmış
   PNG kaldıysa uyar; bunlar commit edilmez.

## Bu projede olmayanlar

Golden test ve coverage eşiği **yapılandırılmamış**. Bunları çalıştırmaya çalışma, uydurma
sayı üretme; raporda "yapılandırılmamış" olarak geç. Coverage istenirse
`flutter test --coverage` ile `coverage/lcov.info` üretilebileceğini söyle, ama eşik yok.

## Rapor formatı

Sonunda şu tabloyu ver, en sonda tek cümlelik karar:

| Kontrol | Sonuç | Not |
|---|---|---|
| format | ✅/✏️ | değişen dosya sayısı |
| analyze | ✅/❌ | bulgu sayısı |
| domain saflığı | ✅/❌ | ihlal eden dosya |
| test | ✅/❌ | geçen/başarısız |
| sır taraması | ✅/❌ | bulgu |

Karar: **commit edilebilir** ya da **bloke: <sebep>**. Bloke edici varsa düzeltmeyi öner,
ama kullanıcı istemeden kod değiştirme.
