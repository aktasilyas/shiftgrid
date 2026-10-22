# Snake Shift

Flutter (Android öncelikli) ızgara bulmacası: tahtadaki çok hücreli yılanlardan birine
dokunursun, önü açıksa süzülüp tahtadan çıkar; önü kapalıysa çarpışır ve can gider.
Amaç tahtayı temizlemek.

## Komutlar

```bash
flutter pub get
flutter gen-l10n          # ARB değiştiyse ZORUNLU (üretilen dosyalar commit'lenir)
flutter analyze           # sıfır uyarı bekleniyor
flutter test              # 60 test; property testi dahil (~1 dk)
dart format lib test      # CI'da format adımı YOK, yerelde sen sağla
flutter run -d <device>   # `flutter devices` ile id al
flutter build appbundle --release   # yayın paketi (imza android/key.properties'ten)
```

Tek test dosyası: `flutter test test/features/game/domain/board_test.dart`

## Mimari

Clean Architecture, feature-first. Bağımlılık yönü tek taraflı: `presentation → domain ← data`.

```
lib/core/            ads, audio, di, l10n, monetization, settings, theme, utils
lib/features/game/
  domain/            entities, repositories (arayüz), usecases   ← saf Dart
  data/              datasources, models, repositories (impl)
  presentation/      painters, providers, screens, widgets
```

- **Domain saf Dart'tır.** `lib/features/*/domain` altında `package:flutter` importu
  yasaktır ve CI'da grep ile zorlanır (ihlal = kırmızı build).
- **State: Riverpod 3.x**, elle yazılan provider'lar. Kod üretimi (`@riverpod`,
  build_runner) ve freezed **kullanılmıyor** — mevcut stile uy.
- **DI tek yerden:** tüm repository/servis provider'ları `lib/core/di/providers.dart`.
  Global singleton yok. `sharedPreferencesProvider` ve `progressStoreProvider`
  `main`'de `overrides` ile doldurulur.
- **Render: saf `CustomPainter`.** Flame yok. Hücre başına widget yok — tüm tahta tek
  painter'da çizilir.
- **Kalıcılık:** ayarlar `shared_preferences`, ilerleme Hive (`ProgressStore`).
- **Lokalizasyon:** TR + EN, ARB tabanlı. Kullanıcıya görünen hiçbir metin kodda sabit yazılmaz.

## Çözülebilirlik invariantı (projenin kalbi)

Seviyeler **ters üretimle** (reverse generation) üretilir: boş tahtaya başla, her adımda
o anki tahtaya göre kenara açık kaçış ışını olan bir yılan yerleştir. Yerleştirme sırasının
tersi garanti çözümdür; solver yoktur.

Neden çalışır: yılan kaldırmak yolu yalnızca açar, asla kapatmaz (monotonluk).

Bu invariant `test/features/game/level_generator_property_test.dart` ile korunur (zorluk
başına seed taraması). **Bu test kırmızıysa hiçbir şey merge edilmez.** Üreteci veya
`Board`/`tryFire`/`rayEscapes` davranışını değiştiriyorsan bu testi mutlaka çalıştır.

## Zorluk merdiveni

Zorluğu oyuncu seçmez, oyun belirler. `lib/features/game/domain/usecases/level_progression.dart`
tek doğruluk kaynağıdır: 1–5 kolay, sonrası sabit ve deterministik bir desenle
orta/zor/çok zor karışık, toplam 120 bölüm. Bir seviyenin üreteç tohumu, kendi zorluğu
içindeki sırasından türetilir — bu yüzden deseni değiştirmek eski ilerleme kayıtlarını
kaydırır; değiştirirken bunu bilerek yap.

## Kod stili

- `analysis_options.yaml` katıdır: `strict-casts`, `strict-inference`, `strict-raw-types`,
  `require_trailing_commas`, `prefer_final_locals`, `avoid_print`, `unawaited_futures`.
- Yorumlar **niyeti/kısıtı** anlatır, kodu tekrar etmez. Çevredeki yorum yoğunluğuna uy.
- Kullanıcıya görünen metinler ve doküman dili **Türkçe**; kod, sınıf adları, kod yorumları
  ve commit mesajları **İngilizce**.
- Commit mesajları Conventional Commits: `feat(levels): ...`, `fix(render): ...`, `chore: ...`.

## Asla

- **Asla** `main`'e doğrudan push yapma. Değişiklik dal + PR ile gelir.
- **Asla** sır commit'leme: `*.jks`, `key.properties`, `.env`, `google-services.json`,
  gerçek AdMob/IAP kimlikleri. Gerçek reklam kimlikleri `--dart-define` ile geçilir.
- **Asla** domain katmanına `package:flutter` importu ekleme.
- **Asla** hücre başına widget veya Flame ekleme.
- **Asla** kullanıcıya görünen metni koda sabitleme — ARB'ye ekle, `gen-l10n` çalıştır.
- **Asla** başarısız/atlanmış testle "tamamlandı" deme. Testi geçmeyen iş bitmemiştir.
- **Asla** üretilen dosyaları (`lib/core/l10n/app_localizations*.dart`) elle düzenleme.
- **Asla** paket kimliğini (`com.aktasilyas.snakeshift`) değiştirme — Play'de kilitli.

## Referans dokümanlar

Kalıcı olmayan, konuya özel bilgi bu dosyada değil `docs/` altındadır:
`docs/DECISIONS.md` (ADR günlüğü — mimari karar verdiysen buraya yaz),
`docs/STATE.md` (proje durumu), `docs/RELEASE.md` (yayın adımları ve store metinleri),
`docs/SPEC.md`, `docs/BACKLOG.md`, `docs/LEGAL.md`, `docs/LICENSES.md`.
`docs/BOOTSTRAP.md` projenin ilk kurulum brifingidir ve `docs/archive/` tamamlanmış
görev listelerini tutar; ikisi de tarihsel bağlam içindir, güncel kural kaynağı
**bu dosyadır**. Dosya tipine özel kurallar `.claude/rules/` altındadır ve ilgili
dosyaya dokunduğunda kendiliğinden yüklenir.
