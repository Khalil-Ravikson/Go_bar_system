import 'package:flutter/material.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/features/receipt/application/receipt_service.dart';

/// Diálogo para partilha do recibo via WhatsApp.
class WhatsappShareDialog extends StatefulWidget {
  final String tableNumber;
  final List<Map<String, dynamic>> preparingItems;
  final List<Map<String, dynamic>> deliveredItems;
  final double subtotal;
  final double serviceTax;
  final double total;

  const WhatsappShareDialog({
    super.key,
    required this.tableNumber,
    required this.preparingItems,
    required this.deliveredItems,
    required this.subtotal,
    required this.serviceTax,
    required this.total,
  });

  static void show(
    BuildContext context, {
    required String tableNumber,
    required List<Map<String, dynamic>> preparingItems,
    required List<Map<String, dynamic>> deliveredItems,
    required double subtotal,
    required double serviceTax,
    required double total,
  }) {
    showDialog(
      context: context,
      builder: (_) => WhatsappShareDialog(
        tableNumber: tableNumber,
        preparingItems: preparingItems,
        deliveredItems: deliveredItems,
        subtotal: subtotal,
        serviceTax: serviceTax,
        total: total,
      ),
    );
  }

  @override
  State<WhatsappShareDialog> createState() => _WhatsappShareDialogState();
}

class _WhatsappShareDialogState extends State<WhatsappShareDialog> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text(
        'Enviar Recibo Digital',
        style: TextStyle(color: AppColors.textMain),
      ),
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
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: AppColors.textMain),
            decoration: const InputDecoration(
              labelText: 'Telefone do Cliente (DDD + Número)',
              labelStyle: TextStyle(color: AppColors.textMuted),
              hintText: 'Ex: 11999998888',
              hintStyle: TextStyle(color: AppColors.textMuted),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.surfaceLight),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.neonGreen),
              ),
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
            final text = ReceiptService.formatReceiptText(
              tableNumber: widget.tableNumber,
              preparingItems: widget.preparingItems,
              deliveredItems: widget.deliveredItems,
              subtotal: widget.subtotal,
              serviceTax: widget.serviceTax,
              total: widget.total,
            );
            ReceiptService.shareToWhatsApp(
              phone: _phoneController.text,
              text: text,
            );
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
          child: const Text(
            'Compartilhar',
            style: TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
