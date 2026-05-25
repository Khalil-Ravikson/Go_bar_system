import 'package:automacao_bar/design_system/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'colors.dart';

class AppThemes {
  static ThemeData get darkNeonTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Inter',
      colorScheme: const ColorScheme.dark(
        primary: AppColors.neonGreen,
        secondary: AppColors.teal,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.red,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
      ),
      dividerColor: AppColors.borderSubtle,
    );
  }
}