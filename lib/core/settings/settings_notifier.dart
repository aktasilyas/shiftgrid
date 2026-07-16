import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/providers.dart';
import 'settings_state.dart';

class SettingsNotifier extends Notifier<SettingsState> {
  static const _kSound = 'settings.sound';
  static const _kLanguage = 'settings.language';

  @override
  SettingsState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return SettingsState(
      soundEnabled: prefs.getBool(_kSound) ?? true,
      languageCode: prefs.getString(_kLanguage),
    );
  }

  Future<void> toggleSound() async {
    final next = !state.soundEnabled;
    state = state.copyWith(soundEnabled: next);
    await ref.read(sharedPreferencesProvider).setBool(_kSound, next);
  }

  /// [code] null follows the system locale.
  Future<void> setLanguage(String? code) async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (code == null) {
      state = state.copyWith(clearLanguage: true);
      await prefs.remove(_kLanguage);
    } else {
      state = state.copyWith(languageCode: code);
      await prefs.setString(_kLanguage, code);
    }
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
