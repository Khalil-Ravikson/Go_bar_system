import 'package:flutter/material.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/features/pos/presentation/widgets/sidebar_header.dart';
import 'package:automacao_bar/features/pos/presentation/widgets/sidebar_cart_list.dart';
import 'package:automacao_bar/features/pos/presentation/widgets/sidebar_footer.dart';
import 'package:automacao_bar/features/pos/presentation/providers/cart_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lateral de pedidos do PDV.
/// Em desktop: barra fixa com largura de 384px.
/// Em mobile: renderizado dentro de um bottom sheet via [isMobileBottomSheet].
class OrderSidebar extends ConsumerWidget {
  final bool isMobileBottomSheet;

  const OrderSidebar({
    super.key,
    this.isMobileBottomSheet = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);

    return Container(
      width: isMobileBottomSheet ? double.infinity : 384,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: isMobileBottomSheet
            ? null
            : const Border(
                left: BorderSide(color: AppColors.surfaceLight, width: 1),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SidebarHeader(itemCount: cartItems.length),
          const Divider(),
          Expanded(child: const SidebarCartList()),
          const Divider(),
          SidebarFooter(isMobileBottomSheet: isMobileBottomSheet),
        ],
      ),
    );
  }
}
