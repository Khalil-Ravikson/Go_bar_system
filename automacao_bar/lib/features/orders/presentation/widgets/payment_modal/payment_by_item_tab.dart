import 'package:flutter/material.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/features/crm/application/customers_provider.dart';
import 'package:automacao_bar/shared/presentation/components/app_empty_state.dart';
import 'payment_action_buttons.dart';

/// Aba 3 do PaymentModal — cobrança item a item.
class PaymentByItemTab extends StatefulWidget {
  final List<Map<String, dynamic>> preparingItems;
  final List<Map<String, dynamic>> deliveredItems;
  final Customer? selectedCustomer;
  final void Function(double, String, List<Map<String, dynamic>>) onConfirm;

  const PaymentByItemTab({
    super.key,
    required this.preparingItems,
    required this.deliveredItems,
    required this.selectedCustomer,
    required this.onConfirm,
  });

  @override
  State<PaymentByItemTab> createState() => _PaymentByItemTabState();
}

class _PaymentByItemTabState extends State<PaymentByItemTab> {
  final Map<String, int> _selectedQuantities = {};

  List<Map<String, dynamic>> get _allItems => [
        ...widget.preparingItems,
        ...widget.deliveredItems,
      ];

  double _getPrice(String name) {
    for (var item in _allItems) {
      if (item['name'] == name) return item['price'] as double;
    }
    return 0.0;
  }

  double get _subtotal => _selectedQuantities.entries
      .fold(0.0, (sum, e) => sum + _getPrice(e.key) * e.value);
  double get _serviceTax => _subtotal * 0.10;
  double get _total => _subtotal + _serviceTax;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Cobrança por Item',
              style: TextStyle(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Escolha a quantidade de cada produto a pagar nesta rodada.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          const SizedBox(height: 16),

          // Item list
          Expanded(
            child: _allItems.isEmpty
                ? const AppEmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'Nenhum item disponível',
                  )
                : ListView.separated(
                    itemCount: _allItems.length,
                    separatorBuilder: (_, _) =>
                        const Divider(color: AppColors.surfaceLight, height: 1),
                    itemBuilder: (context, idx) {
                      final item = _allItems[idx];
                      final name = item['name'] as String;
                      final maxQty = item['quantity'] as int;
                      final price = item['price'] as double;
                      final selected = _selectedQuantities[name] ?? 0;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name,
                                      style: const TextStyle(
                                          color: AppColors.textMain,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 2),
                                  Text(
                                    'R\$ ${price.toStringAsFixed(2)} unid · max ${maxQty}x',
                                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            // Stepper
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 18, color: AppColors.textMuted),
                                  onPressed: selected > 0
                                      ? () => setState(() {
                                            selected == 1
                                                ? _selectedQuantities.remove(name)
                                                : _selectedQuantities[name] = selected - 1;
                                          })
                                      : null,
                                ),
                                SizedBox(
                                  width: 28,
                                  child: Text(
                                    '$selected',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: selected > 0 ? AppColors.neonGreen : AppColors.textMuted,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 18, color: AppColors.neonGreen),
                                  onPressed: selected < maxQty
                                      ? () => setState(
                                            () => _selectedQuantities[name] = selected + 1,
                                          )
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Total card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.08)),
            ),
            child: Column(
              children: [
                _row('Subtotal', _subtotal),
                const SizedBox(height: 6),
                _row('Taxa de Serviço (10%)', _serviceTax),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('TOTAL DA SELEÇÃO',
                        style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('R\$ ${_total.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: AppColors.neonGreen, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          PaymentActionButtons(
            totalToPay: _total,
            itemsPaid: _selectedQuantities.entries
                .map((e) => {'name': e.key, 'quantity': e.value})
                .toList(),
            selectedCustomer: widget.selectedCustomer,
            onConfirm: widget.onConfirm,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, double value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          Text('R\$ ${value.toStringAsFixed(2)}',
              style: const TextStyle(color: AppColors.textMain, fontSize: 13)),
        ],
      );
}
