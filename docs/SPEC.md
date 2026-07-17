# SPEC — Ürün ve Teknik Şartname

## 1. Oyun tanımı
Grid tabanlı minimalist bulmaca. N×N ızgarada **çok hücreli yılanlar** bulunur. Oyuncu bir
yılana (gövdenin herhangi bir hücresine) dokunur; yılan başının işaret ettiği yönde süzülür.
Yolu tamamen açıksa tahtadan çıkar. Yolunda başka bir yılan varsa çarpar (tıslama) ve can
kaybedilir. Amaç: tüm yılanları temizlemek.

## 2. Çekirdek varlıklar (domain — saf Dart)
- `Direction` — up / down / left / right. Her yönün (dx, dy) birim vektörü.
- `Snake` — head-first `List<Position> body` + yön; `id` yalnızca animasyon kimliği.
- `Board` — N×N ızgara; occupancy çok hücreli (aynı yılan birden fazla hücrede). Immutable.
- `rayEscapes(board, snake)` — başın yönündeki ışın kenara kadar boşsa true (kendi gövde engel).
- `tryFire(board, position)` — o hücredeki yılanı serbest bırak: açıksa kaldır, değilse çarpışma.

## 3. Çözülebilirlik invariantı (projenin kalbi)
Seviyeler **ters-üretim** ile üretilir: boş tahtadan başla; her adımda o anki tahtaya göre
kenara açık atışı olan bir yılan (baş + değişken uzunluklu gövde) yerleştir.
Yerleştirme sırasının tersi = garanti çözüm. Yılan kaldırmak yolu yalnızca açar (monotonluk)
→ solver gerekmez. Korunma: `test/features/game/level_generator_property_test.dart`, 1000 seed.

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
| Min SDK | Android 24+, target/compile API 36 |

## 5. Zorluk profilleri (özet)
| | size | snakes | length | maxOpenRatio |
|---|---|---|---|---|
| Easy | 5 | 5 | 2–4 | 0.55 |
| Medium | 6 | 7 | 2–6 | 0.45 |
| Hard | 7 | 9 | 3–8 | 0.40 |

Bkz. `DifficultyProfile` ve DECISIONS #0014.
