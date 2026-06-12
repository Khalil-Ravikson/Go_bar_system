import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/shared/presentation/components/neon_button.dart';
import 'package:automacao_bar/features/pos/presentation/providers/cart_provider.dart';

class OrderSidebar extends ConsumerWidget {
  final bool isMobileBottomSheet;

  const OrderSidebar({
    super.key,
    this.isMobileBottomSheet = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final subtotal = ref.watch(cartTotalProvider);
    final serviceTax = subtotal * 0.10;
    final total = subtotal + serviceTax;

    return Container(
      width: isMobileBottomSheet ? double.infinity : 380,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: isMobileBottomSheet
            ? null
            : const Border(
                left: BorderSide(color: AppColors.surfaceLight, width: 1.5),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sidebar Header
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Comanda Atual',
                      style: TextStyle(
                        color: AppColors.textMain,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Mesa 04 • Comanda #12',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${cartItems.length} itens',
                    style: const TextStyle(
                      color: AppColors.neonGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(),

          // Order Items List or Empty State
          Expanded(
            child: cartItems.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_basket_outlined,
                          color: AppColors.textMuted,
                          size: 48,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Carrinho Vazio',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Adicione itens tocando nos cards de produtos.',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: cartItems.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final itemTotal = item.price * item.quantity;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Quantity Controls
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () => ref.read(cartProvider.notifier).decrementQuantity(item.id),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceLight,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(
                                    Icons.remove,
                                    color: AppColors.textMain,
                                    size: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${item.quantity}x',
                                style: const TextStyle(
                                  color: AppColors.neonGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => ref.read(cartProvider.notifier).incrementQuantity(item.id),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceLight,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: AppColors.textMain,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          
                          // Product Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    color: AppColors.textMain,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'R\$ ${item.price.toStringAsFixed(2)} unid.',
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          
                          // Item Total Price & Delete Action
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'R\$ ${itemTotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppColors.textMain,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => ref.read(cartProvider.notifier).removeItem(item.id),
                                child: const Icon(
                                  Icons.delete_outline,
                                  color: AppColors.danger,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
          ),

          const Divider(),

          // Summary and Actions Footer
          Padding(
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
                    Text(
                      'R\$ ${subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(color: AppColors.textMain, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Tax Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Taxa de Serviço (10%)',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                    ),
                    Text(
                      'R\$ ${serviceTax.toStringAsFixed(2)}',
                      style: const TextStyle(color: AppColors.textMain, fontSize: 14),
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'R\$ ${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.neonGreen,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // NeonButton
                NeonButton(
                  text: 'COBRAR MESA',
                  onTap: cartItems.isEmpty
                      ? null
                      : () {
                          if (isMobileBottomSheet) {
                            Navigator.of(context).pop();
                          }
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: AppColors.surface,
                              title: const Text(
                                'Finalizar Comanda',
                                style: TextStyle(color: AppColors.textMain),
                              ),
                              content: Text(
                                'Deseja lançar os itens na comanda e cobrar a Mesa 04?\nValor Total: R\$ ${total.toStringAsFixed(2)}',
                                style: const TextStyle(color: AppColors.textMuted),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    ref.read(cartProvider.notifier).clearCart();
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Comanda finalizada com sucesso!',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        backgroundColor: AppColors.neonGreen,
                                      ),
                                    );
                                  },
                                  child: const Text('Confirmar', style: TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
