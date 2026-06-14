import 'package:flutter/material.dart';
import '../colors.dart';
import '../spacing.dart';

class KitchenOrderCard extends StatelessWidget {
  final String orderId;
  final String tableNumber;
  final String timeElapsed;
  final List<String> items;
  final VoidCallback onComplete;

  const KitchenOrderCard({
    super.key,
    required this.orderId,
    required this.tableNumber,
    required this.timeElapsed,
    required this.items,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: const BoxDecoration(
              color: AppColors.surfaceHighlightDark,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.md)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mesa $tableNumber',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 16, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text(
                      timeElapsed,
                      style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: ElevatedButton(
              onPressed: onComplete,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
              child: const Text('PRONTO'),
            ),
          )
        ],
      ),
    );
  }
}
