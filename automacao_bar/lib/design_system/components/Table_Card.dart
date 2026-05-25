import 'package:automacao_bar/design_system/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../design_system/colors.dart';

enum TableStatus { open, free, reserved }

class TableCard extends StatelessWidget {
  final String tableNumber;
  final TableStatus status;
  final String infoText;
  final String valueText;
  final String? timerText;
  final VoidCallback onTap;

  const TableCard({
    super.key,
    required this.tableNumber,
    required this.status,
    required this.infoText,
    required this.valueText,
    this.timerText,
    required this.onTap,
  });

  Color _getStatusColor() {
    switch (status) {
      case TableStatus.open:
        return AppColors.neonGreen;
      case TableStatus.free:
        return AppColors.textMuted;
      case TableStatus.reserved:
        return AppColors.orange;
    }
  }

  Color _getBgColor() {
    switch (status) {
      case TableStatus.open:
        return AppColors.neonGreen.withOpacity(0.05);
      case TableStatus.free:
        return AppColors.surface;
      case TableStatus.reserved:
        return AppColors.orange.withOpacity(0.05);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final isFree = status == TableStatus.free;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getBgColor(),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isFree ? AppColors.borderSubtle : statusColor.withOpacity(0.2),
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tableNumber,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isFree ? AppColors.textMuted : statusColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  infoText,
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  valueText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isFree ? AppColors.textMuted : AppColors.textPrimary,
                  ),
                ),
                if (timerText != null) ...[
                  const Spacer(),
                  Text(
                    timerText!,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ]
              ],
            ),
            // Indicador de status (bolinha no canto superior direito)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}