import 'package:flutter/material.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/features/crm/application/customers_provider.dart';
import 'payment_action_buttons.dart';

/// Aba 1 do PaymentModal — liquida o saldo total restante de uma vez.
class PaymentTotalTab extends StatelessWidget {
  final double remainingAmount;
  final Customer? selectedCustomer;
  final void Function(double, String, List<Map<String, dynamic>>) onConfirm;

  const PaymentTotalTab({
    super.key,
    required this.remainingAmount,
    required this.selectedCustomer,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
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

          // Amount display
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.1)),
            ),
            child: Column(
              children: [
                const Text(
                  'SALDO RESTANTE A PAGAR',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11, letterSpacing: 1.2),
                ),
                const SizedBox(height: 8),
                Text(
                  'R\$ ${remainingAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.neonGreen,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),

          PaymentActionButtons(
            totalToPay: remainingAmount,
            itemsPaid: const [],
            selectedCustomer: selectedCustomer,
            onConfirm: onConfirm,
          ),
        ],
      ),
    );
  }
}
