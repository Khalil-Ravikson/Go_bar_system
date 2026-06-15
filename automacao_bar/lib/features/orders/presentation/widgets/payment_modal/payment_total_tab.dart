import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/features/crm/application/customers_provider.dart';
import 'payment_action_buttons.dart';

class PaymentTotalTab extends StatefulWidget {
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
  State<PaymentTotalTab> createState() => _PaymentTotalTabState();
}

class _PaymentTotalTabState extends State<PaymentTotalTab> {
  final _amountPaidController = TextEditingController();
  double _amountPaidByCustomer = 0.0;

  @override
  void initState() {
    super.initState();
    _amountPaidController.addListener(() {
      final text = _amountPaidController.text;
      final val = double.tryParse(text.replaceAll(',', '.')) ?? 0.0;
      setState(() {
        _amountPaidByCustomer = val;
      });
    });
  }

  @override
  void dispose() {
    _amountPaidController.dispose();
    super.dispose();
  }

  void _applyQuickCash(double amount) {
    _amountPaidController.text = amount.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final change = _amountPaidByCustomer - widget.remainingAmount;

    return SingleChildScrollView(
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
            'Receber o valor total restante da comanda de uma única vez.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 24),

          // Amount display
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.1)),
            ),
            child: Column(
              children: [
                const Text(
                  'SALDO RESTANTE A PAGAR',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11, letterSpacing: 1.2),
                ),
                const SizedBox(height: 6),
                Text(
                  'R\$ ${widget.remainingAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.neonGreen,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quick change calculator section
          Text(
            'CALCULADORA DE TROCO (DINHEIRO)',
            style: GoogleFonts.shareTechMono(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountPaidController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.robotoMono(color: AppColors.textMain, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: 'Valor Pago pelo Cliente (R\$)',
              labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceLight)),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neonGreen)),
              prefixText: 'R\$ ',
              suffixIcon: _amountPaidController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16, color: AppColors.textMuted),
                      onPressed: () => _amountPaidController.clear(),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [10, 20, 50, 100].map((val) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.surfaceLight),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onPressed: () => _applyQuickCash(val.toDouble()),
                    child: Text(
                      'R\$ $val',
                      style: GoogleFonts.robotoMono(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Next higher bill suggestions (e.g. if bill is 37.50, suggest 50, 100)
          if (widget.remainingAmount > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.remainingAmount < 10)
                  _suggestedBillButton(10.0)
                else if (widget.remainingAmount < 20)
                  _suggestedBillButton(20.0)
                else if (widget.remainingAmount < 50)
                  _suggestedBillButton(50.0)
                else if (widget.remainingAmount < 100)
                  _suggestedBillButton(100.0),
                if (widget.remainingAmount < 50 && widget.remainingAmount > 20) ...[
                  const SizedBox(width: 12),
                  _suggestedBillButton(100.0),
                ]
              ],
            ),
            const SizedBox(height: 16),
          ],

          if (change > 0)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.neonGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Troco a devolver:', style: TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.bold)),
                  Text(
                    'R\$ ${change.toStringAsFixed(2)}',
                    style: GoogleFonts.robotoMono(color: AppColors.neonGreen, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 32),

          PaymentActionButtons(
            totalToPay: widget.remainingAmount,
            itemsPaid: const [],
            selectedCustomer: widget.selectedCustomer,
            onConfirm: widget.onConfirm,
          ),
        ],
      ),
    );
  }

  Widget _suggestedBillButton(double amount) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.neonGreen, width: 0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () => _applyQuickCash(amount),
      child: Text(
        'Pagar com R\$ ${amount.toStringAsFixed(0)}',
        style: GoogleFonts.robotoMono(color: AppColors.neonGreen, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
