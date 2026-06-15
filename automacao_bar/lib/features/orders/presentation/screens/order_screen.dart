import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/shared/presentation/components/neon_button.dart';
import 'package:automacao_bar/shared/presentation/components/app_section_header.dart';
import 'package:automacao_bar/shared/presentation/components/app_info_card.dart';
import 'package:automacao_bar/shared/presentation/components/app_empty_state.dart';
import 'package:automacao_bar/shared/presentation/components/app_bottom_action_bar.dart';

import 'package:automacao_bar/core/database/app_database.dart';
import 'package:automacao_bar/features/tables/application/table_fsm_provider.dart';
import 'package:automacao_bar/features/orders/application/order_fsm_provider.dart' hide orderItemsProvider;
import 'package:automacao_bar/features/auth/application/auth_provider.dart';
import 'package:automacao_bar/features/cash_register/application/cash_register_provider.dart';
import 'package:automacao_bar/features/printer/application/printer_provider.dart';
import 'package:automacao_bar/features/printer/presentation/widgets/thermal_receipt_preview.dart';
import 'package:automacao_bar/features/crm/application/customers_provider.dart';
import 'package:automacao_bar/features/rh/application/shift_provider.dart';
import 'package:automacao_bar/core/database/database_provider.dart';

import '../widgets/order_header_card.dart';
import '../widgets/order_item_tile.dart';
import '../widgets/qr_code_dialog.dart';
import '../widgets/whatsapp_share_dialog.dart';
import '../widgets/payment_modal/payment_modal.dart';

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
  double _paidAmount = 0.0;

  Future<void> _ensureLoggedIn(BuildContext context, VoidCallback onLoggedIn) async {
    final session = ref.read(authProvider);
    if (session != null) {
      onLoggedIn();
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Identifique-se', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Para realizar esta ação, é necessário entrar com seu PIN de operador.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMain, fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: '••••',
                counterText: '',
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceLight)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neonGreen)),
              ),
              onChanged: (val) async {
                if (val.length == 4) {
                  final success = await ref.read(authProvider.notifier).loginByPin(val);
                  if (success) {
                    Navigator.pop(context);
                    onLoggedIn();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PIN inválido.')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentModal(
    BuildContext context,
    String orderId,
    RestaurantTable table,
    List<Map<String, dynamic>> preparingList,
    List<Map<String, dynamic>> deliveredList,
    double remaining,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PaymentModal(
        remainingAmount: remaining,
        preparingItems: preparingList,
        deliveredItems: deliveredList,
        onPay: (amount, method, paidItems) => _processPayment(
          context,
          orderId,
          table,
          amount,
          method,
          paidItems,
          preparingList,
          deliveredList,
          remaining,
        ),
      ),
    );
  }

  Future<void> _processPayment(
    BuildContext context,
    String orderId,
    RestaurantTable table,
    double amountPaid,
    String method,
    List<Map<String, dynamic>> paidItems,
    List<Map<String, dynamic>> preparingList,
    List<Map<String, dynamic>> deliveredList,
    double remaining,
  ) async {
    final session = ref.read(authProvider);
    if (session == null) return;
    final cashState = ref.read(cashRegisterProvider);

    // Register shift & transaction drawer if cashier open
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

    // Call real database DAOs to record the payment and update inventory (Ledger delta)
    final paymentsDao = ref.read(paymentsDaoProvider);
    final inventoryDao = ref.read(inventoryDaoProvider);

    if (method.startsWith('Fiado:')) {
      final customerName = method.substring(6);
      await paymentsDao.processUnpaidCheckout(
        orderId: orderId,
        customerName: customerName,
        amount: amountPaid,
      );
    } else {
      await paymentsDao.processPayment(
        orderId: orderId,
        method: method,
        amount: amountPaid,
        customerId: ref.read(selectedCustomerProvider)?.id,
      );
    }

    if (paidItems.isNotEmpty) {
      await inventoryDao.insertMovementsForOrder(
        orderId: orderId,
        items: paidItems,
        userId: session.name,
      );
    } else {
      if (amountPaid >= remaining - 0.05) {
        await inventoryDao.insertMovementsForOrder(
          orderId: orderId,
          items: [...preparingList, ...deliveredList],
          userId: session.name,
        );
      }
    }

    setState(() {
      _paidAmount += amountPaid;
    });

    if (remaining - amountPaid <= 0.05) {
      // Deduct raw ingredients based on product recipes
      await inventoryDao.deductStockForOrder(orderId);

      // Complete checkout flow
      await ref.read(orderFsmProvider.notifier).payAndCloseOrder(
            orderId: orderId,
            table: table,
          );
      if (mounted) {
        _showFullyPaidDialog(context, method, remaining + _paidAmount - amountPaid);
      }
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

  void _showFullyPaidDialog(BuildContext context, String method, double totalBill) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.neonGreen, width: 1.5),
        ),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.neonGreen),
            const SizedBox(width: 10),
            Text(
              'CONTA LIQUIDADA',
              style: GoogleFonts.shareTechMono(color: AppColors.textMain, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'A comanda da Mesa ${widget.tableNumber} foi liquidada via $method!\n\nValor Final: R\$ ${totalBill.toStringAsFixed(2)}',
          style: const TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/home/pdv');
            },
            child: Text(
              'Voltar ao Salão',
              style: GoogleFonts.shareTechMono(color: AppColors.neonGreen, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, child) {
            final productsAsync = ref.watch(activeProductsStreamProvider);
            return AlertDialog(
              backgroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.neonGreen, width: 1.5),
              ),
              title: Text(
                'ADICIONAR ITEM À COMANDA',
                style: GoogleFonts.shareTechMono(color: AppColors.textMain, fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: 400,
                height: 400,
                child: productsAsync.when(
                  data: (products) {
                    if (products.isEmpty) {
                      return const Center(
                        child: Text(
                          'Nenhum produto cadastrado no estoque.',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ListTile(
                          title: Text(
                            product.name,
                            style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'R\$ ${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: AppColors.neonGreen),
                                onPressed: () async {
                                  await ref.read(orderFsmProvider.notifier).addProductToOrder(
                                        orderId: orderId,
                                        productId: product.id,
                                        quantity: 1,
                                        unitPrice: product.price,
                                      );
                                  if (context.mounted) {
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${product.name} adicionado com sucesso!'),
                                        backgroundColor: AppColors.neonGreen,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(
                    child: Text('Erro: $err', style: const TextStyle(color: Colors.red)),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Fechar', style: TextStyle(color: AppColors.textMuted)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tablesAsync = ref.watch(tablesStreamProvider);

    return tablesAsync.when(
      data: (tables) {
        final tableNum = int.tryParse(widget.tableNumber) ?? 0;
        final table = tables.firstWhere(
          (t) => t.number == tableNum,
          orElse: () => RestaurantTable(
            id: '',
            number: tableNum,
            status: 'livre',
            x: 0,
            y: 0,
            capacity: 4,
            updatedAt: 0,
          ),
        );

        if (table.id.isEmpty) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: Text('Mesa ${widget.tableNumber}'),
              backgroundColor: AppColors.surface,
            ),
            body: const Center(
              child: Text(
                'Mesa não encontrada no sistema.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 16),
              ),
            ),
          );
        }

        if (table.status == 'livre') {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: Text(
                'MESA ${widget.tableNumber.padLeft(2, '0')}',
                style: GoogleFonts.shareTechMono(color: AppColors.textMain, fontWeight: FontWeight.bold),
              ),
              backgroundColor: AppColors.surface,
              elevation: 0,
            ),
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.surfaceLight, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonGreen.withValues(alpha: 0.05),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.table_bar_outlined,
                            size: 80,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'MESA DISPONÍVEL',
                          style: GoogleFonts.shareTechMono(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Esta mesa está atualmente livre e não possui nenhuma comanda ativa aberta.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textMuted, fontSize: 14, height: 1.5),
                        ),
                        const SizedBox(height: 36),
                        NeonButton(
                          text: 'INICIAR ATENDIMENTO',
                          onTap: () => _ensureLoggedIn(context, () async {
                            await ref.read(tableFsmProvider.notifier).openTable(table);
                            await ref.read(orderFsmProvider.notifier).openOrder(table.id);
                          }),
                          isFullWidth: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        // Table is occupied or closing. Fetch active order
        final activeOrderAsync = ref.watch(activeOrderForTableProvider(table.id));

        return activeOrderAsync.when(
          data: (order) {
            if (order == null) {
              return Scaffold(
                backgroundColor: AppColors.background,
                body: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final orderItemsAsync = ref.watch(orderItemsProvider(order.id));
            final productsAsync = ref.watch(activeProductsStreamProvider);

            return orderItemsAsync.when(
              data: (items) {
                return productsAsync.when(
                  data: (products) {
                    // Map local list of items to match details
                    final List<Map<String, dynamic>> preparingList = [];
                    final List<Map<String, dynamic>> deliveredList = [];

                    for (final item in items) {
                      final product = products.firstWhere(
                        (p) => p.id == item.productId,
                        orElse: () => Product(
                          id: item.productId,
                          categoryId: '',
                          name: 'Produto Desconhecido',
                          price: item.unitPrice,
                          minStock: 0,
                          isActive: true,
                          updatedAt: 0,
                        ),
                      );

                      final mappedItem = {
                        'productId': product.id,
                        'name': product.name,
                        'quantity': item.quantity.toInt(),
                        'price': item.unitPrice,
                      };

                      if (item.status == 'entregue' || item.status == 'entregando') {
                        deliveredList.add(mappedItem);
                      } else {
                        preparingList.add(mappedItem);
                      }
                    }

                    // Compute values
                    double subtotal = 0;
                    for (var i in [...preparingList, ...deliveredList]) {
                      subtotal += (i['price'] as double) * (i['quantity'] as int);
                    }
                    double serviceTax = subtotal * 0.10;
                    double total = subtotal + serviceTax;
                    double remaining = total - _paidAmount;

                    return Scaffold(
                      backgroundColor: AppColors.background,
                      appBar: AppBar(
                        title: Text(
                          'COMANDA MESA ${widget.tableNumber.padLeft(2, '0')}',
                          style: GoogleFonts.shareTechMono(color: AppColors.textMain, fontWeight: FontWeight.bold),
                        ),
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
                            remainingAmount: remaining,
                          ),
                          Expanded(
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 800),
                                child: ListView(
                                  padding: const EdgeInsets.all(24),
                                  children: [
                                    if (_paidAmount > 0) ...[
                                      AppInfoCard(
                                        borderColor: AppColors.neonGreen.withValues(alpha: 0.3),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Total já pago:',
                                              style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              'R\$ ${_paidAmount.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                color: AppColors.neonGreen,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                    ],
                                    if (preparingList.isNotEmpty) ...[
                                      const AppSectionHeader(
                                        icon: Icons.hourglass_empty,
                                        title: 'ITENS EM PREPARO',
                                        color: AppColors.warning,
                                      ),
                                      const SizedBox(height: 12),
                                      ListView.separated(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: preparingList.length,
                                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                                        itemBuilder: (_, i) => OrderItemTile(
                                          name: preparingList[i]['name'],
                                          qty: preparingList[i]['quantity'],
                                          price: preparingList[i]['price'],
                                          statusText: 'Cozinha',
                                          statusColor: AppColors.warning,
                                        ),
                                      ),
                                      const SizedBox(height: 32),
                                    ],
                                    if (deliveredList.isNotEmpty) ...[
                                      const AppSectionHeader(
                                        icon: Icons.check_circle_outline,
                                        title: 'ITENS ENTREGUES',
                                        color: AppColors.neonGreen,
                                      ),
                                      const SizedBox(height: 12),
                                      ListView.separated(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: deliveredList.length,
                                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                                        itemBuilder: (_, i) => OrderItemTile(
                                          name: deliveredList[i]['name'],
                                          qty: deliveredList[i]['quantity'],
                                          price: deliveredList[i]['price'],
                                          statusText: 'Entregue',
                                          statusColor: AppColors.neonGreen,
                                        ),
                                      ),
                                    ],
                                    if (preparingList.isEmpty && deliveredList.isEmpty)
                                      const AppEmptyState(
                                        icon: Icons.receipt_long_outlined,
                                        title: 'Comanda Vazia',
                                        subtitle: 'Toque em "Adicionar Itens" para registrar pedidos.',
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      bottomNavigationBar: AppBottomActionBar(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subtotal', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                              Text('R\$ ${subtotal.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.textMain, fontSize: 14)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Taxa de Serviço (10%)', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                              Text('R\$ ${serviceTax.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.textMain, fontSize: 14)),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Saldo Restante',
                                style: GoogleFonts.shareTechMono(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'R\$ ${remaining.toStringAsFixed(2)}',
                                style: const TextStyle(color: AppColors.neonGreen, fontSize: 22, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.print_outlined, color: AppColors.neonGreen, size: 16),
                                  label: const Text(
                                    'IMPRIMIR',
                                    style: TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  onPressed: () {
                                    final printerState = ref.read(printerProvider);
                                    showDialog(
                                      context: context,
                                      builder: (_) => ThermalReceiptPreview(
                                        tableNumber: widget.tableNumber,
                                        preparingItems: preparingList,
                                        deliveredItems: deliveredList,
                                        subtotal: subtotal,
                                        serviceTax: serviceTax,
                                        total: total,
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
                                  label: const Text(
                                    'WHATSAPP',
                                    style: TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  onPressed: () => WhatsappShareDialog.show(
                                    context,
                                    tableNumber: widget.tableNumber,
                                    preparingItems: preparingList,
                                    deliveredItems: deliveredList,
                                    subtotal: subtotal,
                                    serviceTax: serviceTax,
                                    total: total,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.neonGreen),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _ensureLoggedIn(context, () => _showAddProductDialog(context, order.id)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.neonGreen),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text(
                                    'ADICIONAR ITENS',
                                    style: TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: NeonButton(
                                  text: table.status == 'ocupada' ? 'SOLICITAR CONTA' : 'COBRAR MESA',
                                  onTap: () => _ensureLoggedIn(context, () async {
                                    if (table.status == 'ocupada') {
                                      // Transition to billing status
                                      await ref.read(orderFsmProvider.notifier).requestOrderBill(
                                            orderId: order.id,
                                            table: table,
                                          );
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Fechamento solicitado! Mesa em estado de conta.'),
                                            backgroundColor: AppColors.warning,
                                          ),
                                        );
                                      }
                                    } else {
                                      _showPaymentModal(
                                        context,
                                        order.id,
                                        table,
                                        preparingList,
                                        deliveredList,
                                        remaining,
                                      );
                                    }
                                  }),
                                  isFullWidth: false,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Erro ao carregar produtos: $err', style: const TextStyle(color: Colors.red))),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Erro ao carregar comanda: $err', style: const TextStyle(color: Colors.red))),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Erro ao carregar pedido: $err', style: const TextStyle(color: Colors.red))),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Scaffold(
        body: Center(child: Text('Erro ao carregar mesas: $err', style: const TextStyle(color: Colors.red))),
      ),
    );
  }
}
