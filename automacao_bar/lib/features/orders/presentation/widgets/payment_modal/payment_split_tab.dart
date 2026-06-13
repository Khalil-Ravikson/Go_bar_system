import 'package:flutter/material.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/features/crm/application/customers_provider.dart';
import 'payment_action_buttons.dart';

/// Aba 2 do PaymentModal — divisão igualitária entre N pessoas.
class PaymentSplitTab extends StatefulWidget {
  final double remainingAmount;
  final Customer? selectedCustomer;
  final void Function(double, String, List<Map<String, dynamic>>) onConfirm;

  const PaymentSplitTab({
    super.key,
    required this.remainingAmount,
    required this.selectedCustomer,
    required this.onConfirm,
  });

  @override
  State<PaymentSplitTab> createState() => _PaymentSplitTabState();
}

class _PaymentSplitTabState extends State<PaymentSplitTab> {
  int _numberOfPeople = 2;
  int _selectedShares = 1;

  double get _shareValue => widget.remainingAmount / _numberOfPeople;
  double get _totalToPay => _shareValue * _selectedShares;

  Widget _counter({
    required String label,
    required int value,
    required String display,
    required VoidCallback? onDecrease,
    required VoidCallback onIncrease,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, letterSpacing: 0.8)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: AppColors.neonGreen, size: 28),
                onPressed: onDecrease,
              ),
              const SizedBox(width: 16),
              Text(display, style: const TextStyle(color: AppColors.textMain, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: AppColors.neonGreen, size: 28),
                onPressed: onIncrease,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Divisão Igualitária',
              style: TextStyle(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Divida o saldo em partes iguais e pague uma ou mais cotas.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
          const SizedBox(height: 24),

          _counter(
            label: 'NÚMERO DE PESSOAS',
            value: _numberOfPeople,
            display: '$_numberOfPeople',
            onDecrease: _numberOfPeople > 2
                ? () => setState(() {
                      _numberOfPeople--;
                      if (_selectedShares > _numberOfPeople) _selectedShares = _numberOfPeople;
                    })
                : null,
            onIncrease: () => setState(() => _numberOfPeople++),
          ),
          const SizedBox(height: 16),

          _counter(
            label: 'COTAS A PAGAR AGORA',
            value: _selectedShares,
            display: '$_selectedShares de $_numberOfPeople cota(s)',
            onDecrease: _selectedShares > 1 ? () => setState(() => _selectedShares--) : null,
            onIncrease: _selectedShares < _numberOfPeople ? () => setState(() => _selectedShares++) : () {},
          ),
          const SizedBox(height: 24),

          // Breakdown card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.1)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Por cota (1/$_numberOfPeople)',
                        style: const TextStyle(color: AppColors.textMuted)),
                    Text('R\$ ${_shareValue.toStringAsFixed(2)}',
                        style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('TOTAL DA COBRANÇA',
                        style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                    Text('R\$ ${_totalToPay.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: AppColors.neonGreen, fontSize: 20, fontWeight: FontWeight.w900)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          PaymentActionButtons(
            totalToPay: _totalToPay,
            itemsPaid: const [],
            selectedCustomer: widget.selectedCustomer,
            onConfirm: widget.onConfirm,
          ),
        ],
      ),
    );
  }
}
