import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/shared/presentation/components/neon_button.dart';
import 'package:automacao_bar/features/pos/presentation/providers/cart_provider.dart';
import 'package:automacao_bar/features/crm/application/customers_provider.dart';
import 'package:automacao_bar/features/rh/application/shift_provider.dart';
import 'package:automacao_bar/core/database/database_provider.dart';
import 'package:uuid/uuid.dart';

class SidebarFooter extends ConsumerWidget {
  final bool isMobileBottomSheet;

  const SidebarFooter({
    super.key,
    required this.isMobileBottomSheet,
  });

  Future<void> _processCheckout(WidgetRef ref, double total, List<CartItem> cartItems, String method) async {
    final ordersDao = ref.read(ordersDaoProvider);
    final paymentsDao = ref.read(paymentsDaoProvider);
    final inventoryDao = ref.read(inventoryDaoProvider);

    final orderId = const Uuid().v7();
    const tableId = 'pos_quick_sale';

    await ordersDao.openOrder(orderId, tableId);

    for (final item in cartItems) {
      await ordersDao.addOrderItem(
        orderId: orderId,
        productId: item.id,
        quantity: item.quantity.toDouble(),
        unitPrice: item.price,
        notes: item.notes,
      );
    }

    await paymentsDao.processPayment(
      orderId: orderId,
      method: method,
      amount: total,
    );

    final List<Map<String, dynamic>> itemsList = cartItems.map((item) => {
      'productId': item.id,
      'quantity': item.quantity,
    }).toList();

    await inventoryDao.insertMovementsForOrder(
      orderId: orderId,
      items: itemsList,
    );

    ref.read(cartProvider.notifier).clearCart();
    ref.read(selectedCustomerProvider.notifier).state = null;
  }

  void _showCheckoutDialog(BuildContext context, WidgetRef ref, double total, List<CartItem> cartItems) {
    final selectedCustomer = ref.read(selectedCustomerProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Finalizar Comanda',
          style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold),
        ),
        content: Text(
          selectedCustomer != null
              ? 'Deseja cobrar a Mesa 04?\nCliente Vinculado: ${selectedCustomer.name}\nValor Total: R\$ ${total.toStringAsFixed(2)}'
              : 'Deseja cobrar a Mesa 04?\nValor Total: R\$ ${total.toStringAsFixed(2)}',
          style: const TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
          ),
          if (selectedCustomer != null)
            TextButton(
              onPressed: () async {
                ref.read(customersProvider.notifier).chargeDebt(selectedCustomer.id, total);
                ref.read(shiftProvider.notifier).addSale(total);
                await _processCheckout(ref, total, cartItems, 'Lançar na Conta');
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Comanda lançada no Fiado de ${selectedCustomer.name}!'),
                      backgroundColor: AppColors.neonGreen,
                    ),
                  );
                }
              },
              child: const Text('Lançar Fiado', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
            ),
          TextButton(
            onPressed: () async {
              ref.read(shiftProvider.notifier).addSale(total);
              await _processCheckout(ref, total, cartItems, 'Dinheiro');
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Comanda paga com sucesso!',
                      style: TextStyle(color: Colors.black),
                    ),
                    backgroundColor: AppColors.neonGreen,
                  ),
                );
              }
            },
            child: const Text('Confirmar Pago', style: TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final subtotal = ref.watch(cartTotalProvider);
    final serviceTax = subtotal * 0.10;
    final total = subtotal + serviceTax;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Subtotal Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  'R\$ ${subtotal.toStringAsFixed(2)}',
                  key: ValueKey<double>(subtotal),
                  style: const TextStyle(color: AppColors.textMain, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Tax Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Taxa de Serviço (10%)',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  'R\$ ${serviceTax.toStringAsFixed(2)}',
                  key: ValueKey<double>(serviceTax),
                  style: const TextStyle(color: AppColors.textMain, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          const Divider(),
          
          const SizedBox(height: 16),
          
          // Total Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: AppColors.textMain,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  'R\$ ${total.toStringAsFixed(2)}',
                  key: ValueKey<double>(total),
                  style: const TextStyle(
                    color: AppColors.neonGreen,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Action Buttons
          Row(
            children: [
              if (cartItems.any((item) => !item.isSent))
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        ref.read(cartProvider.notifier).markAllAsSent();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Comanda enviada para a cozinha!', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                            backgroundColor: AppColors.neonGreen,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: OutlinedButton(
                        onPressed: () {
                          ref.read(cartProvider.notifier).markAllAsSent();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Comanda enviada para a cozinha!', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                              backgroundColor: AppColors.neonGreen,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.neonGreen, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text(
                          'ENVIAR COZINHA',
                          style: TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ),
              if (cartItems.any((item) => !item.isSent)) const SizedBox(width: 16),
              Expanded(
                child: NeonButton(
                  text: 'COBRAR MESA',
                  onTap: cartItems.isEmpty
                      ? null
                      : () {
                          if (isMobileBottomSheet) {
                            Navigator.of(context).pop();
                          }
                          _showCheckoutDialog(context, ref, total, cartItems);
                        },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
