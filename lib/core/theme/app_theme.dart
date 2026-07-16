import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Dark-first theme built on the original [AppPalette].
abstract final class AppTheme {
  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppPalette.amber,
      brightness: Brightness.dark,
      surface: AppPalette.surface,
      primary: AppPalette.amber,
      secondary: AppPalette.teal,
      error: AppPalette.rose,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppPalette.canvas,
      textTheme: const TextTheme().apply(
        bodyColor: AppPalette.textPrimary,
        displayColor: AppPalette.textPrimary,
      ),
    );
  }
}
