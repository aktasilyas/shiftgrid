# ShiftGrid

Grid tabanlı minimalist ok bulmacası. N×N ızgarada oklar; bir oka dokun, işaret ettiği yönde
kaysın. Yol açıksa tahtadan çıkar; başka bir oka çarparsa can kaybedersin. Amaç: tüm okları temizle.

> Android öncelikli. Flutter + Riverpod + CustomPainter. Klon değil, özgün türev.

## Teknoloji
- Flutter 3.38.5 / Dart 3.10.4
- Riverpod (state), Hive + shared_preferences (kalıcılık)
- flutter_localizations + ARB (TR/EN)
- Clean Architecture (feature-first), saf Dart domain

## Klasör yapısı
```
lib/
├── core/{theme,constants,utils,di,l10n}
├── features/game/{domain,data,presentation}
└── main.dart
```

## Geliştirme
```bash
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter run
```

## Dokümanlar
- `docs/SPEC.md` — ürün/teknik şartname
- `docs/STATE.md` — kalıcı durum
- `docs/DECISIONS.md` — karar günlüğü
- `docs/BACKLOG.md` — ertelenen işler
- `docs/BOOTSTRAP.md` — yürütme talimatı

## Lisans
Özel (private). Üçüncü taraf varlık lisansları: `docs/LICENSES.md`.
