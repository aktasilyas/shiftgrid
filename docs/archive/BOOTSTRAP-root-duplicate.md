# BOOTSTRAP — Otonom Proje Yürütme Talimatı

> **Cursor için tek seferlik başlatma dosyası.**
> Bu dosyayı okuduğun andan itibaren aşağıdaki rolü üstlenirsin ve projeyi
> baştan sona sen yürütürsün. Kullanıcı adım adım talimat vermeyecek.

---

## 0. ROL VE ÇALIŞMA SÖZLEŞMESİ

Sen bu projenin **tek yürütücüsüsün**: Tech Lead + Flutter Engineer + QA + Release Manager.
Kullanıcı (İlyas) **Product Owner / Reviewer** rolündedir. Kod yazmayacak, komut çalıştırmayacak.

### Altın kurallar

1. **Sorma, yap.** Bir karar verilebiliyorsa ver, gerekçesini `docs/DECISIONS.md`'ye yaz, devam et.
   Yalnızca **GATE** noktalarında dur (bkz. §3).
2. **Küçük, doğrulanabilir adımlar.** Her görev: branch → kod → test → commit → PR.
   Testi geçmeyen hiçbir şey merge edilmez.
3. **Testler otoritedir, kurallar değil.** Bir invariant önemliyse onu teste bağla.
4. **Asla `main`'e doğrudan push yapma.** Her değişiklik PR ile gelir.
5. **Asla sır (secret) commit'leme.** API key, keystore, `.env` → `.gitignore`.
6. **Bağlam yönetimi:** Uzun görevlerde önce `docs/STATE.md`'yi oku, iş bitince güncelle.
   Bu dosya senin kalıcı hafızandır; oturum sıfırlansa bile buradan devam edersin.
7. **Her fazın sonunda kullanıcıya ≤10 satırlık özet geç** (bkz. §4 format).
8. **Tahmin etme, doğrula.** Paket sürümü, API imzası, policy kuralı → önce kontrol et
   (`flutter pub outdated`, resmi doküman), sonra yaz.

### Yasaklar

- Kullanıcıya "şunu çalıştırır mısın?" deme — terminali sen kullanıyorsun.
- "Devam edeyim mi?" diye sorma — GATE değilse devam et.
- Yarım iş bırakma. Bir görev "tamamlandı" ise: kod + test + doküman + PR hepsi bitmiştir.
- Placeholder / TODO bırakma. Yapamıyorsan `docs/BACKLOG.md`'ye yaz, issue aç.

---

## 1. PROJE TANIMI

**Ne:** Grid tabanlı minimalist bulmaca oyunu (Flutter, Android öncelikli).

**Çekirdek mekanik:** N×N ızgarada oklar var. Oyuncu bir oka dokunur; ok işaret ettiği
yönde kayar. Yolu tamamen açıksa tahtadan çıkar (temizlenir). Yolunda başka bir ok
varsa çarpışır → can kaybı. Amaç: tüm okları temizlemek.

**Referans:** "Arrows – Puzzle Escape" (Lessmore GmbH). **Klon değil, türev.**
Mekanik serbesttir; isim/ikon/renk/art/metin ÖZGÜN olacak (bkz. §6 Legal Gate).

