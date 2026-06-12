import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductIngredient {
  final String id;
  final String productId;
  final String ingredientId;
  final String name;
  final double defaultQuantity;
  final String unitMeasure;
  final bool isRemovable;

  const ProductIngredient({
    required this.id,
    required this.productId,
    required this.ingredientId,
    required this.name,
    required this.defaultQuantity,
    required this.unitMeasure,
    this.isRemovable = true,
  });

  ProductIngredient copyWith({
    String? id,
    String? productId,
    String? ingredientId,
    String? name,
    double? defaultQuantity,
    String? unitMeasure,
    bool? isRemovable,
  }) {
    return ProductIngredient(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      ingredientId: ingredientId ?? this.ingredientId,
      name: name ?? this.name,
      defaultQuantity: defaultQuantity ?? this.defaultQuantity,
      unitMeasure: unitMeasure ?? this.unitMeasure,
      isRemovable: isRemovable ?? this.isRemovable,
    );
  }
}

class RecipeNotifier extends Notifier<Map<String, List<ProductIngredient>>> {
  @override
  Map<String, List<ProductIngredient>> build() {
    return {
      'p1': [
        const ProductIngredient(
          id: 'pi1',
          productId: 'p1',
          ingredientId: 'i3',
          name: 'Pão de Hambúrguer',
          defaultQuantity: 1.0,
          unitMeasure: 'un',
          isRemovable: false,
        ),
        const ProductIngredient(
          id: 'pi2',
          productId: 'p1',
          ingredientId: 'i4',
          name: 'Carne de Hambúrguer',
          defaultQuantity: 1.0,
          unitMeasure: 'un',
          isRemovable: false,
        ),
        const ProductIngredient(
          id: 'pi3',
          productId: 'p1',
          ingredientId: 'i5',
          name: 'Queijo Cheddar',
          defaultQuantity: 1.0,
          unitMeasure: 'un',
          isRemovable: true,
        ),
        const ProductIngredient(
          id: 'pi4',
          productId: 'p1',
          ingredientId: 'i1',
          name: 'Tomate',
          defaultQuantity: 2.0,
          unitMeasure: 'un',
          isRemovable: true,
        ),
        const ProductIngredient(
          id: 'pi5',
          productId: 'p1',
          ingredientId: 'i6',
          name: 'Alface',
          defaultQuantity: 1.0,
          unitMeasure: 'un',
          isRemovable: true,
        ),
      ]
    };
  }

  void addIngredientToRecipe({
    required String productId,
    required String ingredientId,
    required String name,
    required double quantity,
    required String unitMeasure,
    required bool isRemovable,
  }) {
    final newId = 'pi${DateTime.now().millisecondsSinceEpoch}';
    final productIngredient = ProductIngredient(
      id: newId,
      productId: productId,
      ingredientId: ingredientId,
      name: name,
      defaultQuantity: quantity,
      unitMeasure: unitMeasure,
      isRemovable: isRemovable,
    );

    final currentRecipe = Map<String, List<ProductIngredient>>.from(state);
    final list = currentRecipe[productId] ?? [];
    currentRecipe[productId] = [...list, productIngredient];
    state = currentRecipe;
  }

  void removeIngredientFromRecipe(String productId, String productIngredientId) {
    final currentRecipe = Map<String, List<ProductIngredient>>.from(state);
    final list = currentRecipe[productId] ?? [];
    currentRecipe[productId] = list.where((item) => item.id != productIngredientId).toList();
    state = currentRecipe;
  }
}

final recipeProvider = NotifierProvider<RecipeNotifier, Map<String, List<ProductIngredient>>>(() {
  return RecipeNotifier();
});

final productRecipeProvider = Provider.family<List<ProductIngredient>, String>((ref, productId) {
  final recipes = ref.watch(recipeProvider);
  return recipes[productId] ?? [];
});
