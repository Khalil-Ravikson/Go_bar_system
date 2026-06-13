import 'package:flutter/material.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/features/crm/application/customers_provider.dart';

/// Tile de cliente para a lista do CRM.
class CustomerListTile extends StatelessWidget {
  final Customer customer;
  final VoidCallback onRepay;

  const CustomerListTile({
    super.key,
    required this.customer,
    required this.onRepay,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasDebt = customer.currentBalance > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasDebt
              ? AppColors.danger.withValues(alpha: 0.3)
              : AppColors.surfaceLight,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            backgroundColor: hasDebt
                ? AppColors.danger.withValues(alpha: 0.15)
                : AppColors.neonGreen.withValues(alpha: 0.15),
            child: Text(
              customer.name[0],
              style: TextStyle(
                color: hasDebt ? AppColors.danger : AppColors.neonGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Name + Phone
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name,
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  customer.phone,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),

          // Balance + status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'R\$ ${customer.currentBalance.toStringAsFixed(2)}',
                style: TextStyle(
                  color: hasDebt ? AppColors.danger : AppColors.textMuted,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                hasDebt ? 'Saldo Devedor' : 'Sem débitos',
                style: TextStyle(
                  color: hasDebt
                      ? AppColors.danger.withValues(alpha: 0.7)
                      : AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),

          // Payment action
          IconButton(
            icon: const Icon(Icons.payment, color: AppColors.neonGreen),
            tooltip: 'Amortizar Dívida',
            onPressed: onRepay,
          ),
        ],
      ),
    );
  }
}
