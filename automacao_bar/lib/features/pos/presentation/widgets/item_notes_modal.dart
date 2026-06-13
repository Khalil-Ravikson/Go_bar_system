import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/shared/presentation/components/neon_button.dart';
import 'package:automacao_bar/features/management/application/products_provider.dart';
import 'package:automacao_bar/features/management/application/recipe_provider.dart';
import 'package:automacao_bar/features/pos/presentation/providers/cart_provider.dart';
import 'package:automacao_bar/features/pos/presentation/widgets/ingredients_selector.dart';

class ItemNotesModal extends ConsumerStatefulWidget {
  final Product product;

  const ItemNotesModal({super.key, required this.product});

  @override
  ConsumerState<ItemNotesModal> createState() => _ItemNotesModalState();
}

class _ItemNotesModalState extends ConsumerState<ItemNotesModal> {
  final _notesController = TextEditingController();
  final Set<String> _excludedIngredientIds = {};

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _toggleIngredient(ProductIngredient ing) {
    if (!ing.isRemovable) return;
    final phrase = 'Sem ${ing.name}';
    setState(() {
      if (_excludedIngredientIds.contains(ing.id)) {
        _excludedIngredientIds.remove(ing.id);
        String text = _notesController.text.trim();
        text = text.replaceAll(phrase, '').trim();
        text = text.replaceAll(RegExp(r'\s*,\s*,'), ',');
        text = text.replaceAll(RegExp(r'^[,;\s]+|[,;\s]+$'), '');
        _notesController.text = text;
      } else {
        _excludedIngredientIds.add(ing.id);
        final current = _notesController.text.trim();
        _notesController.text =
            current.isNotEmpty ? '$current, $phrase' : phrase;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final recipe = ref.watch(productRecipeProvider(widget.product.id));

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          color: AppColors.textMain,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'R\$ ${widget.product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.neonGreen,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Ingredientes (componente extraído)
            if (recipe.isNotEmpty)
              IngredientsSelector(
                recipe: recipe,
                excludedIds: _excludedIngredientIds,
                onToggle: _toggleIngredient,
              ),

            // Observações
            const Text(
              'OBSERVAÇÕES',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              style: const TextStyle(color: AppColors.textMain),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Ex: Bem passado, sem gelo, limão extra...',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surfaceLight,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.neonGreen),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botão confirmar
            NeonButton(
              onTap: () {
                final notes = _notesController.text.trim();
                ref.read(cartProvider.notifier).addItem(
                      widget.product.id,
                      widget.product.name,
                      widget.product.price,
                      notes: notes.isNotEmpty ? notes : null,
                    );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        '${widget.product.name} adicionado à comanda!',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: AppColors.neonGreen,
                      duration: const Duration(seconds: 1),
                    ),
                  );
              },
              text: 'Confirmar e Adicionar',
            ),
          ],
        ),
      ),
    );
  }
}
