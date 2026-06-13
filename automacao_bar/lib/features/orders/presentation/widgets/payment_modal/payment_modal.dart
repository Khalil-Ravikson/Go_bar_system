import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/features/cash_register/application/cash_register_provider.dart';
import 'package:automacao_bar/features/crm/application/customers_provider.dart';
import 'payment_total_tab.dart';
import 'payment_split_tab.dart';
import 'payment_by_item_tab.dart';

/// Modal de divisão de conta — 3 abas: Total, Por Igual, Por Item.
/// Chamado via [showModalBottomSheet].
class PaymentModal extends ConsumerStatefulWidget {
  final double remainingAmount;
  final List<Map<String, dynamic>> preparingItems;
  final List<Map<String, dynamic>> deliveredItems;
  final void Function(double amount, String method, List<Map<String, dynamic>> paidItems) onPay;

  const PaymentModal({
    super.key,
    required this.remainingAmount,
    required this.preparingItems,
    required this.deliveredItems,
    required this.onPay,
  });

  @override
  ConsumerState<PaymentModal> createState() => _PaymentModalState();
}

class _PaymentModalState extends ConsumerState<PaymentModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _confirm(double amount, String method, List<Map<String, dynamic>> items) {
    Navigator.of(context).pop();
    widget.onPay(amount, method, items);
  }

  @override
  Widget build(BuildContext context) {
    final cashState = ref.watch(cashRegisterProvider);
    final selectedCustomer = ref.watch(selectedCustomerProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.only(top: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Divisão de Conta',
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Cash register warning
          if (!cashState.isOpen)
            Container(
              margin: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.danger),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Caixa FECHADO. Recebimentos em dinheiro não atualizarão a gaveta!',
                      style: TextStyle(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.neonGreen,
            labelColor: AppColors.neonGreen,
            unselectedLabelColor: AppColors.textMuted,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Pagar Total'),
              Tab(text: 'Por Igual'),
              Tab(text: 'Por Item'),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                PaymentTotalTab(
                  remainingAmount: widget.remainingAmount,
                  selectedCustomer: selectedCustomer,
                  onConfirm: _confirm,
                ),
                PaymentSplitTab(
                  remainingAmount: widget.remainingAmount,
                  selectedCustomer: selectedCustomer,
                  onConfirm: _confirm,
                ),
                PaymentByItemTab(
                  preparingItems: widget.preparingItems,
                  deliveredItems: widget.deliveredItems,
                  selectedCustomer: selectedCustomer,
                  onConfirm: _confirm,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
