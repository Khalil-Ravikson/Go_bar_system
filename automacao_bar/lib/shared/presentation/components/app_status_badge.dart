import 'package:flutter/material.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';

/// Badge de status compacto para AppBars e cards.
/// Ex: "ABERTO", "PAGO", "EM PREPARO", "AGUARDANDO".
class AppStatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const AppStatusBadge({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

/// Variante de badge baseada num booleano — útil para estado aberto/pago.
class AppOpenClosedBadge extends StatelessWidget {
  final bool isOpen;
  final String openLabel;
  final String closedLabel;

  const AppOpenClosedBadge({
    super.key,
    required this.isOpen,
    this.openLabel = 'ABERTO',
    this.closedLabel = 'PAGO',
  });

  @override
  Widget build(BuildContext context) {
    return AppStatusBadge(
      label: isOpen ? openLabel : closedLabel,
      color: isOpen ? AppColors.neonGreen : Colors.blue,
    );
  }
}
