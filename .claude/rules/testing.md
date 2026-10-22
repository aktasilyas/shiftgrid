---
paths:
  - "test/**/*.dart"
---

# Test katmanı

- Yalnızca `flutter_test`. Mockito/mocktail/build_runner yok — sahte yerine gerçek
  nesne veya elle yazılmış küçük stub kullan.
- Dosya yerleşimi kaynak ağacını yansıtır: `lib/features/game/domain/x.dart` →
  `test/features/game/domain/x_test.dart`.
- Test adı davranışı cümleyle anlatır: `test('blocked shot costs a life without changing
  the board', ...)`. `it works`, `test1` gibi adlar kabul edilmez.
- Kurulum → eylem → doğrulama sırası korunur; her testte tek davranış doğrulanır.
  `expect`'e mümkünse `reason:` ekle, çünkü seed tabanlı hatalar tek satırdan anlaşılmaz.
- Provider testleri `ProviderContainer` + `addTearDown(container.dispose)` ile kurulur.
- **Property testi kutsaldır:** `level_generator_property_test.dart` üretecin
  çözülebilirlik invariantını korur. Test yavaş diye seed sayısını düşürme; yalnızca
  tahta boyutu gerçekten büyüdüyse (ör. çok zor profili) örneklemi azalt ve gerekçesini
  dosyaya yorum olarak yaz.
- Yeni bir zorluk profili veya use-case eklediysen property/unit testini aynı PR'da ekle.
- Testler deterministik olmalı: rastgelelik kullanan her yerde sabit seed ver.
  `DateTime.now()` yerine parametreyle gün indeksi geçir.
- Görsel doğrulama için geçici PNG üreten testler yazılabilir, ama commit edilmez —
  iş bitince dosyayı sil.
