import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/shared/presentation/components/product_card.dart';
import 'package:automacao_bar/features/management/application/products_provider.dart';
import 'package:automacao_bar/features/pos/presentation/widgets/item_notes_modal.dart';
import 'package:automacao_bar/features/pos/presentation/screens/order_sidebar.dart';

import 'package:automacao_bar/features/crm/application/customers_provider.dart';

class PosScreen extends ConsumerWidget {
  const PosScreen({super.key});

  void _showLinkCustomerDialog(BuildContext context, WidgetRef ref, List<Customer> customers) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Vincular Cliente à Comanda', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
          content: customers.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Text('Nenhum cliente cadastrado no CRM.', style: TextStyle(color: AppColors.textMuted)),
                )
              : SizedBox(
                  width: 300,
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: customers.length,
                    separatorBuilder: (context, _) => const Divider(color: AppColors.surfaceLight),
                    itemBuilder: (context, index) {
                      final c = customers[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: AppColors.surfaceLight,
                          child: Text(c.name[0], style: const TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(c.name, style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          c.currentBalance > 0 
                              ? 'Saldo Devedor: R\$ ${c.currentBalance.toStringAsFixed(2)}'
                              : 'Sem débitos',
                          style: TextStyle(color: c.currentBalance > 0 ? AppColors.danger : AppColors.textMuted, fontSize: 12),
                        ),
                        onTap: () {
                          ref.read(selectedCustomerProvider.notifier).state = c;
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCELAR', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final selectedCustomer = ref.watch(selectedCustomerProvider);
    final customers = ref.watch(customersProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth <= 600;

        final Widget catalogWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title & Vincular Cliente Row
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ponto de Venda',
                        style: TextStyle(
                          color: AppColors.textMain,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Selecione os produtos para comanda',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  if (selectedCustomer != null)
                    InputChip(
                      label: Text(
                        selectedCustomer.name,
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      avatar: const Icon(Icons.person, color: Colors.black, size: 16),
                      backgroundColor: AppColors.neonGreen,
                      onDeleted: () {
                        ref.read(selectedCustomerProvider.notifier).state = null;
                      },
                      deleteIcon: const Icon(Icons.cancel, size: 16, color: Colors.black),
                    )
                  else
                    OutlinedButton.icon(
                      icon: const Icon(Icons.person_add_alt_1_outlined, color: AppColors.neonGreen, size: 16),
                      label: const Text('VINCULAR', style: TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold, fontSize: 11)),
                      onPressed: () => _showLinkCustomerDialog(context, ref, customers),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.neonGreen, width: 1.2),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            
            // Products Grid
            Expanded(
              child: LayoutBuilder(
                builder: (context, gridConstraints) {
                  int crossAxisCount = 2;
                  if (gridConstraints.maxWidth > 900) {
                    crossAxisCount = 4;
                  } else if (gridConstraints.maxWidth > 650) {
                    crossAxisCount = 3;
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(24),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCard(
                        name: product.name,
                        price: product.price,
                        isHappyHour: product.isHappyHour,
                        isSoldOut: product.isSoldOut,
                        onAdd: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => ItemNotesModal(product: product),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: isMobile
                ? catalogWidget
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: catalogWidget),
                      const OrderSidebar(),
                    ],
                  ),
          ),
          floatingActionButton: isMobile
              ? FloatingActionButton(
                  backgroundColor: AppColors.neonGreen,
                  foregroundColor: Colors.black,
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => Container(
                        height: MediaQuery.of(context).size.height * 0.85,
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: const OrderSidebar(isMobileBottomSheet: true),
                      ),
                    );
                  },
                  child: const Icon(Icons.shopping_cart),
                )
              : null,
        );
      },
    );
  }
}
