# DECISIONS — Karar Günlüğü (ADR-lite)

Her önemli karar burada gerekçesiyle kayıt altına alınır. Format: numara, tarih, karar, gerekçe.

---

## 0001 — Kod adı ve paket kimliği
**Tarih:** 2026-07-16
**Karar:** Proje kod adı **ShiftGrid**, uygulama paketi `com.aktasilyas.shiftgrid`.
**Gerekçe:** Legal Gate (§6) referans markadan ("Arrows", "Escape") uzak, özgün bir ad gerektiriyor.
"ShiftGrid" mekaniği (ızgarada kayma) tanımlar ve referans markayı çağrıştırmaz. Nihai pazarlama
adı FAZ 4'te Legal Gate kontrolünde kesinleştirilecek; kod adı stabil kalır.

## 0002 — Özgün görsel palet
**Tarih:** 2026-07-16
**Karar:** Koyu slate zemin (#14161C), sıcak amber birincil (#F2A65A), soğuk teal ikincil (#4FD1C5),
gül kırmızısı hata (#E06C75). `lib/core/theme/app_palette.dart`.
**Gerekçe:** Özgün görsel kimlik farklılaştırıcısı (§1). Referansın renk dilinden bağımsız,
koyu-tema öncelikli, yüksek kontrastlı erişilebilir palet.

## 0003 — Yalnızca Android platformu (v1)
**Tarih:** 2026-07-16
**Karar:** `flutter create --platforms android`. iOS/web/desktop üretilmedi.
**Gerekçe:** BOOTSTRAP "Android öncelikli". Kapsamı dar tutmak CI'yi ve bakım yükünü azaltır;
gerekirse sonradan `flutter create --platforms ios .` ile eklenebilir.

## 0004 — intl 0.20.2 sabitleme
**Tarih:** 2026-07-16
**Karar:** `intl: ^0.20.2`.
**Gerekçe:** `flutter_localizations` (SDK) intl'i 0.20.2'ye pinliyor; sürüm çözümü için zorunlu.

## 0005 — PR akışı ile GATE 0
**Tarih:** 2026-07-16
**Karar:** `main` yalnızca README/lisans/lisans ile başlatılır; tüm FAZ 0 iskelesi
`phase-0-bootstrap` branch'inden PR ile gelir. GATE 0 = repo linki + PR CI durumu.
**Gerekçe:** Altın kural #4 (main'e doğrudan push yok) ve #2 (her değişiklik test+PR ile).

## 0006 — Branch protection GitHub Pro gerektiriyor
**Tarih:** 2026-07-16
**Karar:** Private repo'da classic branch protection ve rulesets, ücretsiz planda 403 veriyor
("Upgrade to GitHub Pro or make this repository public"). Repo private kalacak (Legal Gate);
Pro yükseltmesi kullanıcının kararı. Bu arada `main` koruması **disiplin + CI** ile sağlanır:
tüm değişiklikler `phase-*`/`feat-*` branch'lerinden PR ile gelir, CI yeşil olmadan merge edilmez.
**Gerekçe:** Repo'yu public yapmak Legal Gate ilkesine aykırı; Pro yükseltmesi PO kararıdır.
**Aksiyon (BACKLOG):** Pro'ya geçilirse `docs/`'daki ruleset JSON ile koruma etkinleştirilecek.

## 0007 — Üreteç parametreleri ve açık-atış kapısı
**Tarih:** 2026-07-16
**Karar:** Zorluk profilleri: easy 4×4/6 ok, medium 5×5/10 ok, hard 6×6/15 ok.
Açık-atış kapısı `maxOpenRatio` (easy 0.65, medium 0.5, hard 0.45): bitmiş tahtada açık atışı olan
okların oranı bu eşiği aşarsa seed atılıp yeniden üretilir (maxAttempts=48; bulunamazsa en düşük
oranlı aday saklanır). Üreteç deterministik: `Random(seed)`.
**Gerekçe:** Daha az "bariz ilk hamle" → daha bulmaca-hissi. Determinizm test/edilebilirlik ve
curated seed listeleri (FAZ 4) için şart. Kapı çözülebilirliği etkilemez (invariant korunur).

## 0008 — APK'yı CI'da derle (yerelde JDK yok)
**Tarih:** 2026-07-16
**Karar:** Geliştirme makinesinde JDK/Android Studio yok (yalnızca Android SDK 36 var).
APK, GitHub Actions'ta (temurin JDK 17 + subosito flutter-action) `flutter build apk --release`
ile derlenip `shiftgrid-release-apk` artifact'ı olarak yüklenir.
**Gerekçe:** Kullanıcının sistemine JDK kurmadan tekrarlanabilir, indirilebilir APK üretmek.
Yerel derleme gerekirse portable JDK + `flutter config --jdk-dir` ile eklenebilir (BACKLOG).

## 0009 — Ses: SystemSound + haptik (lisanssız asset yok)
**Tarih:** 2026-07-16
**Karar:** `SoundController` platformun yerleşik `SystemSound` (click/alert) + `HapticFeedback`
kullanır; üçüncü taraf ses dosyası paketlenmez. `audioplayers` bağımlılığı ileride lisanslı/özgün
sfx için eklendi ama şu an kullanılmıyor.
**Gerekçe:** Legal Gate §6 — lisanssız asset yasak. Yerleşik sesler OS lisansı altında güvenli.
Lisanslı/özgün sfx BACKLOG'da.

## 0010 — İlerleme & kilit modeli
**Tarih:** 2026-07-16
**Karar:** İlerleme Hive `Box<int>` ('progress'), anahtar `"{difficulty}:{seed}"` → en iyi hamle.
Seviyeler zorluk başına sıralı açılır (seed n, n-1 tamamlanınca açılır). `ProgressRepository`
arayüzü domain'de; impl data'da, test için `ProgressStore` soyutlaması (Hive'sız InMemory).
**Gerekçe:** Basit, deterministik, test edilebilir; Hive detayını domain'den uzak tutar.

## 0011 — Özgün mekanik: zincir-kombo + günlük seri
**Tarih:** 2026-07-16
**Karar:** Farklılaştırıcı özgün mekanik olarak **zincir-kombo**: ardışık başarılı çıkışlar komboyu
artırır, çarpışma sıfırlar; her `comboRewardThreshold` (4) komboda, can eksikse **1 can iade edilir**.
Ek olarak **günlük görev + gün-serisi (streak)**: güne özel deterministik seed, ardışık günlerde
oynanınca seri artar. Çözülebilirlik invariantını etkilemez (yalnızca puan/can/motivasyon katmanı).
**Gerekçe:** BOOTSTRAP §1 "en az 1 özgün mekanik" + §4 "günlük görev/seri". Risk-ödül döngüsü
(komboyu koruma) oyuna özgün bir ritim katar; invariantı bozmadan eklenir ve teste bağlanır.
