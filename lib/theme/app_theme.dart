import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Dark Mode
  static const Color bgDark = Color(0xFF0A0A12);
  static const Color surfaceDark = Color(0xFF12121E);
  static const Color cardDark = Color(0x0FFFFFFF);
  static const Color borderDark = Color(0x1AFFFFFF);

  // Light Mode
  static const Color bgLight = Color(0xFFF0F4FF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0x99FFFFFF);
  static const Color borderLight = Color(0xCCFFFFFF);

  // Accents
  static const Color mint = Color(0xFF00E5B0);
  static const Color purple = Color(0xFF7C5CFC);
  static const Color orangeRed = Color(0xFFFF4E1F);
  static const Color purpleOrb = Color(0xFF6B21A8);
  static const Color orangeOrb = Color(0xFFEA580C);

  // Text
  static const Color textLight = Color(0xFFF0F0FF);
  static const Color textDark = Color(0xFF0D0D1A);
  static const Color mutedDark = Color(0xFF6B7299);
  static const Color mutedLight = Color(0xFF8891AA);
}

class AppTheme {
  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.mint,
        secondary: AppColors.purple,
        surface: AppColors.surfaceDark,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData.dark().textTheme,
      ).apply(bodyColor: AppColors.textLight, displayColor: AppColors.textLight),
      useMaterial3: true,
    );
  }

  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.mint,
        secondary: AppColors.purple,
        surface: AppColors.surfaceLight,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData.light().textTheme,
      ).apply(bodyColor: AppColors.textDark, displayColor: AppColors.textDark),
      useMaterial3: true,
    );
  }
}
