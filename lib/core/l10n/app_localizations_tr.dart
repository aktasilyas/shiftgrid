// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'ShiftGrid';

  @override
  String get play => 'Oyna';

  @override
  String get restart => 'Yeniden';

  @override
  String get movesLabel => 'Hamle';

  @override
  String get youWon => 'Tahta temizlendi!';

  @override
  String get youLost => 'Canın bitti';

  @override
  String get howToPlay => 'Bir oku dokunarak dışarı kaydır. Hepsini temizle.';

  @override
  String get newLevel => 'Yeni bölüm';

  @override
  String get settings => 'Ayarlar';

  @override
  String get soundLabel => 'Ses ve titreşim';

  @override
  String get languageLabel => 'Dil';

  @override
  String get systemLanguage => 'Sistem';

  @override
  String get chooseDifficulty => 'Zorluk seç';

  @override
  String get difficultyEasy => 'Kolay';

  @override
  String get difficultyMedium => 'Orta';

  @override
  String get difficultyHard => 'Zor';

  @override
  String get undo => 'Geri al';

  @override
  String get hint => 'İpucu';

  @override
  String get nextLevel => 'Sıradaki';

  @override
  String get lockedLabel => 'Kilitli';

  @override
  String levelLabel(int number) {
    return 'Bölüm $number';
  }

  @override
  String bestMovesLabel(int moves) {
    return 'En iyi: $moves';
  }

  @override
  String get dailyChallenge => 'Günlük görev';

  @override
  String streakLabel(int days) {
    return '$days günlük seri';
  }

  @override
  String comboLabel(int count) {
    return 'Kombo x$count';
  }

  @override
  String get watchAdForLife => 'Can için reklam izle';

  @override
  String get removeAds => 'Reklamları kaldır';

  @override
  String get restorePurchases => 'Satın alımları geri yükle';

  @override
  String get adsRemovedActive => 'Reklamlar kaldırıldı — teşekkürler!';
}
