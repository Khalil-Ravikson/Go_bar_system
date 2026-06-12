import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/shared/presentation/components/product_card.dart';
import 'package:automacao_bar/features/pos/presentation/providers/cart_provider.dart';
import 'order_sidebar.dart';

class PosScreen extends ConsumerWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock products data
    final List<Map<String, dynamic>> mockProducts = [
      {
        'id': 'p1',
        'name': 'Chopp Brahma 300ml',
        'price': 9.90,
        'isHappyHour': false,
        'isSoldOut': false,
      },
      {
        'id': 'p2',
        'name': 'Heineken Long Neck',
        'price': 12.00,
        'isHappyHour': true,
        'isSoldOut': false,
      },
      {
        'id': 'p3',
        'name': 'Gin Tônica Tropical',
        'price': 24.90,
        'isHappyHour': false,
        'isSoldOut': false,
      },
      {
        'id': 'p4',
        'name': 'Caipirinha de Limão',
        'price': 15.00,
        'isHappyHour': false,
        'isSoldOut': true,
      },
    ];

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
                    itemCount: mockProducts.length,
                    itemBuilder: (context, index) {
                      final product = mockProducts[index];
                      return ProductCard(
                        name: product['name'] as String,
                        price: product['price'] as double,
                        isHappyHour: product['isHappyHour'] as bool,
                        isSoldOut: product['isSoldOut'] as bool,
                        onAdd: () {
                          ref.read(cartProvider.notifier).addItem(
                            product['id'] as String,
                            product['name'] as String,
                            product['price'] as double,
                          );
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product['name']} adicionado à comanda!'),
                              duration: const Duration(seconds: 1),
                            ),
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
