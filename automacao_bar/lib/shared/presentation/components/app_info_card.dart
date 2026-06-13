import 'package:flutter/material.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';

/// Card genérico com padding fixo de 16px, fundo [AppColors.surface]
/// e borda colorida configurável.
///
/// Use para qualquer caixa de informação destacada —
/// total pago, alertas, sumários de valor.
class AppInfoCard extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const AppInfoCard({
    super.key,
    required this.child,
    required this.borderColor,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: child,
    );
  }
}
