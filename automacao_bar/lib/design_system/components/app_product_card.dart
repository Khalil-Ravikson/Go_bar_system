import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';

class AppProductCard extends StatelessWidget {
  final String name;
  final int priceInCents;
  final VoidCallback onTap;
  // Futuro: final String? emojiIcon;

  const AppProductCard({
    super.key,
    required this.name,
    required this.priceInCents,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          // Estética premium sugerida pelo HTML
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryNeon.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                CurrencyFormatter.format(priceInCents),
                style: const TextStyle(
                  color: AppColors.primaryNeon,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}