import 'package:flutter/material.dart';
import '../colors.dart';
import '../spacing.dart';

class StatusTableCard extends StatelessWidget {
  final String tableNumber;
  final String status; // 'livre', 'ocupada', 'fechando'
  final VoidCallback onTap;
  final double? amount;

  const StatusTableCard({
    super.key,
    required this.tableNumber,
    required this.status,
    required this.onTap,
    this.amount,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'ocupada':
        statusColor = AppColors.warning;
        break;
      case 'fechando':
        statusColor = AppColors.danger;
        break;
      case 'livre':
      default:
        statusColor = AppColors.success;
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: statusColor, width: 4),
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                tableNumber,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (amount != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'R\$ ${amount!.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
