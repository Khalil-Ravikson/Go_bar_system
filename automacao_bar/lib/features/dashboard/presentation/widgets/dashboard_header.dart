import 'package:flutter/material.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/features/management/application/ingredients_provider.dart';

class DashboardHeader extends StatelessWidget {
  final List<Ingredient> lowStockIngredients;

  const DashboardHeader({
    super.key,
    required this.lowStockIngredients,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Visão Executiva',
              style: TextStyle(
                color: AppColors.textMain,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 8), // Modified from 4 to 8
            Text(
              'Painel de Business Intelligence • Tempo Real',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16), // Adjusted to 16
            onTap: () {
              if (lowStockIngredients.isNotEmpty) {
                _showLowStockBottomSheet(context, lowStockIngredients);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Estoque saudável! Nenhuma quebra crítica reportada.', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    backgroundColor: AppColors.neonGreen,
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8), // Modified from 10 to 8
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16), // Adjusted to 16
                border: Border.all(color: AppColors.surfaceLight),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_none, color: AppColors.neonGreen, size: 24),
                  if (lowStockIngredients.isNotEmpty)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16, // Modified from 18 to 16
                          minHeight: 16, // Modified from 18 to 16
                        ),
                        child: Text(
                          '${lowStockIngredients.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10, // Adjust from 9
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showLowStockBottomSheet(BuildContext context, List<Ingredient> items) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24), // Adjusted from 20 to 24
              topRight: Radius.circular(24), // Adjusted from 20 to 24
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: AppColors.danger),
                      SizedBox(width: 8), // Modified from 10 to 8
                      Text(
                        'Alertas de Estoque Baixo',
                        style: TextStyle(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Os seguintes ingredientes atingiram níveis críticos de stock e necessitam reabastecimento imediato:',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14), // Adjusted from 13 to 14
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (context, _) => const Divider(color: AppColors.surfaceLight),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.inventory_2_outlined, color: AppColors.danger),
                      title: Text(item.name, style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        'Mínimo de segurança: ${item.minStock.toStringAsFixed(1)} ${item.unitMeasure}',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                      trailing: Text(
                        '${item.inStock.toStringAsFixed(1)} ${item.unitMeasure}',
                        style: const TextStyle(color: AppColors.danger, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
