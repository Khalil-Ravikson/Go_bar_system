import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/shared/presentation/components/neon_button.dart';
import 'package:automacao_bar/features/auth/application/auth_provider.dart';
import 'package:automacao_bar/features/cash_register/application/cash_register_provider.dart';
import 'package:automacao_bar/features/receipt/application/receipt_service.dart';
import 'package:automacao_bar/features/printer/application/printer_provider.dart';
import 'package:automacao_bar/features/printer/presentation/widgets/thermal_receipt_preview.dart';
import 'package:automacao_bar/features/crm/application/customers_provider.dart';
import 'package:automacao_bar/features/rh/application/shift_provider.dart';
import 'package:automacao_bar/features/inventory/application/inventory_provider.dart';

class TableDetailsScreen extends ConsumerStatefulWidget {
  final String tableNumber;

  const TableDetailsScreen({
    super.key,
    this.tableNumber = '04', // Default table number if not supplied
  });

  @override
  ConsumerState<TableDetailsScreen> createState() => _TableDetailsScreenState();
}

class _TableDetailsScreenState extends ConsumerState<TableDetailsScreen> {
  // Mutable lists for order items initialized in initState
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

  double get _subtotal {
    double sum = 0;
    for (var item in _preparingItems) {
      sum += (item['price'] as double) * (item['quantity'] as int);
    }
    for (var item in _deliveredItems) {
      sum += (item['price'] as double) * (item['quantity'] as int);
    }
    return sum;
  }

  double get _serviceTax => _subtotal * 0.10;
  double get _total => _subtotal + _serviceTax;
  double get _remainingAmount => _total - _paidAmount;

