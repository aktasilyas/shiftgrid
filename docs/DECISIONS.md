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
