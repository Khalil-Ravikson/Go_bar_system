import 'package:flutter/material.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/features/crm/application/customers_provider.dart';

/// Linha de botões de método de pagamento (PIX, Cartão, Dinheiro, Fiado).
/// Reutilizada pelas 3 abas do PaymentModal.
class PaymentActionButtons extends StatelessWidget {
  final double totalToPay;
  final List<Map<String, dynamic>> itemsPaid;
  final Customer? selectedCustomer;
  final void Function(double, String, List<Map<String, dynamic>>) onConfirm;

  const PaymentActionButtons({
    super.key,
    required this.totalToPay,
    required this.itemsPaid,
    required this.selectedCustomer,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final bool disabled = totalToPay <= 0.01;

    return Row(
      children: [
        _btn(icon: Icons.pix, label: 'PIX',
            onTap: disabled ? null : () => onConfirm(totalToPay, 'PIX', itemsPaid)),
        const SizedBox(width: 8),
        _btn(icon: Icons.credit_card, label: 'Cartão',
            onTap: disabled ? null : () => onConfirm(totalToPay, 'Cartão', itemsPaid)),
        const SizedBox(width: 8),
        _btn(icon: Icons.payments_outlined, label: 'Dinheiro',
            onTap: disabled ? null : () => onConfirm(totalToPay, 'Dinheiro', itemsPaid)),
        if (selectedCustomer != null) ...[
          const SizedBox(width: 8),
          _btn(icon: Icons.assignment_late_outlined, label: 'Fiado',
              onTap: disabled ? null : () => onConfirm(totalToPay, 'Lançar na Conta', itemsPaid)),
        ],
      ],
    );
  }

  Widget _btn({required IconData icon, required String label, required VoidCallback? onTap}) {
    final bool blocked = onTap == null;
    return Expanded(
      child: Opacity(
        opacity: blocked ? 0.4 : 1.0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: blocked ? Colors.transparent : AppColors.neonGreen.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(icon, color: blocked ? AppColors.textMuted : AppColors.neonGreen, size: 22),
                const SizedBox(height: 4),
                Text(label,
                    style: TextStyle(
                      color: blocked ? AppColors.textMuted : AppColors.textMain,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
