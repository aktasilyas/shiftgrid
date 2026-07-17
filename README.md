# ShiftGrid

Grid tabanlı minimalist yılan bulmacası. N×N ızgarada kıvrımlı yılanlar; bir yılana dokun,
başı işaret ettiği yönde süzülsün. Yol açıksa tahtadan çıkar; başka bir yılana çarparsa
tıslar ve can kaybedersin. Amaç: tüm yılanları temizle.

> Android öncelikli. Flutter + Riverpod + CustomPainter. Klon değil, özgün türev.

## Teknoloji
- Flutter 3.41+ / Dart 3.11+
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
flutter analyze
flutter test
flutter run
```

## Dokümantasyon
- `docs/STATE.md` — kalıcı proje hafızası
- `docs/DECISIONS.md` — karar günlüğü
- `docs/SPEC.md` — şartname
- `docs/RELEASE.md` — yayın adımları
- `docs/BOOTSTRAP.md` — yürütme talimatı
