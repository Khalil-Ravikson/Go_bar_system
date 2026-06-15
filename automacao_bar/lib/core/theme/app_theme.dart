import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract class AppTheme {
  static ThemeData get darkNeonTheme {
    final base = ThemeData.dark();

    // Roboto Mono for financial/numeric values, Inter for general UI
    final monoStyle = GoogleFonts.robotoMono();
    final interStyle = GoogleFonts.inter();

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.surface,
      dividerColor: AppColors.surfaceLight,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.neonGreen,
        secondary: AppColors.electricBlue,
        tertiary: AppColors.magentaCyber,
        surface: AppColors.surface,
        error: AppColors.neonRed,
        onPrimary: Colors.black,
        onSurface: AppColors.textMain,
      ),

      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        // Body
        bodyLarge:  interStyle.copyWith(color: AppColors.textMain, fontSize: 16),
        bodyMedium: interStyle.copyWith(color: AppColors.textSecondary, fontSize: 14),
        bodySmall:  interStyle.copyWith(color: AppColors.textMuted, fontSize: 12),
        // Titles
        titleLarge:  interStyle.copyWith(color: AppColors.textMain, fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        titleMedium: interStyle.copyWith(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.w600),
        titleSmall:  interStyle.copyWith(color: AppColors.textMain, fontSize: 14, fontWeight: FontWeight.w600),
        // Financial values (mono) — use displayLarge/Medium/Small
        displayLarge:  monoStyle.copyWith(color: AppColors.neonGreen, fontSize: 48, fontWeight: FontWeight.w700),
        displayMedium: monoStyle.copyWith(color: AppColors.neonGreen, fontSize: 32, fontWeight: FontWeight.w700),
        displaySmall:  monoStyle.copyWith(color: AppColors.neonGreen, fontSize: 24, fontWeight: FontWeight.w600),
        // Label styles
        labelLarge:  interStyle.copyWith(color: AppColors.textMain, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.8),
        labelMedium: interStyle.copyWith(color: AppColors.textSecondary, fontSize: 12, letterSpacing: 0.5),
        labelSmall:  interStyle.copyWith(color: AppColors.textMuted, fontSize: 11, letterSpacing: 0.4),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.neonGreen),
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.textMain,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        surfaceTintColor: Colors.transparent,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonGreen,
          foregroundColor: Colors.black,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: 0.8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.neonGreen,
          side: const BorderSide(color: AppColors.neonGreen, width: 1.5),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.neonGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.neonRed),
        ),
        labelStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
        hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.surfaceLight,
        thickness: 1,
        space: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface,
        contentTextStyle: GoogleFonts.inter(color: AppColors.textMain),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.surfaceLight),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.surfaceLight),
        ),
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.textMain,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: GoogleFonts.inter(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),
    );
  }
}

/// Helper extensions for quick access to mono font in financial displays
extension MonoText on TextStyle {
  TextStyle get mono => copyWith(fontFamily: GoogleFonts.robotoMono().fontFamily);
}
