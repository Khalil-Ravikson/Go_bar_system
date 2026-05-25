import 'package:flutter/material.dart';

class AppColors {
  // Fundo principal (Dark profundo, quase um cinza chumbo/azulado)
  static const Color background = Color(0xFF0F1115);
  
  // Superfícies de Cards (Ligeiramente mais claro que o fundo para criar profundidade)
  static const Color surface = Color(0xFF1A1D24);
  
  // O "Verde Neon" Premium (Usado para botões primários, valores em dinheiro e destaques)
  static const Color primaryNeon = Color(0xFF00E676); 
  
  // Verde secundário/Mint (Para detalhes menos chamativos e fundos translúcidos)
  static const Color secondaryMint = Color(0xFF00BFA5);
  
  // Cores de status operacionais
  static const Color success = Color(0xFF00C853);
  static const Color warning = Color(0xFFFFAB00);
  static const Color error = Color(0xFFFF3D00);
  
  // Textos
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF8F95A0);
  
  // Bordas e divisores (Glassmorphism sutil)
  static const Color border = Color(0xFF2A2D35);
}