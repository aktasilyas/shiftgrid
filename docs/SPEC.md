# SPEC — Ürün ve Teknik Şartname

## 1. Oyun tanımı
Grid tabanlı minimalist bulmaca. N×N ızgarada oklar bulunur. Oyuncu bir oka dokunur; ok
işaret ettiği yönde kayar. Yolu tamamen açıksa tahtadan çıkar (temizlenir). Yolunda başka
bir ok varsa çarpışır ve can kaybedilir. Amaç: tüm okları temizlemek.

## 2. Çekirdek varlıklar (domain — saf Dart)
- `Direction` — up / down / left / right. Her yönün (dx, dy) birim vektörü.
- `Arrow` — bir hücredeki ok: konum + yön (+ ileride tip: normal/özel).
- `Board` — N×N ızgara; hücrelerde ok veya boş. Değişmez (immutable) yapı hedeflenir.
- `rayEscapes(board, arrow)` — okun yönündeki ışın kenara kadar boşsa true.
- `tryFire(board, arrow)` — oku ateşle: açıksa kaldır (yeni board), değilse çarpışma sonucu döndür.

## 3. Çözülebilirlik invariantı (projenin kalbi)
Seviyeler **ters-üretim** ile üretilir: boş tahtadan başla; her adımda o anki tahtaya göre
kenara açık atışı olan bir (hücre, yön) seç ve ok koy. Yerleştirme sırasının tersi = garanti çözüm.
Ok kaldırmak yolu yalnızca açar (monotonluk) → solver gerekmez.
Korunma: `test/features/game/level_generator_property_test.dart`, 1000 seed.

## 4. Teknik anayasa (özet)
| Konu | Karar |
|---|---|
| Render | Saf Flutter + CustomPainter (Flame yok, hücre-başına-widget yok) |
| State | Riverpod (Notifier/AsyncNotifier), DI provider ile |
| Mimari | Clean Architecture, feature-first |
| Domain | Saf Dart — `package:flutter` importu yasak (CI kontrol eder) |
| Test | Use-case başına birim test; üreteç property test (1000 seed) |
| Kalıcılık | shared_preferences (ayar) + hive (ilerleme) |
| Lokalizasyon | flutter_localizations + ARB (hardcoded string yok) |
| SDK | minSdk 24, target/compile API 36 |

## 5. Farklılaştırıcılar (v1'de ≥2)
- Özgün görsel kimlik (palet + ad + ikon) — bkz. DECISIONS 0001, 0002.
- En az 1 özgün mekanik — FAZ 4 (BACKLOG).
- Tam TR/EN lokalizasyon.

## 6. Kapsam dışı (v1)
iOS/web/desktop, çok oyunculu, online skor tabloları.
