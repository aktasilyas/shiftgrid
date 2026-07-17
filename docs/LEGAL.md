# LEGAL — Gate 2 Kontrol Listesi (BOOTSTRAP §6)

Durum: FAZ 4 sonu. İlke = oyun mekaniği telif korumasına tabi değil; **isim, ikon, art, trade dress**
korunur. Aşağıdaki maddeler mevcut duruma göre işaretlenmiştir.

| # | Madde | Durum | Not |
|---|---|---|---|
| 1 | Uygulama adı özgün; "Arrows/Arrow Escape/Puzzle Escape" içermiyor | ✅ | "ShiftGrid" (DECISIONS #0001) |
| 2 | İkon tamamen özgün | ✅ | Özgün ikon üretildi (`assets/app_icon.png`, `flutter_launcher_icons`); LICENSES.md |
| 3 | Renk paleti ve art stili özgün | ✅ | `AppPalette` (DECISIONS #0002); art = özgün geometrik CustomPainter |
| 4 | Store açıklaması sıfırdan yazıldı | ✅ | `docs/RELEASE.md` §4 (TR/EN, özgün metin) |
| 5 | Geliştirici adı hiçbir markayı çağrıştırmıyor | ✅ | `com.aktasilyas.shiftgrid` |
| 6 | En az 1 özgün mekanik | ✅ | Zincir-kombo (can iadesi) + günlük görev/seri (DECISIONS #0011) |
| 7 | Ekran görüntüleri/video kendi build'imizden | ⏳ | Cihaz/emülatör gerekli; RELEASE.md §6 talimatı (kendi build'imizden) |
| 8 | Hiçbir asset lisanssız alınmadı | ✅ | Üçüncü taraf ses/font/görsel yok; yalnızca SystemSound + haptik (DECISIONS #0009). `docs/LICENSES.md` boş |

## Özet
- **FAZ 6 sonrası:** 1–6 ve 8 ✅. Yalnızca **7 (ekran görüntüleri)** cihaz/emülatör gerektirdiği
  için beklemede — RELEASE.md §6'da kendi build'imizden alma talimatı var; taklit/placeholder yok.
- GATE 2 (LEGAL) FAZ 4'te onaylandı; FAZ 6 ikon/store metniyle 2 ve 4 de tamamlandı.
