// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ShiftGrid';

  @override
  String get play => 'Play';

  @override
  String get restart => 'Restart';

  @override
  String get movesLabel => 'Moves';

  @override
  String get youWon => 'Board cleared!';

  @override
  String get youLost => 'Out of lives';

  @override
  String get howToPlay => 'Tap an arrow to slide it out. Clear them all.';

  @override
  String get newLevel => 'New level';

  @override
  String get settings => 'Settings';

  @override
  String get soundLabel => 'Sound & haptics';

  @override
  String get languageLabel => 'Language';

  @override
  String get systemLanguage => 'System';

  @override
  String get chooseDifficulty => 'Choose a difficulty';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get undo => 'Undo';

  @override
  String get hint => 'Hint';

  @override
  String get nextLevel => 'Next';

  @override
  String get lockedLabel => 'Locked';

  @override
  String levelLabel(int number) {
    return 'Level $number';
  }

  @override
  String bestMovesLabel(int moves) {
    return 'Best: $moves';
  }

  @override
  String get dailyChallenge => 'Daily challenge';

  @override
  String streakLabel(int days) {
    return '$days day streak';
  }

  @override
  String comboLabel(int count) {
    return 'Combo x$count';
  }

  @override
  String get watchAdForLife => 'Watch ad for a life';

  @override
  String get removeAds => 'Remove ads';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get adsRemovedActive => 'Ads removed — thank you!';
}
