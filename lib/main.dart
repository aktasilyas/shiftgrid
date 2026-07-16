import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/di/providers.dart';
import 'core/l10n/app_localizations.dart';
import 'core/settings/settings_notifier.dart';
import 'core/theme/app_theme.dart';
import 'features/game/data/datasources/hive_progress_store.dart';
import 'features/game/presentation/screens/menu_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final progressBox = await Hive.openBox<int>(HiveProgressStore.boxName);
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        progressStoreProvider.overrideWithValue(HiveProgressStore(progressBox)),
      ],
      child: const ShiftGridApp(),
    ),
  );
}

class ShiftGridApp extends ConsumerWidget {
  const ShiftGridApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final locale = settings.languageCode == null
        ? null
        : Locale(settings.languageCode!);

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.dark,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const MenuScreen(),
    );
  }
}
