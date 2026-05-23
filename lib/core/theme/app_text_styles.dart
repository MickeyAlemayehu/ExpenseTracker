import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized text style factory. We build TextTheme from these in [AppTheme].
class AppTextStyles {
  AppTextStyles._();

  static TextTheme textTheme(Brightness brightness) {
    final base = brightness == Brightness.light
        ? Typography.blackMountainView
        : Typography.whiteMountainView;
    return GoogleFonts.interTextTheme(base).copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400),
      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
    );
  }
}