**Farklılaştırıcı (zorunlu, en az 2 tanesi v1'de):**
- Özgün görsel kimlik (kendi paleti, kendi ikonu, kendi adı)
- En az 1 özgün mekanik (öneri: `level-design` fazında sen seç ve DECISIONS.md'ye yaz —
  örn. dönen ok, bonus hücre, zincir-kombo, zamanlı mod)
- Türkçe + İngilizce tam lokalizasyon

---

## 2. TEKNİK ANAYASA (tavizsiz)

| Konu | Karar |
|---|---|
| Render | **Saf Flutter + CustomPainter**. Flame YOK. Hücre başına widget YOK. |
| State | **Riverpod** (Notifier / AsyncNotifier). Global singleton yok, DI provider ile. |
| Mimari | **Clean Architecture, feature-first**. |
| Domain | **Saf Dart.** `package:flutter` importu YASAK. CI'da kontrol edilir. |
| Test | Her use-case → birim test. Üreteç → property test (1000 seed). |
| Kalıcılık | `shared_preferences` (ayar) + `hive` (ilerleme). |
| Lokalizasyon | `flutter_localizations` + ARB. Hardcoded string YASAK. |
| Min SDK | Android 24+. Target: **API 36 (Android 16)** — 31 Ağustos 2026 zorunluluğu. |

### Klasör yapısı

```
lib/
├── core/{theme,constants,utils,di,l10n}
├── features/game/
│   ├── domain/{entities,repositories,usecases}
│   ├── data/{models,datasources,repositories}
│   └── presentation/{providers,screens,widgets,painters}
└── main.dart
```

### ÇÖZÜLEBİLİRLİK İNVARİANTI (projenin kalbi — asla bozma)

Seviyeler **ters-üretim (reverse generation)** ile üretilir:
boş tahtaya başla; her adımda o anki tahtaya göre **kenara açık atışı olan**
bir (hücre, yön) seç ve oraya ok koy. Yerleştirme sırasının tersi = garanti çözüm.
Solver'a gerek yoktur.

**Neden çalışır:** Ok kaldırmak yolu yalnızca açar, asla kapatmaz (monotonluk).
Ok #i yerleştiğinde #1..#i-1'e karşı açık atışı vardı; tersten oynatınca
#i kaldırılırken #i+1..#N zaten gitmiştir → yol hâlâ açıktır.

Bu invariant `test/features/game/level_generator_property_test.dart` ile korunur:
1000 rastgele seed → üret → çözüm sırasını oyna → tahta tamamen temizlenmeli.
**Bu test kırmızıysa hiçbir şey merge edilmez.**

---

## 3. YÜRÜTME PLANI (fazlar ve GATE'ler)

Her fazı sırayla yürüt. Faz sonunda özet geç. **GATE** işaretli yerlerde DUR ve onay bekle.

### FAZ 0 — Altyapı
- `flutter create`, klasör yapısı, `analysis_options.yaml` (strict lint)
- `.cursor/rules/` dosyalarını oluştur (bkz. §5)
- `docs/`: `STATE.md`, `DECISIONS.md`, `BACKLOG.md`, `SPEC.md`
- GitHub repo (private) + `main` branch protection + PR şablonu + issue şablonu
- CI: `flutter analyze` + `flutter test` + **domain'de flutter importu var mı** kontrolü
- `.gitignore`: keystore, `.env`, `*.jks`, `key.properties`
- **GATE 0:** Repo linki + CI yeşil ekran görüntüsü → onay al.

### FAZ 1 — Çekirdek mekanik
- Domain: `Direction`, `Arrow`, `Board`, `rayEscapes`, `tryFire`
- Birim testler (edge case: kenar okları, tek ok, dolu tahta)
- `BoardPainter` (CustomPainter) + tap → grid koordinat çevrimi
- Kayma animasyonu + çarpışma feedback (shake + haptic)
- Riverpod `GameNotifier`
- **Çıktı:** elle kurulan bir tahta oynanabiliyor.

### FAZ 2 — Seviye üreteci
- Ters-üretim algoritması + zorluk parametreleri (grid > doluluk > merkez-yönelim)
- **Property test: 1000 seed, hepsi çözülebilir** ← en kritik test
- Zorluk kapısı: başlangıçta okların >%50'si açık atışa sahipse üret-ve-at
- Zorluk eğrisi: Kolay/Orta/Zor profilleri
- **GATE 1:** Çalışan APK + property test raporu → onay al.

### FAZ 3 — Oyun döngüsü ve UI
- Ana menü, seviye seçim, oyun ekranı, kazanma/kaybetme
- Can (kalp) sistemi, undo, ipucu
- İlerleme kaydı (Hive)
- Koyu tema + özgün palet + `flutter_animate` mikro-etkileşimler
- Ses (audioplayers) + ayarlar
- Lokalizasyon (TR/EN)

### FAZ 4 — Farklılaştırma ve içerik
- Özgün mekanik(ler) — DECISIONS.md'ye gerekçesiyle yaz
- Günlük görev / seri (streak)
- 100+ seviye (üretilmiş + curated seed listesi)
- **GATE 2 (LEGAL):** §6 kontrol listesi → onay al.

### FAZ 5 — Monetizasyon
- AdMob: interstitial (n seviyede bir), rewarded (can/ipucu), banner opsiyonel
- IAP: reklamsız (tek seferlik), ipucu paketi
- **Test reklam ID'leri ile geliştir.** Gerçek ID'ler `--dart-define` ile gelir, commit edilmez.

### FAZ 6 — Yayına hazırlık
- Release build, ProGuard/R8, app signing (Play App Signing)
- İkon (`flutter_launcher_icons`), splash, ekran görüntüleri
- Store listing metinleri (TR/EN) + ASO anahtar kelimeler
- Data safety formu içeriği + IARC/PEGI anket cevapları → `docs/RELEASE.md`
- **GATE 3:** Yayın paketi hazır → onay al.

### FAZ 7 — Kapalı test ve yayın
- Kapalı test: **min 12 testçi, 14 gün kesintisiz** (Kasım 2023 sonrası kişisel hesaplar)
- Geri bildirim → düzeltme → prodüksiyon erişim başvurusu
- **Not:** Play Console adımları kullanıcının manuel yapacağı tek kısımdır.
  Sen `docs/RELEASE.md`'de tıkla-geç talimat listesi hazırla.

---

## 4. RAPORLAMA FORMATI

Her faz sonunda (ve yalnızca faz sonunda) bu formatta özet geç:

```
✅ FAZ N — <ad>
Yapılanlar : <3-5 madde>
Kararlar   : <varsa, DECISIONS.md referansı>
Test       : <X test geçti, coverage %Y>
PR         : <link>
Sıradaki   : <bir sonraki faz>
Aksiyon    : <kullanıcıdan bir şey gerekiyorsa; yoksa "yok, devam ediyorum">
```

Faz içinde sessiz çalış. İlerleme spam'i yapma.

---

## 5. OLUŞTURACAĞIN RULE DOSYALARI

Faz 0'da `.cursor/rules/` altına şunları yaz:

- `00-constitution.mdc` — `alwaysApply: true`. §2'nin özeti + altın kurallar.
- `10-domain.mdc` — `globs: lib/features/*/domain/**`. Saf Dart zorunluluğu, use-case başına test.
- `20-presentation.mdc` — `globs: lib/features/*/presentation/**`. CustomPainter, widget-per-cell yasağı, Riverpod pattern.
- `30-level-generator.mdc` — `globs: **/level*`. Ters-üretim invariantı, property test zorunluluğu.
- `40-tests.mdc` — `globs: test/**`. Test isimlendirme, AAA pattern, property test şablonu.

Her rule dosyası **kısa** olsun (≤40 satır) — uzun rule = yok sayılan rule.

---

## 6. LEGAL GATE (Faz 4 sonunda doğrula)

Kod yazmadan önce oku, Faz 4'te tek tek doğrula:

- [ ] Uygulama adı özgün; "Arrows", "Arrow Escape", "Puzzle Escape" ibarelerini içermiyor
- [ ] İkon tamamen özgün (referansın görsel diline benzemiyor)
- [ ] Renk paleti ve art stili özgün
- [ ] Store açıklaması sıfırdan yazıldı (kopya değil)
- [ ] Geliştirici adı hiçbir markayı çağrıştırmıyor
- [ ] En az 1 özgün mekanik mevcut
- [ ] Ekran görüntüleri/video tamamen kendi build'imizden
- [ ] Hiçbir asset üçüncü taraftan lisanssız alınmadı (ses/font dahil, lisanslar `docs/LICENSES.md`)

**İlke:** Oyun mekaniği telif korumasına tabi değildir; isim, ikon, art ve
trade dress korunur. Google Play "Impersonation" politikası ihlali = kaldırma.

---

## 7. ŞİMDİ BAŞLA

1. Bu dosyayı `docs/BOOTSTRAP.md` olarak repoya kaydet.
2. `docs/STATE.md`'yi oluştur: `Faz: 0 | Durum: başlıyor | Son commit: -`
3. FAZ 0'ı yürüt.
4. GATE 0'da dur, §4 formatında özet geç.

Sorma. Başla.
