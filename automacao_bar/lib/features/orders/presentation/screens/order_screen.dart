import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/shared/presentation/components/neon_button.dart';
import 'package:automacao_bar/shared/presentation/components/app_section_header.dart';
import 'package:automacao_bar/shared/presentation/components/app_info_card.dart';
import 'package:automacao_bar/shared/presentation/components/app_empty_state.dart';
import 'package:automacao_bar/shared/presentation/components/app_bottom_action_bar.dart';
import 'package:automacao_bar/features/auth/application/auth_provider.dart';
import 'package:automacao_bar/features/cash_register/application/cash_register_provider.dart';
import 'package:automacao_bar/features/printer/application/printer_provider.dart';
import 'package:automacao_bar/features/printer/presentation/widgets/thermal_receipt_preview.dart';
import 'package:automacao_bar/features/crm/application/customers_provider.dart';
import 'package:automacao_bar/features/rh/application/shift_provider.dart';
import 'package:automacao_bar/features/inventory/application/inventory_provider.dart';
import '../widgets/order_header_card.dart';
import '../widgets/order_item_tile.dart';
import '../widgets/qr_code_dialog.dart';
import '../widgets/whatsapp_share_dialog.dart';
import '../widgets/payment_modal/payment_modal.dart';

/// Tela unificada de Comanda — consolida order_details_screen + table_details_screen.
/// Exibe itens em preparo e entregues, totais e acções de pagamento.
class OrderScreen extends ConsumerStatefulWidget {
  final String tableNumber;

  const OrderScreen({
    super.key,
    this.tableNumber = '04',
  });

