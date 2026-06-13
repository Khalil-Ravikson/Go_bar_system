import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/features/delivery/application/delivery_provider.dart';

class CourierSettlementScreen extends ConsumerWidget {
  const CourierSettlementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couriers = ref.watch(couriersProvider);
    final deliveries = ref.watch(deliveryOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Acerto de Contas com Estafetas', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Acertos de Taxas de Entrega (Fechamento)',
                style: TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Veja a comissão acumulada por cada entregador e registre o pagamento das corridas concluídas.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: ListView.separated(
                  itemCount: couriers.length,
                  separatorBuilder: (context, _) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final courier = couriers[index];

                    // Find all delivered, unsettled orders for this courier
                    final unsettledOrders = deliveries.where((d) => 
                        d.courierId == courier.id && 
                        d.status == 'entregue' && 
                        !d.isSettled
                    ).toList();

                    final totalDue = unsettledOrders.fold<double>(0.0, (sum, o) => sum + o.deliveryFee);

                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: totalDue > 0 
                              ? AppColors.neonGreen.withValues(alpha: 0.15) 
                              : AppColors.surfaceLight,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header info
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    courier.name,
                                    style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Tel: ${courier.phone} • ${courier.deliveryFeeConfig}',
                                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'R\$ ${totalDue.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: totalDue > 0 ? AppColors.neonGreen : AppColors.textMuted,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    '${unsettledOrders.length} entregas pendentes',
                                    style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          
                          if (unsettledOrders.isNotEmpty) ...[
                            const Divider(height: 24, color: AppColors.surfaceLight),
                            const Text(
                              'Entregas Concluídas neste turno:',
                              style: TextStyle(color: AppColors.textMain, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            
                            // Mini list of orders
                            ...unsettledOrders.map((o) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '• ${o.customerAddress}',
                                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'R\$ ${o.deliveryFee.toStringAsFixed(2)}',
                                      style: const TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 38,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.neonGreen.withValues(alpha: 0.1),
                                  foregroundColor: AppColors.neonGreen,
                                  side: const BorderSide(color: AppColors.neonGreen, width: 1),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.payments_outlined, size: 18),
                                label: const Text('DAR BAIXA / PAGAR ESTAFETA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                onPressed: () {
                                  ref.read(deliveryOrdersProvider.notifier).settleCourier(courier.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Comissão de R\$ ${totalDue.toStringAsFixed(2)} paga a ${courier.name}!'),
                                      backgroundColor: AppColors.neonGreen,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 12),
                            const Row(
                              children: [
                                Icon(Icons.check_circle_outline, color: AppColors.textMuted, size: 14),
                                SizedBox(width: 6),
                                Text(
                                  'Todas as contas acertadas com este entregador.',
                                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                                ),
                              ],
                            ),
                          ]
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
