# RELEASE — Yayına hazırlık (GATE 3)

Uygulama: **ShiftGrid** · Paket: `com.aktasilyas.shiftgrid` · Sürüm: `1.0.0+1`

## 1. Build

Kod imzasız (CI/dev) release derlemesi zaten çalışıyor. Yayın için:

```bash
# App Bundle (Play Store için önerilen), gerçek reklam ID'leriyle:
flutter build appbundle --release \
  --dart-define=ADMOB_BANNER=ca-app-pub-XXX/XXX \
  --dart-define=ADMOB_INTERSTITIAL=ca-app-pub-XXX/XXX \
  --dart-define=ADMOB_REWARDED=ca-app-pub-XXX/XXX
```

- **R8/kaynak küçültme** release'te açık (`isMinifyEnabled`, `isShrinkResources`) +
  `android/app/proguard-rules.pro`.
- **İkon** `flutter_launcher_icons` (adaptive, `assets/app_icon.png`, özgün).
- **Splash** `flutter_native_splash` (arka plan `#14161C`).

## 2. İmzalama (Play App Signing)
1. Upload keystore oluştur:
   `keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
2. `android/key.properties` oluştur (bkz. `android/key.properties.example`). Bu dosya **git-ignored**.
3. `flutter build appbundle --release` artık upload anahtarıyla imzalar.
4. Play Console → App integrity → **Play App Signing** etkin (Google dağıtım anahtarını yönetir).

## 3. Yayın öncesi ZORUNLU (BACKLOG)
- [ ] Gerçek AdMob birim ID'leri (`--dart-define`) + manifest `APPLICATION_ID`'yi gerçek app id ile değiştir.
- [ ] Play Console'da `remove_ads` non-consumable ürününü tanımla.
- [ ] `docs/PRIVACY.md`'yi herkese açık bir URL'de yayınla ve listelemede bağla.
- [ ] UMP / rıza formu (AB kullanıcıları için).
- [ ] Ekran görüntüleri (aşağıda §6) — kendi build'imizden.

## 4. Store listing metinleri

### English
- **Title (≤30):** ShiftGrid
- **Short description (≤80):** Release the snakes — clear the grid in this logic puzzle.
- **Full description:**
  > ShiftGrid is a clean, minimalist logic puzzle. Every level is a tangle of snakes —
  > tap one to let it glide out, but only if its path is clear. Plan your order, chain
  > escapes to build a combo and win back lives, and clear the whole board.
  >
  > • 120 handcrafted-by-seed levels across Easy, Medium and Hard
  > • A fresh Daily Challenge with a day-streak to keep
  > • Chain-combo mechanic: consecutive escapes refund lives
  > • Undo and a smart hint that never leads to a dead end
  > • Distraction-free dark theme, Turkish & English
  >
  > No timers, no clutter — just you and the grid.

### Türkçe
- **Başlık (≤30):** ShiftGrid
- **Kısa açıklama (≤80):** Yılanları serbest bırak, ızgarayı temizle — mantık bulmacası.
- **Tam açıklama:**
  > ShiftGrid sade, minimalist bir mantık bulmacasıdır. Her bölüm iç içe yılanlarla doludur —
  > yolu açıksa dokunup süzülerek çıksın. Sıranı planla, ardışık çıkışlarla kombo yap ve
  > can kazan, tüm tahtayı temizle.
  >
  > • Kolay/Orta/Zor'da 120 bölüm
  > • Her gün yeni Günlük Görev + gün-serisi
  > • Zincir-kombo: ardışık çıkışlar can iade eder
  > • Geri al ve asla çıkmaza sokmayan akıllı ipucu
  > • Dikkat dağıtmayan koyu tema, Türkçe & İngilizce
  >
  > Sayaç yok, karmaşa yok — sadece sen ve ızgara.

## 5. ASO anahtar kelimeler
- **EN:** puzzle, logic puzzle, brain, snake, grid, minimalist, offline, daily puzzle, casual
- **TR:** bulmaca, mantık, zeka oyunu, yılan, ızgara, minimalist, çevrimdışı, günlük bulmaca

## 6. Ekran görüntüleri (DURUM: bekliyor — cihaz/emülatör gerekir)
Kendi build'imizden (Legal §7). Emülatör/cihazda:
```bash
flutter run --release
# Menü, seviye seçim, oyun, kombo, kazanma ekranı, günlük görev, ayarlar kareleri
```
Play: telefon için en az 2 (min 320px), 16:9 veya 9:16. Öneri: 1080×1920.

## 7. Data safety formu (Play Console cevapları)
- **Konum/kişisel bilgi/rehber:** Hayır.
- **Cihaz/diğer kimlikler (Advertising ID):** Toplanıyor **ve** paylaşılıyor → amaç: **Reklamlar** (Google AdMob).
- **Uygulama etkinliği (etkileşim):** AdMob ölçümü için toplanabilir.
- **Satın alma geçmişi:** Play Faturalandırma (Reklamları kaldır).
- **Veriler aktarımda şifreli:** Evet (Google SDK'ları HTTPS).
- **Kullanıcı silme talebi:** Yerel veriler cihazda; uygulama depolamasını temizleyerek silinir.
- **Çocuklara yönelik mi:** Hayır (Herkes, ancak çocuklar hedeflenmiyor).

## 8. İçerik derecelendirme (IARC anketi)
- Şiddet/korku/cinsellik/küfür/uyuşturucu: **Yok**.
- Kumar (gerçek/simüle): **Yok** (rewarded reklam kumar değildir).
- Dijital satın alma: **Evet** (Reklamları kaldır).
- Reklam içeriyor: **Evet** (Play'de "Reklam içerir" rozeti).
- Beklenen: **PEGI 3 / Everyone**.

## 9. Play Console tıkla-geç adımları (kullanıcı yapar)
1. Play Console → **Create app** (ad: ShiftGrid, kategori: Oyun > Bulmaca, ücretsiz).
2. **App integrity → Play App Signing** etkinleştir.
3. **Store listing:** §4 metinleri, ikon (512×512), feature graphic (1024×500), §6 ekran görüntüleri.
4. **Privacy policy URL** (§3) gir.
5. **Data safety** (§7) ve **Content rating** (§8) anketlerini doldur.
6. **Ads:** "Contains ads" = Evet.
7. **In-app products:** `remove_ads` (non-consumable) oluştur.
8. **Closed testing** track: AAB yükle, min 12 testçi / 14 gün (bkz. FAZ 7).
9. Geri bildirim → düzeltme → **production** erişim başvurusu.

> Not: Play Console adımları kullanıcının manuel yapacağı tek kısımdır.

## 10. Kapalı test (FAZ 7 — tıkla-geç)

Kasım 2023 sonrası açılan **kişisel** geliştirici hesapları için prodüksiyona
geçmeden önce zorunlu: **en az 12 testçi, 14 gün kesintisiz** kapalı test.

1. **AAB hazırla:** `flutter build appbundle --release` (gerçek ID'lerle, §1).
2. Play Console → **Testing → Closed testing → Create track** (örn. "alpha").
3. **Testers:** bir e-posta listesi oluştur, ≥12 gerçek Google hesabı ekle
   (test edenlerin katılım bağlantısını kabul etmesi gerekir).
4. **Create release** → AAB yükle → sürüm notları (CHANGELOG'dan) → **Review → Rollout**.
5. Testçilere **opt-in URL**'yi paylaş; kurup en az 14 gün aktif kullanmalarını iste.
6. **14 gün boyunca kesintisiz** en az 12 testçi kalsın (düşerse sayaç sıfırlanabilir).
7. **Geri bildirim** topla (Play Console → Feedback + doğrudan). Hataları düzelt →
   versiyonu artır (`pubspec.yaml` `version: 1.0.0+2` ...) → yeni AAB yükle.
8. 14 gün + ≥12 testçi tamamlanınca **Production access** başvurusunu doldur.
9. Onaylanınca **Production** track'e release oluştur → aşamalı yayın (staged rollout).

### Sürümleme
- `pubspec.yaml` → `version: <marketing>+<build>` (ör. `1.0.1+3`).
- Her yüklemede **build numarası artmalı**. Değişiklikleri `CHANGELOG.md`'ye işle.

### Yayın öncesi son kontrol (tekrarlı)
- [ ] Gerçek AdMob ID'leri (`--dart-define`) + manifest app id
- [ ] `remove_ads` ürünü aktif, satın alma/geri yükleme test edildi
- [ ] Privacy policy URL yayında ve listelemede
- [ ] Data safety + içerik derecelendirme + "Reklam içerir" işaretli
- [ ] Ekran görüntüleri kendi build'imizden yüklendi
- [ ] `flutter analyze` temiz, tüm testler yeşil, CI release build yeşil
