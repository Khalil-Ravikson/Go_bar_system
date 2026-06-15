import 'package:flutter/material.dart';

abstract class AppColors {
  // ── Neo Dark Background Layers ────────────────────────────────────────────
  static const Color background    = Color(0xFF0A0A0F); // Neo Dark
  static const Color surface       = Color(0xFF12121A); // Cards/Grafite
  static const Color surfaceAlt    = Color(0xFF1A1A24); // Superfícies secundárias
  static const Color surfaceLight  = Color(0xFF252532); // Borders/Subtle
  static const Color navBackground = Color(0xFF0E0E16);

  // ── Neon Accent Palette ───────────────────────────────────────────────────
  static const Color neonGreen     = Color(0xFF00FF88); // Sucesso / Pagamento / Mesa Livre
  static const Color electricBlue  = Color(0xFF00D4FF); // Mesa Ocupada / Info
  static const Color magentaCyber  = Color(0xFFFF00CC); // Mesa Fechando / Ação/Edição
  static const Color neonRed       = Color(0xFFFF0055); // Alerta / Estoque Baixo

  // ── Semantic Aliases ──────────────────────────────────────────────────────
  static const Color primaryNeon   = neonGreen;
  static const Color tableFree     = neonGreen;
  static const Color tableOccupied = electricBlue;
  static const Color tableClosing  = magentaCyber;
  static const Color lowStock      = neonRed;

  // ── Legacy / Compat ───────────────────────────────────────────────────────
  static const Color teal          = Color(0xFF00C9A7);
  static const Color orange        = Color(0xFFFF8C42);
  static const Color warning       = Color(0xFFFFAA00);
  static const Color danger        = neonRed;
  static const Color error         = neonRed;
  static const Color success       = neonGreen;

  // ── Typography ────────────────────────────────────────────────────────────
  static const Color textMain      = Color(0xFFF0F0F5);
  static const Color textPrimary   = textMain;
  static const Color textSecondary = Color(0xFF8B8BA8);
  static const Color textMuted     = Color(0xFF5A5A72);

  // ── Borders & Dividers ────────────────────────────────────────────────────
  static const Color border        = Color(0xFF252532);
  static const Color borderSubtle  = Color(0x1400FF88); // neonGreen 8%
  static const Color borderActive  = Color(0x4D00FF88); // neonGreen 30%
  static const Color borderBlue    = Color(0x4D00D4FF); // electricBlue 30%
  static const Color borderMagenta = Color(0x4DFF00CC); // magentaCyber 30%
  static const Color borderRed     = Color(0x4DFF0055); // neonRed 30%
}
