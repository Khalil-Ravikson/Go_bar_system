import 'package:automacao_bar/presentation/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/theme/app_colors.dart';


void main() {
  runApp(const ProviderScope(child: BarAutomationApp()));
}

class BarAutomationApp extends StatelessWidget {
  const BarAutomationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDV Bar & Restaurante',
      debugShowCheckedModeBanner: false,
      theme: _buildDarkTheme(),
      home: const DashboardScreen(), // <-- Aponta direto para o nosso Orquestrador!
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.surface,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryNeon,
        secondary: AppColors.primaryOrange,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
    );
  }
}