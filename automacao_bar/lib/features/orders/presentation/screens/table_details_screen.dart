import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/shared/presentation/components/neon_button.dart';

class TableDetailsScreen extends StatefulWidget {
  final String tableNumber;

  const TableDetailsScreen({
    super.key,
    this.tableNumber = '04', // Default table number if not supplied
  });

  @override
  State<TableDetailsScreen> createState() => _TableDetailsScreenState();
}

class _TableDetailsScreenState extends State<TableDetailsScreen> {
  // Mock items list divided into preparing and delivered
  final List<Map<String, dynamic>> _preparingItems = [
    {'name': 'Gin Tônica Tropical', 'quantity': 1, 'price': 24.90},
    {'name': 'Caipirinha de Limão', 'quantity': 1, 'price': 15.00},
  ];

  final List<Map<String, dynamic>> _deliveredItems = [
    {'name': 'Chopp Brahma 300ml', 'quantity': 3, 'price': 9.90},
    {'name': 'Heineken Long Neck', 'quantity': 2, 'price': 12.00},
    {'name': 'Porção de Batatas Fritas', 'quantity': 1, 'price': 28.00},
  ];

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

  void _showPaymentModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Fechar Conta',
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
              const SizedBox(height: 12),
              const Text(
                'Selecione a forma de pagamento preferida pelo cliente.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
              const SizedBox(height: 24),
              
              // Total billing display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Valor Total a Pagar',
                      style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'R\$ ${_total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.neonGreen,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Payment options
              _buildPaymentOption(
                icon: Icons.pix,
                title: 'PIX (Instantâneo)',
                subtitle: 'Gera QR Code na tela ou chave copia e cola',
                onTap: () => _finalizePayment('PIX'),
              ),
              const SizedBox(height: 12),
              _buildPaymentOption(
                icon: Icons.credit_card,
                title: 'Cartão de Crédito/Débito',
                subtitle: 'Aproxime ou insira o cartão na maquininha',
                onTap: () => _finalizePayment('Cartão'),
              ),
              const SizedBox(height: 12),
              _buildPaymentOption(
                icon: Icons.payments_outlined,
                title: 'Dinheiro físico',
                subtitle: 'Informe o troco recebido no caixa',
                onTap: () => _finalizePayment('Dinheiro'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.surfaceLight, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.neonGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.neonGreen, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textMain,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  void _finalizePayment(String method) {
    Navigator.of(context).pop(); // Close bottom sheet
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Pagamento Confirmado', style: TextStyle(color: AppColors.textMain)),
        content: Text(
          'A conta da Mesa ${widget.tableNumber} foi fechada com sucesso via $method!\nComanda finalizada.',
          style: const TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              context.go('/pos'); // Go back to POS
            },
            child: const Text(
              'Voltar ao Início',
              style: TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold),
            ),
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
        title: Text('Comanda Mesa ${widget.tableNumber}'),
        backgroundColor: AppColors.surface,
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
                      'Atendimento ativo há 1h 14m',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.neonGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.neonGreen, width: 1),
                  ),
                  child: const Text(
                    'ABERTO',
                    style: TextStyle(
                      color: AppColors.neonGreen,
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
                          'Total Parcial',
                          style: TextStyle(
                            color: AppColors.textMain,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'R\$ ${_total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.neonGreen,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
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
                            text: 'FECHAR CONTA',
                            onTap: _showPaymentModal,
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
}
