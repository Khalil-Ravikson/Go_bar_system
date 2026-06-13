import 'package:flutter/material.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/features/management/application/recipe_provider.dart';

/// Exibe os ingredientes de um produto como chips clicáveis.
/// Ingredientes removíveis podem ser excluídos; os fixos mostram um cadeado.
/// Ao alternar, chama [onToggle] para sincronizar com o controlador de texto.
class IngredientsSelector extends StatelessWidget {
  final List<ProductIngredient> recipe;
  final Set<String> excludedIds;
  final void Function(ProductIngredient) onToggle;

  const IngredientsSelector({
    super.key,
    required this.recipe,
    required this.excludedIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'COMPOSIÇÃO DO PRATO',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: recipe.map((ing) {
            final isExcluded = excludedIds.contains(ing.id);

            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: ing.isRemovable ? () => onToggle(ing) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isExcluded
                        ? AppColors.surfaceLight.withValues(alpha: 0.5)
                        : AppColors.neonGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isExcluded
                          ? AppColors.surfaceLight
                          : AppColors.neonGreen.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ing.name,
                        style: TextStyle(
                          color: isExcluded
                              ? AppColors.textMuted
                              : AppColors.textMain,
                          fontWeight: isExcluded
                              ? FontWeight.normal
                              : FontWeight.bold,
                          decoration: isExcluded
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (ing.isRemovable)
                        Icon(
                          isExcluded
                              ? Icons.add_circle_outline
                              : Icons.remove_circle_outline,
                          size: 14,
                          color: isExcluded
                              ? AppColors.textMuted
                              : AppColors.neonGreen,
                        )
                      else
                        const Icon(
                          Icons.lock_outline,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