  void _showPaymentModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return AppPaymentModal(
          remainingAmount: _remainingAmount,
          preparingItems: _preparingItems,
          deliveredItems: _deliveredItems,
          onPay: (amount, method, paidItems) {
            _processPayment(amount, method, paidItems);
          },
        );
      },
    );
  }

  void _processPayment(double amountPaid, String method, List<Map<String, dynamic>> paidItems) {
    final session = ref.read(authProvider);
    if (session == null) return;
    final cashState = ref.read(cashRegisterProvider);
    
    // Register the cash transaction in the shift drawer if payment is Cash (Dinheiro)
    if (method == 'Dinheiro' && cashState.isOpen) {
      ref.read(cashRegisterProvider.notifier).addTransaction(
        amount: amountPaid,
        type: CashTransactionType.venda,
        reason: 'Venda Mesa ${widget.tableNumber} (Divisão)',
        user: session.name,
      );
    }

    // Register debt to customer if method is "Lançar na Conta"
    if (method == 'Lançar na Conta') {
      final customer = ref.read(selectedCustomerProvider);
      if (customer != null) {
        ref.read(customersProvider.notifier).chargeDebt(customer.id, amountPaid);
      }
    }

    // Accumulate sale inside waiter shift
    ref.read(shiftProvider.notifier).addSale(amountPaid);

    // Decrement stock levels of ingredients
    if (paidItems.isNotEmpty) {
      ref.read(inventoryProvider.notifier).decrementStockForItems(paidItems);
    } else {
      // It's a payment of a cota or entire remaining amount. If final payment, decrement remaining items
      final double totalRemaining = _total - _paidAmount;
      if (amountPaid >= totalRemaining - 0.05) {
        final allRemainingItems = [..._preparingItems, ..._deliveredItems];
        ref.read(inventoryProvider.notifier).decrementStockForItems(allRemainingItems);
      }
    }

    setState(() {
      _paidAmount += amountPaid;

      // Update quantities/items if it was paid by item
      if (paidItems.isNotEmpty) {
        for (var paidItem in paidItems) {
          final name = paidItem['name'] as String;
          final qtyPaid = paidItem['quantity'] as int;

          // Check preparing items first
          for (int i = 0; i < _preparingItems.length; i++) {
            if (_preparingItems[i]['name'] == name) {
              final currentQty = _preparingItems[i]['quantity'] as int;
              if (currentQty <= qtyPaid) {
                _preparingItems.removeAt(i);
              } else {
                _preparingItems[i]['quantity'] = currentQty - qtyPaid;
              }
              break;
            }
          }

          // Check delivered items
          for (int i = 0; i < _deliveredItems.length; i++) {
            if (_deliveredItems[i]['name'] == name) {
              final currentQty = _deliveredItems[i]['quantity'] as int;
              if (currentQty <= qtyPaid) {
                _deliveredItems.removeAt(i);
              } else {
                _deliveredItems[i]['quantity'] = currentQty - qtyPaid;
              }
              break;
            }
          }
        }
      }
    });

    // Check if fully paid (or close due to rounding)
    if (_remainingAmount <= 0.05) {
      setState(() {
        _preparingItems.clear();
        _deliveredItems.clear();
      });
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.neonGreen),
              SizedBox(width: 10),
              Text('Conta Totalmente Paga', style: TextStyle(color: AppColors.textMain)),
            ],
          ),
          content: Text(
            'A comanda da Mesa ${widget.tableNumber} foi liquidada com sucesso via $method!\n\nValor Final: R\$ ${_total.toStringAsFixed(2)}',
            style: const TextStyle(color: AppColors.textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                context.go('/home/pdv'); // Go back to POS
              },
              child: const Text(
                'Voltar ao Início',
                style: TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    } else {
      // Partial payment feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pagamento parcial de R\$ ${amountPaid.toStringAsFixed(2)} via $method confirmado!',
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.neonGreen,
        ),
      );
    }
  }

  void _printReceiptPreview() {
    final printerState = ref.read(printerProvider);
    showDialog(
      context: context,
      builder: (context) => ThermalReceiptPreview(
        tableNumber: widget.tableNumber,
        preparingItems: _preparingItems,
        deliveredItems: _deliveredItems,
        subtotal: _subtotal,
        serviceTax: _serviceTax,
        total: _total,
        paperWidth: printerState.paperWidth,
      ),
    );
  }

  void _promptWhatsAppShare() {
    final phoneController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Enviar Recibo Digital', style: TextStyle(color: AppColors.textMain)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Gostaria de enviar o cupom de fechamento para o WhatsApp do cliente?',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: AppColors.textMain),
              decoration: const InputDecoration(
                labelText: 'Telefone do Cliente (DDD + Número)',
                labelStyle: TextStyle(color: AppColors.textMuted),
                hintText: 'Ex: 11999998888',
                hintStyle: TextStyle(color: AppColors.textMuted),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceLight)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neonGreen)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              final phone = phoneController.text;
              final text = ReceiptService.formatReceiptText(
                tableNumber: widget.tableNumber,
                preparingItems: _preparingItems,
                deliveredItems: _deliveredItems,
                subtotal: _subtotal,
                serviceTax: _serviceTax,
                total: _total,
              );
              
              ReceiptService.shareToWhatsApp(phone: phone, text: text);
              Navigator.of(context).pop();
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Abrindo o WhatsApp...',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: AppColors.neonGreen,
                ),
              );
            },
            child: const Text('Compartilhar', style: TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Comanda Mesa ${widget.tableNumber}',
          style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code, color: AppColors.neonGreen),
            tooltip: 'Gerar QR Cardápio',
            onPressed: () => _showQrMenuDialog(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header info card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                bottom: BorderSide(color: AppColors.surfaceLight, width: 1.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mesa ${widget.tableNumber}',
                      style: const TextStyle(
                        color: AppColors.textMain,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Atendimento ativo • Simulação',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _remainingAmount > 0 
                        ? AppColors.neonGreen.withValues(alpha: 0.15)
                        : Colors.blue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _remainingAmount > 0 ? AppColors.neonGreen : Colors.blue, 
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _remainingAmount > 0 ? 'ABERTO' : 'PAGO',
                    style: TextStyle(
                      color: _remainingAmount > 0 ? AppColors.neonGreen : Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Lists Body
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Paid indicators if partial payments took place
                    if (_paidAmount > 0) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.3)),
                        ),
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
                    ],

                    // Section 1: Items Preparing
                    if (_preparingItems.isNotEmpty) ...[
                      _buildSectionHeader('Itens em Preparo', Icons.hourglass_empty, AppColors.warning),
                      const SizedBox(height: 12),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _preparingItems.length,
                        separatorBuilder: (context, idx) => const SizedBox(height: 12),
                        itemBuilder: (context, idx) {
                          final item = _preparingItems[idx];
                          return _buildOrderListItem(
                            name: item['name'] as String,
                            qty: item['quantity'] as int,
                            price: item['price'] as double,
                            statusText: 'Cozinha',
                            statusColor: AppColors.warning,
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Section 2: Items Delivered
                    if (_deliveredItems.isNotEmpty) ...[
                      _buildSectionHeader('Itens Entregues', Icons.check_circle_outline, AppColors.neonGreen),
                      const SizedBox(height: 12),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _deliveredItems.length,
                        separatorBuilder: (context, idx) => const SizedBox(height: 12),
                        itemBuilder: (context, idx) {
                          final item = _deliveredItems[idx];
                          return _buildOrderListItem(
                            name: item['name'] as String,
                            qty: item['quantity'] as int,
                            price: item['price'] as double,
                            statusText: 'Entregue',
                            statusColor: AppColors.neonGreen,
                          );
                        },
                      ),
                    ],

                    if (_preparingItems.isEmpty && _deliveredItems.isEmpty) ...[
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 48.0),
                          child: Text(
                            'Nenhum item restante nesta comanda.',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Total & Actions Footer
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.surfaceLight, width: 1.5),
              ),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Subtotal',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                        ),
                        Text(
                          'R\$ ${_subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(color: AppColors.textMain, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Taxa de Serviço (10%)',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                        ),
                        Text(
                          'R\$ ${_serviceTax.toStringAsFixed(2)}',
                          style: const TextStyle(color: AppColors.textMain, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Saldo Devedor Restante',
                          style: TextStyle(
                            color: AppColors.textMain,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'R\$ ${_remainingAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.neonGreen,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Receipt Share & Print Row
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.print_outlined, color: AppColors.neonGreen, size: 18),
                            label: const Text('IMPRIMIR VIA', style: TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold, fontSize: 13)),
                            onPressed: () => _printReceiptPreview(),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.neonGreen, width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.share, color: AppColors.neonGreen, size: 18),
                            label: const Text('WHATSAPP', style: TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold, fontSize: 13)),
                            onPressed: () => _promptWhatsAppShare(),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.neonGreen, width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Buttons Row
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => context.go('/pos'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(
                                  color: AppColors.neonGreen,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            child: const Text(
                              'ADICIONAR MAIS ITENS',
                              style: TextStyle(
                                color: AppColors.neonGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: NeonButton(
                            text: 'COBRAR MESA',
                            onTap: _remainingAmount > 0 ? _showPaymentModal : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderListItem({
    required String name,
    required int qty,
    required double price,
    required String statusText,
    required Color statusColor,
  }) {
    final itemTotal = price * qty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${qty}x',
              style: const TextStyle(
                color: AppColors.neonGreen,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'R\$ ${price.toStringAsFixed(2)} unid.',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'R\$ ${itemTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.textMain,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showQrMenuDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'QR Cardápio - Mesa ${widget.tableNumber}',
            style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Escaneie o QR Code abaixo para acessar o cardápio digital desta mesa.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                width: 180,
                height: 180,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.3), width: 2),
                ),
                child: CustomPaint(
                  size: const Size(164, 164),
                  painter: QrCodeMockPainter(),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Acesse: gobar.app/cardapio/mesa${widget.tableNumber}',
                style: const TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('FECHAR', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Dedicated Stateful Widget for the tabbed Payment Splitter
class AppPaymentModal extends ConsumerStatefulWidget {
  final double remainingAmount;
  final List<Map<String, dynamic>> preparingItems;
  final List<Map<String, dynamic>> deliveredItems;
  final Function(double amount, String method, List<Map<String, dynamic>> paidItems) onPay;

  const AppPaymentModal({
    super.key,
    required this.remainingAmount,
    required this.preparingItems,
    required this.deliveredItems,
    required this.onPay,
  });

  @override
  ConsumerState<AppPaymentModal> createState() => _AppPaymentModalState();
}

class _AppPaymentModalState extends ConsumerState<AppPaymentModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Tab 2: Equal Split state
  int _numberOfPeople = 2;
  int _selectedShares = 1;

  // Tab 3: Pay by Item state
  // Key: Item Name, Value: Quantity selected to pay
  final Map<String, int> _selectedQuantities = {};

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

  double get _splitShareValue => widget.remainingAmount / _numberOfPeople;
  double get _splitTotalToPay => _splitShareValue * _selectedShares;

  // Helper to fetch item price by name
  double _getItemPrice(String name) {
    for (var item in widget.preparingItems) {
      if (item['name'] == name) return item['price'] as double;
    }
    for (var item in widget.deliveredItems) {
      if (item['name'] == name) return item['price'] as double;
    }
    return 0.0;
  }

  double get _itemsSubtotal {
    double total = 0.0;
    _selectedQuantities.forEach((name, qty) {
      total += _getItemPrice(name) * qty;
    });
    return total;
  }

  double get _itemsServiceTax => _itemsSubtotal * 0.10;
  double get _itemsTotalToPay => _itemsSubtotal + _itemsServiceTax;

  void _confirmPayment(double amount, String method, List<Map<String, dynamic>> itemsList) {
    Navigator.of(context).pop(); // Close bottom sheet
    widget.onPay(amount, method, itemsList);
  }

  @override
  Widget build(BuildContext context) {
    final cashState = ref.watch(cashRegisterProvider);

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
          // Header Drag Handle
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
          
          // Drawer Warning if Cash Register is closed
          if (!cashState.isOpen) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.danger, width: 1),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Aviso: O Caixa de Turno está FECHADO. Recebimentos em Dinheiro não atualizarão a gaveta!',
                      style: TextStyle(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],

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
                // ABA 1: PAGAR TOTAL
                _buildTotalTab(),

                // ABA 2: DIVIDIR POR IGUAL
                _buildEqualSplitTab(),

                // ABA 3: PAGAR POR ITEM
                _buildPayByItemTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ABA 1 Layout
  Widget _buildTotalTab() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Liquidamento Integral',
            style: TextStyle(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Receber o valor total restante da mesa de uma única vez.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 32),
          
          // Total Amount Display
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.1), width: 1.5),
            ),
            child: Column(
              children: [
                const Text('SALDO RESTANTE A PAGAR', style: TextStyle(color: AppColors.textMuted, fontSize: 11, letterSpacing: 1.2)),
                const SizedBox(height: 8),
                Text(
                  'R\$ ${widget.remainingAmount.toStringAsFixed(2)}',
                  style: const TextStyle(color: AppColors.neonGreen, fontSize: 32, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          const Spacer(),
          _buildPaymentActionButtons(widget.remainingAmount, []),
        ],
      ),
    );
  }

  // ABA 2 Layout
  Widget _buildEqualSplitTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Divisão Igualitária',
            style: TextStyle(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Divida o saldo em partes iguais e pague uma ou mais cotas.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 24),

          // Number of people controls
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text('NÚMERO DE PESSOAS', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: AppColors.neonGreen, size: 32),
                      onPressed: _numberOfPeople > 2
                          ? () {
                              setState(() {
                                _numberOfPeople--;
                                if (_selectedShares > _numberOfPeople) {
                                  _selectedShares = _numberOfPeople;
                                }
                              });
                            }
                          : null,
                    ),
                    const SizedBox(width: 24),
                    Text(
                      '$_numberOfPeople',
                      style: const TextStyle(color: AppColors.textMain, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 24),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: AppColors.neonGreen, size: 32),
                      onPressed: () {
                        setState(() {
                          _numberOfPeople++;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Counter of shares to pay
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text('COTAS A PAGAR AGORA', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, color: AppColors.textMain),
                      onPressed: _selectedShares > 1
                          ? () {
                              setState(() {
                                _selectedShares--;
                              });
                            }
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '$_selectedShares de $_numberOfPeople cota(s)',
                      style: const TextStyle(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.add, color: AppColors.textMain),
                      onPressed: _selectedShares < _numberOfPeople
                          ? () {
                              setState(() {
                                _selectedShares++;
                              });
                            }
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Breakdown calculations card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.1), width: 1.5),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Valor por Cota (1/$_numberOfPeople)', style: const TextStyle(color: AppColors.textMuted)),
                    Text(
                      'R\$ ${_splitShareValue.toStringAsFixed(2)}',
                      style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('TOTAL DA COBRANÇA', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                    Text(
                      'R\$ ${_splitTotalToPay.toStringAsFixed(2)}',
                      style: const TextStyle(color: AppColors.neonGreen, fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildPaymentActionButtons(_splitTotalToPay, []),
        ],
      ),
    );
  }

  // ABA 3 Layout
  Widget _buildPayByItemTab() {
    final allItems = [...widget.preparingItems, ...widget.deliveredItems];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Cobrança Selecionada por Item',
            style: TextStyle(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Escolha a quantidade de cada produto que será paga nesta rodada.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 16),

          // Items Selection List
          Expanded(
            child: allItems.isEmpty
                ? const Center(child: Text('Nenhum item disponível.', style: TextStyle(color: AppColors.textMuted)))
                : ListView.separated(
                    itemCount: allItems.length,
                    separatorBuilder: (context, idx) => const Divider(color: AppColors.surfaceLight),
                    itemBuilder: (context, idx) {
                      final item = allItems[idx];
                      final name = item['name'] as String;
                      final maxQty = item['quantity'] as int;
                      final price = item['price'] as double;
                      final selectedQty = _selectedQuantities[name] ?? 0;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w600, fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text('R\$ ${price.toStringAsFixed(2)} unid (max: ${maxQty}x)', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                ],
                              ),
                            ),
                            
                            // Counter controls
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, color: AppColors.textMuted, size: 18),
                                  onPressed: selectedQty > 0
                                      ? () {
                                          setState(() {
                                            if (selectedQty == 1) {
                                              _selectedQuantities.remove(name);
                                            } else {
                                              _selectedQuantities[name] = selectedQty - 1;
                                            }
                                          });
                                        }
                                      : null,
                                ),
                                Container(
                                  width: 30,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$selectedQty',
                                    style: TextStyle(
                                      color: selectedQty > 0 ? AppColors.neonGreen : AppColors.textMuted,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, color: AppColors.neonGreen, size: 18),
                                  onPressed: selectedQty < maxQty
                                      ? () {
                                          setState(() {
                                            _selectedQuantities[name] = selectedQty + 1;
                                          });
                                        }
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
          const SizedBox(height: 16),

          // Total Items Billing display card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.05)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal dos Itens', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                    Text('R\$ ${_itemsSubtotal.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.textMain, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Taxa de Serviço (10%)', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                    Text('R\$ ${_itemsServiceTax.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.textMain, fontSize: 13)),
                  ],
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('TOTAL DA SELEÇÃO', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(
                      'R\$ ${_itemsTotalToPay.toStringAsFixed(2)}',
                      style: const TextStyle(color: AppColors.neonGreen, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _buildPaymentActionButtons(
            _itemsTotalToPay,
            _selectedQuantities.entries
                .map((e) => {'name': e.key, 'quantity': e.value})
                .toList(),
          ),
        ],
      ),
    );
  }

  // Row of actions (PIX, Cartão, Dinheiro, Fiado)
  Widget _buildPaymentActionButtons(double totalToPay, List<Map<String, dynamic>> itemsPaid) {
    final disabled = totalToPay <= 0.01;
    final selectedCustomer = ref.watch(selectedCustomerProvider);

    return Row(
      children: [
        // PIX Button
        Expanded(
          child: _buildIconButton(
            icon: Icons.pix,
            label: 'PIX',
            onTap: disabled ? null : () => _confirmPayment(totalToPay, 'PIX', itemsPaid),
          ),
        ),
        const SizedBox(width: 8),
        
        // Card Button
        Expanded(
          child: _buildIconButton(
            icon: Icons.credit_card,
            label: 'Cartão',
            onTap: disabled ? null : () => _confirmPayment(totalToPay, 'Cartão', itemsPaid),
          ),
        ),
        const SizedBox(width: 8),
        
        // Cash Button
        Expanded(
          child: _buildIconButton(
            icon: Icons.payments_outlined,
            label: 'Dinheiro',
            onTap: disabled ? null : () => _confirmPayment(totalToPay, 'Dinheiro', itemsPaid),
          ),
        ),
        if (selectedCustomer != null) ...[
          const SizedBox(width: 8),
          // Fiado Button
          Expanded(
            child: _buildIconButton(
              icon: Icons.assignment_late_outlined,
              label: 'Fiado',
              onTap: disabled ? null : () => _confirmPayment(totalToPay, 'Lançar na Conta', itemsPaid),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    final isBlocked = onTap == null;

    return Opacity(
      opacity: isBlocked ? 0.4 : 1.0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isBlocked ? Colors.transparent : AppColors.neonGreen.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: isBlocked ? AppColors.textMuted : AppColors.neonGreen, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isBlocked ? AppColors.textMuted : AppColors.textMain,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QrCodeMockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.neonGreen;
    final bgPaint = Paint()..color = Colors.black87;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final pixelSize = size.width / 15;

    // Draw corner finder patterns
    void drawFinder(double x, double y) {
      canvas.drawRect(Rect.fromLTWH(x, y, pixelSize * 5, pixelSize * 5), paint);
      canvas.drawRect(Rect.fromLTWH(x + pixelSize, y + pixelSize, pixelSize * 3, pixelSize * 3), bgPaint);
      canvas.drawRect(Rect.fromLTWH(x + pixelSize * 2, y + pixelSize * 2, pixelSize, pixelSize), paint);
    }

    drawFinder(0, 0);
    drawFinder(size.width - pixelSize * 5, 0);
    drawFinder(0, size.height - pixelSize * 5);

    // Draw some random qr matrix pixels
    final randomPixels = [
      [2, 7], [3, 7], [4, 7], [7, 2], [7, 3], [7, 4],
      [10, 10], [10, 11], [10, 12], [11, 10], [12, 10],
      [8, 8], [9, 9], [6, 12], [12, 6], [14, 14], [13, 14],
      [8, 14], [14, 8], [7, 7], [7, 8], [8, 7], [9, 6], [6, 9]
    ];

    for (var pix in randomPixels) {
      canvas.drawRect(
        Rect.fromLTWH(pix[0] * pixelSize, pix[1] * pixelSize, pixelSize, pixelSize),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
