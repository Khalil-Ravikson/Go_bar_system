import 'package:flutter/material.dart';

abstract class AppColors {
  // SaaS Dark Mode Layers
  static const Color background = Color(0xFF0D0D0D); // Pure dark background
  static const Color surface = Color(0xFF1A1A1A);    // Card/Container surface
  static const Color surfaceLight = Color(0xFF2A2A2A); // Border and subtle surfaces
  static const Color navBackground = Color(0xFF141720);
  static const Color surfaceHighlight = Color(0xFF222637);

  // Accents & Brand Colors
  static const Color neonGreen = Color(0xFF00FF88);  // High contrast Neon Green
  static const Color primaryNeon = neonGreen;
  static const Color teal = Color(0xFF00C9A7);
  static const Color orange = Color(0xFFFF8C42);
  
  // Alert/Status
  static const Color danger = Color(0xFFFF4444);
  static const Color warning = Color(0xFFFFAA00);
  static const Color error = danger;
  static const Color success = neonGreen;

  // Typography
  static const Color textMain = Color(0xFFF0F0F0);
  static const Color textPrimary = textMain;
  static const Color textSecondary = Color(0xFF8B91B5);
  static const Color textMuted = Color(0xFF888888);

  // Borders & Dividers
  static const Color border = Color(0xFF2A2A2A);     // 1px standard border color
  static const Color borderSubtle = Color.fromARGB(20, 0, 255, 136);
  static const Color borderActive = Color.fromARGB(76, 0, 255, 136);
}

