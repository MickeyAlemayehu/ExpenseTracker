import 'package:flutter/material.dart';

/// App color tokens. The `Color`s here are seed values — actual ThemeData is
/// generated from these in [AppTheme].
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryDark = Color(0xFF8478F0);
  static const Color secondary = Color(0xFF00CFA8);

  // Semantic
  static const Color income = Color(0xFF00B894);
  static const Color expense = Color(0xFFE17055);
  static const Color warning = Color(0xFFF7B731);
  static const Color info = Color(0xFF0984E3);

  // Neutrals (light)
  static const Color backgroundLight = Color(0xFFF7F8FC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color onSurfaceLight = Color(0xFF1B1D2A);
  static const Color borderLight = Color(0xFFE5E7EF);
  static const Color mutedLight = Color(0xFF8A8FA3);

  // Neutrals (dark)
  static const Color backgroundDark = Color(0xFF0F1117);
  static const Color surfaceDark = Color(0xFF181B24);
  static const Color onSurfaceDark = Color(0xFFE9EAF1);
  static const Color borderDark = Color(0xFF252836);
  static const Color mutedDark = Color(0xFF8A8FA3);

  /// Palette used for category color swatches in pickers.
  static const List<Color> categorySwatches = [
    Color(0xFF6C5CE7),
    Color(0xFF00CFA8),
    Color(0xFFE17055),
    Color(0xFFF7B731),
    Color(0xFF0984E3),
    Color(0xFFEB3B5A),
    Color(0xFF20BF6B),
    Color(0xFF8854D0),
    Color(0xFFFD9644),
    Color(0xFF2BCBBA),
    Color(0xFF4B7BEC),
    Color(0xFFA55EEA),
  ];
}
