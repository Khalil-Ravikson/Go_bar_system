import 'package:flutter/material.dart';

/// Cabeçalho padronizado de secção numa lista.
/// Exibe um [icon] colorido e um [title] na mesma linha.
class AppSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const AppSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}
