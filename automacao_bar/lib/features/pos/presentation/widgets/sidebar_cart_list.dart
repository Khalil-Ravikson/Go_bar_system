import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/features/pos/presentation/providers/cart_provider.dart';
import 'package:automacao_bar/features/waste/application/waste_provider.dart';

class SidebarCartList extends ConsumerWidget {
  const SidebarCartList({super.key});

  void _showDeleteDialog(BuildContext context, WidgetRef ref, CartItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Item enviado à Cozinha',
          style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'O item "${item.name}" já está em preparo.\nComo deseja classificar a remoção?',
          style: const TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(cartProvider.notifier).removeItem(item.id, notes: item.notes);
              Navigator.of(context).pop();
            },
            child: const Text('Erro do Cliente', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              ref.read(wasteProvider.notifier).addWaste(
                productId: item.id,
                productName: item.name,
                quantity: item.quantity.toDouble(),
                reason: 'Cancelado pelo cliente (Cozinha/Preparo)',
              );
              ref.read(cartProvider.notifier).removeItem(item.id, notes: item.notes);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Registrado como Desperdício/Quebra!'),
                  backgroundColor: AppColors.danger,
                ),
              );
            },
            child: const Text(
              'Registrar Desperdício',
              style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);

    if (cartItems.isEmpty) {
      return const Center(
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
            SizedBox(height: 8),
            Text(
              'Adicione itens tocando nos cards de produtos.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
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
                Material(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => ref.read(cartProvider.notifier).decrementQuantity(item.id, notes: item.notes),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.remove,
                        color: AppColors.textMain,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    '${item.quantity}x',
                    key: ValueKey<int>(item.quantity),
                    style: const TextStyle(
                      color: AppColors.neonGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => ref.read(cartProvider.notifier).incrementQuantity(item.id, notes: item.notes),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.add,
                        color: AppColors.textMain,
                        size: 16,
                      ),
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
                  if (item.notes != null && item.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      item.notes!,
                      style: const TextStyle(
                        color: AppColors.warning,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
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
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    'R\$ ${itemTotal.toStringAsFixed(2)}',
                    key: ValueKey<double>(itemTotal),
                    style: const TextStyle(
                      color: AppColors.textMain,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      if (item.isSent) {
                        _showDeleteDialog(context, ref, item);
                      } else {
                        ref.read(cartProvider.notifier).removeItem(item.id, notes: item.notes);
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.delete_outline,
                        color: AppColors.danger,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
