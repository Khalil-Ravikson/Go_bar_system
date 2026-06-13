import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/features/crm/application/customers_provider.dart';

/// Dialog de amortização de dívida do cliente.
class RepayDebtDialog extends ConsumerStatefulWidget {
  final Customer customer;

  const RepayDebtDialog({super.key, required this.customer});

  static void show(BuildContext context, WidgetRef ref, Customer customer) {
    showDialog(
      context: context,
      builder: (_) => RepayDebtDialog(customer: customer),
    );
  }

  @override
  ConsumerState<RepayDebtDialog> createState() => _RepayDebtDialogState();
}

class _RepayDebtDialogState extends ConsumerState<RepayDebtDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Amortizar — ${widget.customer.name}',
        style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Saldo devedor: R\$ ${widget.customer.currentBalance.toStringAsFixed(2)}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: AppColors.textMain),
              decoration: const InputDecoration(
                labelText: 'Valor Pago (R\$)',
                labelStyle: TextStyle(color: AppColors.textMuted),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.surfaceLight)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.neonGreen)),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Informe o valor';
                final n = double.tryParse(val.replaceAll(',', '.'));
                if (n == null || n <= 0) return 'Valor inválido';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCELAR', style: TextStyle(color: AppColors.textMuted)),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final amount = double.parse(_amountController.text.replaceAll(',', '.'));
              ref.read(customersProvider.notifier).payDebt(widget.customer.id, amount);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  'R\$ ${amount.toStringAsFixed(2)} amortizado com sucesso!',
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                backgroundColor: AppColors.neonGreen,
              ));
            }
          },
          child: const Text('CONFIRMAR',
              style: TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
