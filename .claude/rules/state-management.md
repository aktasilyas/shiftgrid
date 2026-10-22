---
paths:
  - "lib/features/*/presentation/providers/**/*.dart"
  - "lib/core/di/**/*.dart"
---

# Riverpod katmanı

- Riverpod **3.x**, provider'lar **elle** yazılır. `@riverpod` annotation, build_runner
  ve freezed bu projede yok — ekleme.
- Durum sınıfı `Notifier<T>` alt sınıfıdır; `NotifierProvider` dosyanın sonunda
  `final gameProvider = NotifierProvider<GameNotifier, GameState>(GameNotifier.new);`
  biçiminde tanımlanır.
- State sınıfı immutable'dır: `final` alanlar + `copyWith`. Presentation state'lerinde
  değer eşitliği (`==`/`hashCode`) **tanımlanmaz** — `GameState` ve `SettingsState` kimlik
  karşılaştırmasıyla çalışır, bu bilinçli. (Değer eşitliği kuralı domain varlıkları içindir.)
  Nullable alanı `null`'a çekmek gerekiyorsa `SettingsState.copyWith`'teki
  `clearLanguage: true` kalıbını kullan.
- Repository/servis provider'ları **yalnızca** `lib/core/di/providers.dart` içinde tanımlanır.
  Feature içinde yeni bir repository provider'ı açma; oraya ekle. Tek istisna
  `soundControllerProvider` (kendi sınıfının yanında, `lib/core/audio/`) — bunu emsal alma.
- Async kaynaklar (SharedPreferences, Hive) `UnimplementedError` fırlatan tohum
  provider olarak tanımlanır ve `main`'de `ProviderScope(overrides: [...])` ile doldurulur.
- Notifier iş kuralı içermez: karar mantığı `domain/usecases` altındadır, notifier yalnızca
  sonucu duruma uygular (can, kombo, geçmiş, durum geçişi).
- **Riverpod 3 tuzağı:** widget yaşam döngüsü içinde (`initState`, `build`) provider
  mutasyonu yasaktır. Seviye yükleme gibi işleri
  `WidgetsBinding.instance.addPostFrameCallback` ile ertele.
- Yeni public metot eklediysen `test/features/game/presentation/game_notifier_test.dart`
  içine `ProviderContainer` tabanlı test ekle.
