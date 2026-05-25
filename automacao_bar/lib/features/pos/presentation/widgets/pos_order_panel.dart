import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../design_system/components/app_neon_button.dart';
import '../../application/cart_provider.dart';

class PosOrderPanel extends ConsumerWidget {
  final bool isDesktop;

  const PosOrderPanel({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuta apenas o estado do carrinho
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: isDesktop ? AppColors.surface.withOpacity(0.5) : AppColors.surface,
        border: Border(top: isDesktop ? BorderSide.none : const BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            if (isDesktop) ...[
              const Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.receipt_long, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Text('Comanda Atual', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Divider(color: AppColors.border, height: 1),
            ],
            
            // LISTA DE ITENS REATIVA
            Expanded(
              child: cartItems.isEmpty
                  ? const Center(child: Text('Nenhum item adicionado', style: TextStyle(color: AppColors.textSecondary)))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: cartItems.length,
                      separatorBuilder: (context, index) => const Divider(color: AppColors.border),
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return Row(
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: AppColors.error, size: 20),
                                  onPressed: () => cartNotifier.removeProduct(item.product.id),
                                ),
                                Text('${item.quantity}', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryNeon, size: 20),
                                  onPressed: () => cartNotifier.addProduct(item.product),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Text(item.product.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                            ),
                            Text(
                              CurrencyFormatter.format(item.product.currentPrice * item.quantity),
                              style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                            ),
                          ],
                        );
                      },
                    ),
            ),
            const Divider(color: AppColors.border, height: 1),
            
            // RODAPÉ COM VALORES REATIVOS E BOTÃO MODULARIZADO
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (isDesktop) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                        Text(CurrencyFormatter.format(cartNotifier.totalInCents), style: const TextStyle(color: AppColors.textPrimary, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isDesktop ? 'Total' : 'Mesa 12', style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                      Text(
                        CurrencyFormatter.format(cartNotifier.totalInCents),
                        style: const TextStyle(color: AppColors.primaryNeon, fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Usando o nosso novo Lego!
                  AppNeonButton(
                    text: 'CONFIRMAR PEDIDO',
                    icon: Icons.check,
                    onPressed: cartItems.isEmpty ? null : () {
                      // Simulação de ação de fechar venda
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Comanda enviada para a mesa!')),
                      );
                      cartNotifier.clearCart();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}