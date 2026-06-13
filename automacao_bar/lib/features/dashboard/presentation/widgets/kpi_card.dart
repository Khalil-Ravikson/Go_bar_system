import 'package:flutter/material.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';

class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final double variationPercent;
  final String comparisonText;
  final IconData icon;
  final bool isPrimary;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.variationPercent,
    this.comparisonText = 'vs ontem',
    required this.icon,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPositive = variationPercent >= 0;
    final Color trendColor = isPositive ? AppColors.neonGreen : AppColors.danger;
    final IconData trendIcon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPrimary ? AppColors.neonGreen.withValues(alpha: 0.3) : AppColors.surfaceLight,
          width: isPrimary ? 1.5 : 1.0,
        ),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: AppColors.neonGreen.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                )
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isPrimary
                      ? AppColors.neonGreen.withValues(alpha: 0.1)
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: isPrimary ? AppColors.neonGreen : AppColors.textMuted,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              value,
              key: ValueKey<String>(value),
              style: TextStyle(
                color: isPrimary ? AppColors.neonGreen : AppColors.textMain,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                trendIcon,
                color: trendColor,
                size: 14,
              ),
              const SizedBox(width: 4), // 4 is a sub-multiple, could be 8 but 4 is fine for icon spacing
              Text(
                '${isPositive ? "+" : ""}${variationPercent.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: trendColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                comparisonText,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