  @override
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  late List<Map<String, dynamic>> _preparingItems;
  late List<Map<String, dynamic>> _deliveredItems;
  double _paidAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _preparingItems = [
      {'name': 'Gin Tônica Tropical', 'quantity': 1, 'price': 24.90},
      {'name': 'Caipirinha de Limão', 'quantity': 1, 'price': 15.00},
    ];
    _deliveredItems = [
      {'name': 'Chopp Brahma 300ml', 'quantity': 3, 'price': 9.90},
      {'name': 'Heineken Long Neck', 'quantity': 2, 'price': 12.00},
      {'name': 'Porção de Batatas Fritas', 'quantity': 1, 'price': 28.00},
    ];
  }

  // ── Computed values ──────────────────────────────────────────────────────
  double get _subtotal {
    double sum = 0;
    for (var i in [..._preparingItems, ..._deliveredItems]) {
      sum += (i['price'] as double) * (i['quantity'] as int);
    }
    return sum;
  }

  double get _serviceTax => _subtotal * 0.10;
  double get _total => _subtotal + _serviceTax;
  double get _remaining => _total - _paidAmount;

  // ── Actions ──────────────────────────────────────────────────────────────
  void _showPaymentModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PaymentModal(
        remainingAmount: _remaining,
        preparingItems: _preparingItems,
        deliveredItems: _deliveredItems,
        onPay: _processPayment,
      ),
    );
  }

  void _processPayment(
    double amountPaid,
    String method,
    List<Map<String, dynamic>> paidItems,
  ) {
    final session = ref.read(authProvider);
    final cashState = ref.read(cashRegisterProvider);

    if (method == 'Dinheiro' && cashState.isOpen) {
      ref.read(cashRegisterProvider.notifier).addTransaction(
            amount: amountPaid,
            type: CashTransactionType.venda,
            reason: 'Venda Mesa ${widget.tableNumber} (Divisão)',
            user: session.name,
          );
    }

    if (method == 'Lançar na Conta') {
      final customer = ref.read(selectedCustomerProvider);
      if (customer != null) {
        ref.read(customersProvider.notifier).chargeDebt(customer.id, amountPaid);
      }
    }

    ref.read(shiftProvider.notifier).addSale(amountPaid);

    if (paidItems.isNotEmpty) {
      ref.read(inventoryProvider.notifier).decrementStockForItems(paidItems);
    } else {
      if (amountPaid >= _remaining - 0.05) {
        ref.read(inventoryProvider.notifier)
            .decrementStockForItems([..._preparingItems, ..._deliveredItems]);
      }
    }

    setState(() {
      _paidAmount += amountPaid;
      if (paidItems.isNotEmpty) {
        for (var paid in paidItems) {
          final name = paid['name'] as String;
          final qty = paid['quantity'] as int;
          _removeFromList(_preparingItems, name, qty);
          _removeFromList(_deliveredItems, name, qty);
        }
      }
    });

    if (_remaining <= 0.05) {
      setState(() {
        _preparingItems.clear();
        _deliveredItems.clear();
      });
      _showFullyPaidDialog(method);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Pagamento parcial de R\$ ${amountPaid.toStringAsFixed(2)} via $method confirmado!',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.neonGreen,
      ));
    }
  }

  void _removeFromList(List<Map<String, dynamic>> list, String name, int qty) {
    for (int i = 0; i < list.length; i++) {
      if (list[i]['name'] == name) {
        final current = list[i]['quantity'] as int;
        if (current <= qty) {
          list.removeAt(i);
        } else {
          list[i]['quantity'] = current - qty;
        }
        break;
      }
    }
  }

  void _showFullyPaidDialog(String method) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.neonGreen),
            SizedBox(width: 10),
            Text('Conta Paga', style: TextStyle(color: AppColors.textMain)),
          ],
        ),
        content: Text(
          'A comanda da Mesa ${widget.tableNumber} foi liquidada via $method!\n\nValor Final: R\$ ${_total.toStringAsFixed(2)}',
          style: const TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/pos');
            },
            child: const Text('Voltar ao Início',
                style: TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Comanda Mesa ${widget.tableNumber}',
            style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code, color: AppColors.neonGreen),
            tooltip: 'Cardápio QR',
            onPressed: () => QrCodeDialog.show(context, widget.tableNumber),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OrderHeaderCard(
            tableNumber: widget.tableNumber,
            remainingAmount: _remaining,
          ),
          Expanded(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: _buildFooter(),
    );
  }

  Widget _buildBody() {
    final bool isEmpty = _preparingItems.isEmpty && _deliveredItems.isEmpty;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Partial payment banner
            if (_paidAmount > 0) ...[
              AppInfoCard(
                borderColor: AppColors.neonGreen.withValues(alpha: 0.3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total já pago:',
                        style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
                    Text('R\$ ${_paidAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: AppColors.neonGreen, fontWeight: FontWeight.w800, fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Items in preparation
            if (_preparingItems.isNotEmpty) ...[
              const AppSectionHeader(
                icon: Icons.hourglass_empty,
                title: 'ITENS EM PREPARO',
                color: AppColors.warning,
              ),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _preparingItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => OrderItemTile(
                  name: _preparingItems[i]['name'],
                  qty: _preparingItems[i]['quantity'],
                  price: _preparingItems[i]['price'],
                  statusText: 'Cozinha',
                  statusColor: AppColors.warning,
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Delivered items
            if (_deliveredItems.isNotEmpty) ...[
              const AppSectionHeader(
                icon: Icons.check_circle_outline,
                title: 'ITENS ENTREGUES',
                color: AppColors.neonGreen,
              ),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _deliveredItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => OrderItemTile(
                  name: _deliveredItems[i]['name'],
                  qty: _deliveredItems[i]['quantity'],
                  price: _deliveredItems[i]['price'],
                  statusText: 'Entregue',
                  statusColor: AppColors.neonGreen,
                ),
              ),
            ],

            // Empty state
            if (isEmpty)
              const AppEmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'Comanda Liquidada',
                subtitle: 'Todos os itens desta mesa foram pagos.',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return AppBottomActionBar(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      children: [
        // Totals
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Subtotal', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
          Text('R\$ ${_subtotal.toStringAsFixed(2)}',
              style: const TextStyle(color: AppColors.textMain, fontSize: 14)),
        ]),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Taxa de Serviço (10%)',
              style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
          Text('R\$ ${_serviceTax.toStringAsFixed(2)}',
              style: const TextStyle(color: AppColors.textMain, fontSize: 14)),
        ]),
        const Divider(),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Saldo Restante',
              style: TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.bold)),
          Text('R\$ ${_remaining.toStringAsFixed(2)}',
              style: const TextStyle(
                  color: AppColors.neonGreen, fontSize: 22, fontWeight: FontWeight.w800)),
        ]),

        // Print + WhatsApp row
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.print_outlined, color: AppColors.neonGreen, size: 16),
              label: const Text('IMPRIMIR',
                  style: TextStyle(
                      color: AppColors.neonGreen, fontWeight: FontWeight.bold, fontSize: 12)),
              onPressed: () {
                final printerState = ref.read(printerProvider);
                showDialog(
                  context: context,
                  builder: (_) => ThermalReceiptPreview(
                    tableNumber: widget.tableNumber,
                    preparingItems: _preparingItems,
                    deliveredItems: _deliveredItems,
                    subtotal: _subtotal,
                    serviceTax: _serviceTax,
                    total: _total,
                    paperWidth: printerState.paperWidth,
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.neonGreen),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.share, color: AppColors.neonGreen, size: 16),
              label: const Text('WHATSAPP',
                  style: TextStyle(
                      color: AppColors.neonGreen, fontWeight: FontWeight.bold, fontSize: 12)),
              onPressed: () => WhatsappShareDialog.show(
                context,
                tableNumber: widget.tableNumber,
                preparingItems: _preparingItems,
                deliveredItems: _deliveredItems,
                subtotal: _subtotal,
                serviceTax: _serviceTax,
                total: _total,
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.neonGreen),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ]),

        // Add items + Charge row
        Row(children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => context.go('/pos'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.neonGreen),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('ADICIONAR ITENS',
                  style: TextStyle(
                      color: AppColors.neonGreen, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: NeonButton(
              text: 'COBRAR MESA',
              onTap: _remaining > 0 ? _showPaymentModal : null,
              isFullWidth: false,
            ),
          ),
        ]),
      ],
    );
  }
}
