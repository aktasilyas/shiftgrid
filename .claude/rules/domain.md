---
paths:
  - "lib/features/*/domain/**/*.dart"
---

# Domain katmanı

- **Saf Dart.** `package:flutter`, `package:flutter_riverpod`, Hive, SharedPreferences
  veya herhangi bir I/O importu yasaktır. CI bu katmanda `package:flutter` grep'i yapar;
  ihlal build'i kırar. `dart:math` ve `dart:async` serbesttir.
- Varlıklar (`entities/`) immutable'dır: `final` alanlar, `copyWith`, elle yazılmış
  `==`/`hashCode`. `Board`, listeleri `List.unmodifiable` ile sarar — bu korumayı kaldırma.
- Repository'ler burada yalnızca **arayüz** olarak yaşar (`abstract interface class`).
  Uygulama `data/repositories/` altındadır; domain implementasyonu bilmez.
- Use-case'ler serbest fonksiyon veya küçük sınıftır, yan etkisizdir: aynı girdi → aynı
  çıktı. Mutasyon yerine yeni nesne döndür.
- Kural değişikliği doğrudan oynanışı etkiler: `tryFire`, `rayEscapes`, `Board` veya
  `LevelGenerator` dokunuşu sonrası `flutter test` **tam** koşulmalıdır; property testi
  bu katmanın sözleşmesidir.
- Üreteçte ters-üretim invariantını koru: yerleştirme sırasının tersi garanti çözümdür.
  Yerleştirmeyi "sonradan düzelten" bir adım eklersen invariant kırılır.
- Her yeni use-case aynı PR'da birim testiyle gelir (`test/features/*/domain/`).
