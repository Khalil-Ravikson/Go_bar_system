import 'package:flutter/material.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/features/dashboard/application/dashboard_provider.dart';

class DetailsSection extends StatelessWidget {
  final bool isDesktop;
  final DashboardState state;

  const DetailsSection({
    super.key,
    required this.isDesktop,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final topProductsPanel = _buildTopProductsCard(state.topProducts);
    final categorySalesPanel = _buildCategorySalesCard(state.categorySales);

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: topProductsPanel),
          const SizedBox(width: 24),
          Expanded(child: categorySalesPanel),
        ],
      );
    } else {
      return Column(
        children: [
          topProductsPanel,
          const SizedBox(height: 24),
          categorySalesPanel,
        ],
      );
    }
  }

  Widget _buildTopProductsCard(List<Map<String, dynamic>> products) {
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
          const Text(
            'Top 5 Produtos mais Vendidos',
            style: TextStyle(
              color: AppColors.textMain,
              fontSize: 16, // Adjusted from 18 to 16
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            separatorBuilder: (context, index) => const Divider(color: AppColors.surfaceLight, height: 24),
            itemBuilder: (context, index) {
              final prod = products[index];
              return Row(
                children: [
                  CircleAvatar(
                    radius: 16, // Adjusted from 14 to 16
                    backgroundColor: AppColors.surfaceLight,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: AppColors.neonGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prod['name'] as String,
                          style: const TextStyle(
                            color: AppColors.textMain,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8), // Adjusted from 2 to 8
                        Text(
                          '${prod['qty']} unidades',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'R\$ ${(prod['total'] as double).toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.textMain,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySalesCard(List<Map<String, dynamic>> categories) {
    // Calculate category grand total
    final double grandTotal = categories.fold(0.0, (sum, cat) => sum + (cat['total'] as double));

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
          const Text(
            'Vendas por Categoria',
            style: TextStyle(
              color: AppColors.textMain,
              fontSize: 16, // Adjusted from 18 to 16
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Column(
            children: categories.map((cat) {
              final name = cat['name'] as String;
              final total = cat['total'] as double;
              final color = Color(cat['color'] as int);
              final double pct = grandTotal > 0 ? total / grandTotal : 0.0;

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8, // Adjusted from 10 to 8
                            height: 8, // Adjusted from 10 to 8
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            name,
                            style: const TextStyle(
                              color: AppColors.textMain,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'R\$ ${total.toStringAsFixed(2)} (${(pct * 100).toStringAsFixed(1)}%)',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12, // Adjusted from 13 to 12
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4), // 4 is ok for small corners, could be 8
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 8, // Adjusted from 6 to 8
                      backgroundColor: AppColors.surfaceLight,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  const SizedBox(height: 24), // Adjusted from 20 to 24
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
