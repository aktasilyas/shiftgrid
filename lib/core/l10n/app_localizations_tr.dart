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
}
