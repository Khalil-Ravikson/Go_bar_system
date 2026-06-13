import 'package:flutter/material.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/features/dashboard/application/dashboard_provider.dart';
import 'package:automacao_bar/features/dashboard/presentation/widgets/comparison_line_chart.dart';

class ChartSection extends StatelessWidget {
  final DashboardState state;

  const ChartSection({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Desempenho de Vendas',
                    style: TextStyle(
                      color: AppColors.textMain,
                      fontSize: 16, // Adjusted to fit better
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8), // Adjusted from 4 to 8
                  Text(
                    'Comparativo de faturamento de hoje com o dia anterior',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
              // Legend Indicators
              Row(
                children: [
                  _buildLegendDot(AppColors.textMuted.withValues(alpha: 0.5), 'Ontem'),
                  const SizedBox(width: 16),
                  _buildLegendDot(AppColors.neonGreen, 'Hoje'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          ComparisonLineChart(
            todaySpots: state.todaySalesPerHour,
            yesterdaySpots: state.yesterdaySalesPerHour,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8), // Adjusted from 6 to 8
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
