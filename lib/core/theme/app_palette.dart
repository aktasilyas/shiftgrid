import 'package:flutter/material.dart';

/// Original visual identity for ShiftGrid.
///
/// This palette is intentionally distinct from any reference product
/// (see docs/DECISIONS.md #0002). Deep slate canvas, warm amber primary,
/// cool teal secondary.
abstract final class AppPalette {
  static const Color canvas = Color(0xFF14161C);
  static const Color surface = Color(0xFF1E212B);
  static const Color surfaceHigh = Color(0xFF2A2E3B);
  static const Color amber = Color(0xFFF2A65A);
  static const Color teal = Color(0xFF4FD1C5);
  static const Color rose = Color(0xFFE06C75);
  static const Color textPrimary = Color(0xFFECEFF4);
  static const Color textMuted = Color(0xFF9AA2B1);
}
