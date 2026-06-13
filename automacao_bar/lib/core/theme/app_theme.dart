import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class AppTheme {
  static ThemeData get darkNeonTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.surface,
      dividerColor: AppColors.surfaceLight,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.neonGreen,
        secondary: AppColors.neonGreen,
        surface: AppColors.surface,
        error: AppColors.danger,
        onPrimary: Colors.black,
        onSurface: AppColors.textMain,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.neonGreen),
        titleTextStyle: TextStyle(
          color: AppColors.textMain,
          fontSize: 20,
          fontWeight: FontWeight.w700, // Strict bold for headers
          letterSpacing: -0.5,
        ),
      ),
      textTheme: const TextTheme(
        // Body Text
        bodyLarge: TextStyle(
          color: AppColors.textMain,
          fontSize: 16,
          fontWeight: FontWeight.w400, // w400 regular
        ),
        bodyMedium: TextStyle(
          color: AppColors.textMuted,  // Secondary text strictly muted
          fontSize: 14,
          fontWeight: FontWeight.w400, // w400 regular
        ),
        bodySmall: TextStyle(
          color: AppColors.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        // Titles / Headers
        titleLarge: TextStyle(
          color: AppColors.textMain,
          fontSize: 22,
          fontWeight: FontWeight.w700, // w700 bold
          letterSpacing: -0.5,
        ),
        titleMedium: TextStyle(
          color: AppColors.textMain,
          fontSize: 16,
          fontWeight: FontWeight.w600, // w600 semi-bold
        ),
        titleSmall: TextStyle(
          color: AppColors.textMain,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.surfaceLight,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
