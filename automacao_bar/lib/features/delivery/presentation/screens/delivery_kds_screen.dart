import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/features/delivery/application/delivery_provider.dart';

class DeliveryKdsScreen extends ConsumerWidget {
  const DeliveryKdsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveries = ref.watch(deliveryOrdersProvider);
    final couriers = ref.watch(couriersProvider);

    // Active deliveries are those not yet settled
    final activeDeliveries = deliveries.where((d) => !d.isSettled).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Delivery KDS - Despacho', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
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
                'Monitor de Entregas & Logística',
                style: TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Despache pedidos de Delivery, atribua estafetas e acompanhe o status da entrega.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: activeDeliveries.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhuma entrega ativa no momento.',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 16),
                        ),
                      )
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 420,
                          mainAxisExtent: 310,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: activeDeliveries.length,
                        itemBuilder: (context, index) {
                          final order = activeDeliveries[index];
                          return _buildDeliveryCard(context, ref, order, couriers);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryCard(BuildContext context, WidgetRef ref, DeliveryOrder order, List<Courier> couriers) {
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (order.status) {
      case 'preparando':
        statusColor = AppColors.orange;
        statusLabel = 'PREPARANDO';
        statusIcon = Icons.soup_kitchen_outlined;
        break;
      case 'a_caminho':
        statusColor = AppColors.neonGreen;
        statusLabel = 'A CAMINHO';
        statusIcon = Icons.delivery_dining;
        break;
      case 'entregue':
      default:
        statusColor = AppColors.textSecondary;
        statusLabel = 'ENTREGUE';
        statusIcon = Icons.done_all;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: order.status == 'preparando' 
              ? AppColors.surfaceLight 
              : statusColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: ID and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nota #${order.id.toUpperCase()}',
                style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Customer Address
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.textMuted, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.customerAddress,
                  style: const TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: AppColors.surfaceLight),

          // Items Summary
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: order.items.length,
              itemBuilder: (context, idx) {
                final item = order.items[idx];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item['quantity']}x ${item['name']}',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(height: 20, color: AppColors.surfaceLight),

          // Motoboy assignment dropdown
          Row(
            children: [
              const Icon(Icons.person_outline, color: AppColors.textMuted, size: 16),
              const SizedBox(width: 8),
              const Text('Estafeta:', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isDense: true,
                    value: order.courierId,
                    hint: const Text('Não atribuído', style: TextStyle(color: AppColors.danger, fontSize: 12, fontWeight: FontWeight.bold)),
                    dropdownColor: AppColors.surface,
                    style: const TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.bold),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Não atribuído', style: TextStyle(color: AppColors.danger)),
                      ),
                      ...couriers.map((c) {
                        return DropdownMenuItem<String>(
                          value: c.id,
                          child: Text(c.name),
                        );
                      }),
                    ],
                    onChanged: (val) {
                      ref.read(deliveryOrdersProvider.notifier).assignCourier(order.id, val);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Action button depending on status
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: order.status == 'preparando' 
                    ? AppColors.neonGreen 
                    : (order.status == 'a_caminho' ? AppColors.surfaceLight : AppColors.surfaceLight),
                foregroundColor: order.status == 'preparando' ? Colors.black : AppColors.textMain,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: order.courierId == null 
                  ? null // Require courier assignment first
                  : () {
                      if (order.status == 'preparando') {
                        ref.read(deliveryOrdersProvider.notifier).updateDeliveryStatus(order.id, 'a_caminho');
                      } else if (order.status == 'a_caminho') {
                        ref.read(deliveryOrdersProvider.notifier).updateDeliveryStatus(order.id, 'entregue');
                      }
                    },
              child: Text(
                order.status == 'preparando' 
                    ? 'SAIU PARA ENTREGA' 
                    : (order.status == 'a_caminho' ? 'CONFIRMAR COMO ENTREGUE' : 'ENTREGA CONCLUÍDA'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
