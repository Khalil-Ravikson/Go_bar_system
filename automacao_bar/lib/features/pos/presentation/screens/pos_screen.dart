import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/features/pos/presentation/screens/order_sidebar.dart';
import 'package:automacao_bar/features/pos/presentation/widgets/catalog_grid.dart';

class PosScreen extends ConsumerWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth <= 600;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: isMobile
                ? const CatalogGrid()
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Expanded(child: CatalogGrid()),
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
                            topLeft: Radius.circular(24), // Adjusted to 24
                            topRight: Radius.circular(24), // Adjusted to 24
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
