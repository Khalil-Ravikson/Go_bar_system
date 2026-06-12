import 'package:flutter/material.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';

class GoalProgressCard extends StatelessWidget {
  final double current;
  final double target;
  final String title;

  const GoalProgressCard({
    super.key,
    required this.current,
    required this.target,
    this.title = 'Meta Diária de Vendas',
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = (current / target).clamp(0.0, 1.0);
    final int percentInt = (percentage * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceLight),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.neonGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$percentInt%',
                  style: const TextStyle(
                    color: AppColors.neonGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'R\$ ${current.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: AppColors.textMain,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'de R\$ ${target.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 10,
              backgroundColor: AppColors.surfaceLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.neonGreen),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            percentage >= 1.0
                ? '🎉 Parabéns! Meta diária atingida!'
                : 'Faltam R\$ ${(target - current).toStringAsFixed(0)} para atingir a meta.',
            style: TextStyle(
              color: percentage >= 1.0 ? AppColors.neonGreen : AppColors.textMuted,
              fontSize: 12,
              fontStyle: percentage >= 1.0 ? FontStyle.normal : FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
