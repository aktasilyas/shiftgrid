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
}
