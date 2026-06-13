import 'package:flutter/material.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/shared/presentation/components/app_status_badge.dart';

/// Header fixo da tela de comanda com número da mesa,
/// subtitle de status e badge ABERTO/PAGO.
class OrderHeaderCard extends StatelessWidget {
  final String tableNumber;
  final double remainingAmount;

  const OrderHeaderCard({
    super.key,
    required this.tableNumber,
    required this.remainingAmount,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOpen = remainingAmount > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.surfaceLight, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mesa $tableNumber',
                style: const TextStyle(
                  color: AppColors.textMain,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Atendimento ativo',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ],
          ),
          AppOpenClosedBadge(isOpen: isOpen),
        ],
      ),
    );
  }
}
