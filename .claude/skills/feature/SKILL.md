---
name: feature
description: Scaffolds a new feature or use-case in this project's Clean Architecture layers, test-first, wiring providers into core/di and localizing strings. Use when the user says "yeni özellik ekleyelim", "yeni ekran", "yeni use-case", "şu mekaniği ekle", "feature iskeleti kur" or describes a new piece of gameplay/UI to build.
argument-hint: [özellik adı]
---

# Feature — yeni özellik iskeleti

Katman sırası **dıştan içe değil, içten dışa**: domain → test → data → presentation.
Her adımda çalışan bir şey bırak; yarım katman bırakma.

## 0. Kapsamı netleştir

Özellik `game` feature'ının parçası mı, yoksa yeni bir feature mı? Yeni feature ise
`lib/features/<ad>/{domain,data,presentation}` üçlüsünü aç. Oyun kuralını değiştiren bir şeyse
`docs/DECISIONS.md`'ye ADR yaz (numara, karar, gerekçe, alternatifler).

## 1. Domain (saf Dart)

`lib/features/<feature>/domain/` altında:

- `entities/` — immutable veri. `final` alanlar, `copyWith`, elle yazılmış `==`/`hashCode`,
  koleksiyonlar `List.unmodifiable`.
- `usecases/` — yan etkisiz fonksiyon/küçük sınıf. Mutasyon yok, yeni nesne döndür.
- `repositories/` — yalnızca `abstract interface class`.

`package:flutter` importu yasak; CI grep'i build'i kırar.

## 2. Test (koddan hemen sonra, aynı adımda)

`test/features/<feature>/domain/<ad>_test.dart` — kaynak ağacını yansıt.
Davranışı cümleyle anlatan test adları, `expect(..., reason: ...)`, mock yok.
Rastgelelik varsa sabit seed. Oyun kuralına dokunduysan `flutter test` **tamamını** koş:
`level_generator_property_test.dart` çözülebilirlik invariantının bekçisidir.

## 3. Data (kalıcılık gerekiyorsa)

`data/repositories/<ad>_repository_impl.dart` domain arayüzünü uygular; depolama
`ProgressStore` (Hive) veya `SharedPreferences` üzerinden. Testte `InMemoryProgressStore` kullan.

## 4. DI

Provider **yalnızca** `lib/core/di/providers.dart` içinde:

```dart
final xRepositoryProvider = Provider<XRepository>(
  (ref) => XRepositoryImpl(ref.watch(progressStoreProvider)),
);
```

Async kaynak gerekiyorsa `UnimplementedError` fırlatan tohum provider + `main`'de
`ProviderScope(overrides: [...])`.

## 5. Presentation

- Durum: `presentation/providers/<ad>_state.dart` (immutable + `copyWith`) ve
  `<ad>_notifier.dart` (`Notifier<T>`, dosya sonunda `NotifierProvider`).
  freezed / `@riverpod` / build_runner **yok**.
- Notifier iş kuralı içermez; domain use-case'ini çağırır, sonucu duruma uygular.
- Ekran: `presentation/screens/`. Salt okunur ise `ConsumerWidget`, controller/`initState`
  gerekiyorsa `ConsumerStatefulWidget`. Yönlendirme düz `Navigator.push(MaterialPageRoute)`.
- **Riverpod 3 tuzağı:** `initState`/`build` içinde provider mutasyonu yasak →
  `WidgetsBinding.instance.addPostFrameCallback` ile ertele.
- Çizim gerekiyorsa mevcut `BoardPainter`'a ekle; yeni painter/hücre-widget'ı açma.

## 6. Lokalizasyon

Kullanıcıya görünen her metin `lib/core/l10n/app_en.arb` **ve** `app_tr.arb` içine, sonra
`flutter gen-l10n`. Üretilen dosyalar commit'lenir ama elle düzenlenmez.

## 7. Kapanış

`/ship-check` çalıştır. Yeşilse Conventional Commits ile commit'le
(`feat(<kapsam>): ...`), dal + PR ile ilerle. Görsel değişiklik varsa gerçek cihazda
`flutter run` ile doğrula — golden test yok, tek kanıt ekran görüntüsü.
