import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/shared/presentation/components/product_card.dart';
import 'package:automacao_bar/features/management/application/products_provider.dart';
import 'package:automacao_bar/features/pos/presentation/widgets/item_notes_modal.dart';
import 'order_sidebar.dart';

class PosScreen extends ConsumerWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth <= 600;

        final Widget catalogWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
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
                    'Selecione os produtos para adicionar à mesa',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
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
