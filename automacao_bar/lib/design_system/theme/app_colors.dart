import 'package:flutter/material.dart';

abstract class AppColors {
  // ----------------------------------------------------
  // Backgrounds & Surfaces
  // ----------------------------------------------------
  static const Color background = Color(0xFF0D0F14);
  static const Color surface = Color(0xFF1A1D27);
  static const Color surfaceHighlight = Color(0xFF222637);
  static const Color navBackground = Color(0xFF141720);

  // ----------------------------------------------------
  // Accents (Neon System)
  // ----------------------------------------------------
  static const Color neonGreen = Color(0xFF39FF7A);
  static const Color primaryNeon = neonGreen;
  static const Color teal = Color(0xFF00C9A7);
  static const Color orange = Color(0xFFFF8C42);
  
  // Vermelho para alertas operacionais e erros
  static const Color red = Color(0xFFFF4757); 
  static const Color error = red; 
  static const Color danger = red; 
  static const Color success = neonGreen;

  // ----------------------------------------------------
  // Tipografia
  // ----------------------------------------------------
  static const Color textPrimary = Color(0xFFEEF0FF);
  static const Color textSecondary = Color(0xFF8B91B5);
  static const Color textMuted = Color(0xFF5A6080);

  // ----------------------------------------------------
  // Bordas
  // ----------------------------------------------------
  static const Color borderSubtle = Color.fromARGB(20, 57, 255, 122);
  static const Color borderActive = Color.fromARGB(76, 57, 255, 122);
  static const Color border = borderSubtle;
}