import 'package:flutter/material.dart';

abstract class AppColors {
  // SaaS Dark Mode Layers (Waiter & KDS locked to dark, Manager adaptive)
  static const Color backgroundDark = Color(0xFF0F172A); // Deep slate dark (#0F172A)
  static const Color surfaceDark = Color(0xFF1E293B); // Darker surface slate
  static const Color surfaceHighlightDark = Color(0xFF334155); // Elevated slate
  
  // Light Mode Layers
  static const Color backgroundLight = Color(0xFFF8FAFC); // Clean light background (#F8FAFC)
  static const Color surfaceLight = Color(0xFFFFFFFF); // Pure white cards
  static const Color surfaceHighlightLight = Color(0xFFF1F5F9); // Light elevated elements

  // Brand / Accents
  static const Color primary = Color(0xFFF59E0B); // Amber Accent (#F59E0B)
  static const Color primaryDark = Color(0xFFD97706);
  static const Color primaryLight = Color(0xFFFEF3C7);
  
  static const Color secondary = Color(0xFF3B82F6); // Blue for informational actions
  static const Color accent = Color(0xFFF59E0B); // Amber Accent

  // Semantic
  static const Color success = Color(0xFF10B981); // Emerald green for success
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Typography - Dark Mode
  static const Color textMainDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  // Typography - Light Mode
  static const Color textMainLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF94A3B8);

  // Borders
  static const Color borderDark = Color(0xFF334155);
  static const Color borderLight = Color(0xFFE2E8F0);
  
  // Glassmorphism overlays
  static const Color glassOverlayDark = Color(0x801E293B);
  static const Color glassOverlayLight = Color(0xCCFFFFFF);
}
