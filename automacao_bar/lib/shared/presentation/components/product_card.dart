import 'package:flutter/material.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';

class ProductCard extends StatelessWidget {
  final String name;
  final double price;
  final VoidCallback onAdd;
  final bool isHappyHour;
  final bool isSoldOut;

  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    required this.onAdd,
    this.isHappyHour = false,
    this.isSoldOut = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isSoldOut ? 0.55 : 1.0,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isSoldOut ? null : onAdd,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.surfaceLight,
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badges Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isHappyHour)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4), // 4 is ok for small badges
                          border: Border.all(color: AppColors.warning, width: 1),
                        ),
                        child: const Text(
                          'HAPPY HOUR',
                          style: TextStyle(
                            color: AppColors.warning,
                            fontSize: 10, // Adjusted from 9 to 10
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    
                    if (isSoldOut)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.danger, width: 1),
                        ),
                        child: const Text(
                          'ESGOTADO',
                          style: TextStyle(
                            color: AppColors.danger,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16), // Adjusted from 12 to 16
                
                // Product Name
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: AppColors.textMain,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Price and Action Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'R\$ ${price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: isHappyHour ? AppColors.warning : AppColors.neonGreen,
                          fontSize: 16, // Adjusted from 17
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), // Adjusted to 8
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8), // Adjusted from 6
                        border: Border.all(
                          color: isSoldOut ? AppColors.surfaceLight : AppColors.neonGreen,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        isSoldOut ? 'Esgotado' : '+ Adicionar',
                        style: TextStyle(
                          fontSize: 12, // Adjusted from 11
                          fontWeight: FontWeight.bold,
                          color: isSoldOut ? AppColors.textMuted : AppColors.neonGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
