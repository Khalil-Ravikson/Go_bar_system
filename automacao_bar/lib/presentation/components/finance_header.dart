import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class FinanceHeader extends StatelessWidget {
  const FinanceHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetric("Faturamento", "RS 1.240,00"),
          _buildMetric("Pedidos", "34"),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: AppColors.primaryNeon, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }
}