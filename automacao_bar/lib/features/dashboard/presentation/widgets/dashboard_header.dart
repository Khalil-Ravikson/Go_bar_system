import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/core/database/daos/inventory_dao.dart';
import 'package:automacao_bar/core/database/database_provider.dart';
import 'package:automacao_bar/core/utils/pdf_helper.dart';
import 'package:automacao_bar/core/utils/pdf_reports.dart';

class DashboardHeader extends ConsumerWidget {
  final List<ProductBalance> lowStockProducts;

  const DashboardHeader({
    super.key,
    required this.lowStockProducts,
  });

  Future<void> _exportClosingPdf(BuildContext context, WidgetRef ref) async {
    try {
      final revenue = ref.read(revenueTodayProvider).value ?? 0.0;
      final orderCount = ref.read(orderCountTodayProvider).value ?? 0;
      final revenueByMethod = ref.read(revenueByMethodTodayProvider).value ?? {};
      final topProducts = ref.read(topProductsTodayProvider).value ?? [];
      final wastes = ref.read(allWasteRecordsProvider).value ?? [];
      final stockItems = ref.read(allStockItemsProvider).value ?? [];

      final bytes = await PdfReports.generateClosingReport(
        revenueToday: revenue,
        orderCountToday: orderCount,
        revenueByMethod: revenueByMethod,
        topProducts: topProducts,
        wasteRecords: wastes,
        stockItems: stockItems,
      );

      await exportAndDownloadPdf(bytes, 'fechamento_caixa_${DateTime.now().millisecondsSinceEpoch}.pdf');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fechamento de caixa exportado em PDF com sucesso!'),
          backgroundColor: AppColors.neonGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao exportar fechamento: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            SizedBox(height: 8),
            Text(
              'Painel de Business Intelligence • Tempo Real',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _exportClosingPdf(context, ref),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.surfaceLight),
                  ),
                  child: const Icon(Icons.picture_as_pdf, color: AppColors.electricBlue, size: 24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  if (lowStockProducts.isNotEmpty) {
                    _showLowStockBottomSheet(context, lowStockProducts);
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.surfaceLight),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.notifications_none, color: AppColors.neonGreen, size: 24),
                      if (lowStockProducts.isNotEmpty)
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
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${lowStockProducts.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
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
        ),
      ],
    );
  }

  void _showLowStockBottomSheet(BuildContext context, List<ProductBalance> items) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
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
                      SizedBox(width: 8),
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
                'Os seguintes produtos atingiram níveis críticos de stock e necessitam reabastecimento imediato:',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
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
                      title: Text(item.product.name, style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        'Mínimo de segurança: ${item.product.minStock.toStringAsFixed(1)}',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                      trailing: Text(
                        item.balance.toStringAsFixed(1),
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
