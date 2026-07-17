/// User-configurable settings, persisted via shared_preferences.
class SettingsState {
  const SettingsState({required this.soundEnabled, required this.languageCode});

  /// null means "follow the system locale".
  final String? languageCode;
  final bool soundEnabled;

  SettingsState copyWith({bool? soundEnabled, String? languageCode, bool clearLanguage = false}) =>
      SettingsState(
        soundEnabled: soundEnabled ?? this.soundEnabled,
        languageCode: clearLanguage ? null : (languageCode ?? this.languageCode),
      );
}
