import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// O Enum que define os estados possíveis de uma mesa
enum TableStatus { free, occupied, closing }

class TableCard extends StatelessWidget {
  final String tableNumber;
  final TableStatus status;
  final String infoText;
  final String? valueText; // Ex: Total gasto até agora
  final VoidCallback onTap;

  const TableCard({
    super.key,
    required this.tableNumber,
    required this.status,
    required this.infoText,
    this.valueText,
    required this.onTap,
  });

  // Regras de negócio visuais isoladas do layout
  Color _getStatusColor() {
    switch (status) {
      case TableStatus.free:
        return AppColors.textMuted; // Cinzento
      case TableStatus.occupied:
        return AppColors.primaryNeon; // Verde Neon
      case TableStatus.closing:
        return AppColors.orange; // Laranja Alerta
    }
  }

  Color _getBgColor() {
    switch (status) {
      case TableStatus.free:
        return AppColors.surface;
      case TableStatus.occupied:
        return AppColors.primaryNeon.withOpacity(0.05);
      case TableStatus.closing:
        return AppColors.orange.withOpacity(0.05);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final isFree = status == TableStatus.free;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getBgColor(),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isFree ? AppColors.border : statusColor.withOpacity(0.3),
            width: isFree ? 1 : 1.5,
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'MESA $tableNumber',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isFree ? AppColors.textSecondary : statusColor,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      infoText,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (valueText != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        valueText!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ]
                  ],
                ),
              ],
            ),
            
            // Ponto de Status no canto superior direito
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  boxShadow: isFree ? null : [
                    BoxShadow(
                      color: statusColor.withOpacity(0.5),
                      blurRadius: 6,
                      spreadRadius: 1,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}