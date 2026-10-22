# FAZ 2 — Skills

## Şema doğrulaması (WebFetch)

`https://code.claude.com/docs/en/skills` okundu. Doğrulanan noktalar:

- Yapı: `.claude/skills/<isim>/SKILL.md`; komut adı dizin adından gelir.
- Tüm frontmatter alanları opsiyonel, **`description` önerilen**. `description` + `when_to_use`
  birleşimi skill listesinde **1.536 karakterde kesilir** → ana kullanım önce yazılır.
- `disable-model-invocation: true` → skill'i Claude kendiliğinden yükleyemez, yalnızca
  kullanıcı `/isim` ile çağırır; bağlam maliyeti sıfırdır. **Yan etkili skill'ler için önerilen.**
- `allowed-tools` skill'in çağrıldığı tur boyunca izin ister sormaz; `argument-hint`
  otomatik tamamlamada görünür.
- Gövde kısa tutulmalı: yüklendikten sonra **turlar boyunca bağlamda kalır**.

## Oluşturulanlar

| Skill | Dosya | Frontmatter | Satır |
|---|---|---|---|
| `/ship-check` | `.claude/skills/ship-check/SKILL.md` | `allowed-tools: Bash Read Grep` | 58 |
| `/release` | `.claude/skills/release/SKILL.md` | **`disable-model-invocation: true`**, `argument-hint: [patch\|minor\|major]` | 95 |
| `/feature` | `.claude/skills/feature/SKILL.md` | `argument-hint: [özellik adı]` | 75 |

Frontmatter'ların üçü de `yaml.safe_load` ile parse edildi → geçerli.

Komutlar uydurulmadı; `.github/workflows/ci.yml` ve `docs/RELEASE.md`'den alındı. `/release`
gerçek imza akışını (`android/key.properties` yoksa dur, `keytool -printcert` ile doğrula) ve
`docs/RELEASE.md` §3'teki açık yayın zorunluluklarını içerir.

`description` alanları tetikleyici olarak yazıldı: üçüncü tekil şahıs + kullanıcının gerçekten
yazacağı Türkçe ifadeler ("commit öncesi kontrol", "sürüm çıkaralım", "yeni ekran").

## Doğrulama — `/ship-check` fiilen çalıştırıldı

`Skill` aracıyla `/ship-check` çağrısı **"Unknown skill"** döndürdü: skill'ler oturum
**başlangıcında** keşfediliyor, bu oturumda oluşturuldukları için kayıtlı değiller. Beklenen
davranış; sonraki oturumda `/ship-check` çalışır. Doğrulamayı boş geçmemek için skill'in
adımları birebir elle koşuldu:

| Kontrol | Sonuç | Not |
|---|---|---|
| Kapsam | ✅ | 2 yeniden adlandırma + `.claude/`, `CLAUDE.md` (takipsiz) |
| Format | ✏️ | **24 dosya yeniden biçimlenecek** (aşağıya bak) |
| Analyze | ✅ | `No issues found!` (60.8 sn) |
| Domain saflığı | ✅ | `lib/features/*/domain` içinde `package:flutter` yok |
| Test | ✅ | **60/60 geçti** (52 sn, property testi dahil) |
| Sır taraması | ✅ | keystore/env/servis anahtarı yok |
| Geçici dosya | ✅ | `*_tmp_test.dart` kalmamış |

**Skill gerçek çıktı üretti ve gerçek bir bulgu yakaladı.**

### Bulgu: repo Dart 3.11 formatter'ından eski

`dart format lib test` → *54 dosyanın 24'ü değişti*. Sebep: Dart 3.11 ile gelen yeni
biçimlendirici (trailing-comma davranışı) repodaki mevcut biçimden farklı. CI'da format adımı
olmadığı için bu fark bugüne kadar görünmemiş.

Biçimlendirme churn'ü **kasıtlı olarak geri alındı** (`git checkout -- lib test`): 24 dosyalık
bir yeniden biçimlendirmeyi araç-kurulumu PR'ına gizlice sokmak yanlış olurdu. Bu ayrı bir PR
konusudur — RAPOR.md'de "sonraki adım" olarak öneriliyor.

Not: FAZ 5'te kurulacak format hook'u yalnızca **düzenlenen dosyaya** `dart format` uygular,
yani churn'ü tek seferde değil, dosyaya dokundukça yayar.
