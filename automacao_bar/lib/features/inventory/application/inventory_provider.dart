import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../management/application/ingredients_provider.dart';
import '../../management/application/recipe_provider.dart';
import '../../management/application/products_provider.dart';
import '../../pos/presentation/providers/cart_provider.dart' as cart_present;

class InventoryNotifier extends Notifier<List<Ingredient>> {
  @override
  List<Ingredient> build() {
    return [
      const Ingredient(id: 'i1', name: 'Tomate', unitMeasure: 'un', inStock: 50.0, minStock: 15.0),
      const Ingredient(id: 'i2', name: 'Cebola', unitMeasure: 'un', inStock: 30.0, minStock: 10.0),
      const Ingredient(id: 'i3', name: 'Pão de Hambúrguer', unitMeasure: 'un', inStock: 100.0, minStock: 20.0),
      const Ingredient(id: 'i4', name: 'Carne de Hambúrguer', unitMeasure: 'un', inStock: 80.0, minStock: 20.0),
      const Ingredient(id: 'i5', name: 'Queijo Cheddar', unitMeasure: 'un', inStock: 120.0, minStock: 30.0),
      const Ingredient(id: 'i6', name: 'Alface', unitMeasure: 'un', inStock: 40.0, minStock: 15.0),
    ];
  }

  void addIngredient(String name, String unitMeasure, double inStock, {double minStock = 15.0}) {
    final newId = 'i${DateTime.now().millisecondsSinceEpoch}';
    final newIngredient = Ingredient(
      id: newId,
      name: name,
      unitMeasure: unitMeasure,
      inStock: inStock,
      minStock: minStock,
    );
    state = [...state, newIngredient];
  }

  void updateStock(String id, double newStock) {
    state = state.map((ing) {
      if (ing.id == id) {
        return ing.copyWith(inStock: newStock);
      }
      return ing;
    }).toList();
  }

  // Decrement stocks for a single product and quantity, parsing exclusions from notes
  void decrementStockForProduct(String productId, int productQty, {String? notes}) {
    final recipes = ref.read(recipeProvider);
    final recipe = recipes[productId] ?? [];
    if (recipe.isEmpty) return;

    // Parse exclusions from notes
    final Set<String> excludedNames = {};
    if (notes != null && notes.isNotEmpty) {
      final parts = notes.split(RegExp(r'[,;\n]'));
      for (var part in parts) {
        final trimmed = part.trim().toLowerCase();
        if (trimmed.startsWith('sem ')) {
          final ingredientName = trimmed.substring(4).trim();
          excludedNames.add(ingredientName);
        }
      }
    }

    state = state.map((ingredient) {
      ProductIngredient? recipeItem;
      for (var r in recipe) {
        if (r.ingredientId == ingredient.id) {
          recipeItem = r;
          break;
        }
      }

      if (recipeItem != null) {
        final isExcluded = excludedNames.contains(recipeItem.name.toLowerCase());
        if (!isExcluded) {
          final decrementAmount = recipeItem.defaultQuantity * productQty;
          final newStock = (ingredient.inStock - decrementAmount).clamp(0.0, double.infinity);
          return ingredient.copyWith(inStock: newStock);
        }
      }
      return ingredient;
    }).toList();
  }

  // Decrement stocks for a list of table items (e.g. from checkout screen)
  void decrementStockForItems(List<Map<String, dynamic>> items) {
    final products = ref.read(productsProvider);
    for (var item in items) {
      final name = item['name'] as String;
      final quantity = item['quantity'] as int;
      final notes = item['notes'] as String?;

      // Find product by name (case-insensitive)
      Product? product;
      for (var p in products) {
        if (p.name.toLowerCase() == name.toLowerCase()) {
          product = p;
          break;
        }
      }

      if (product != null) {
        decrementStockForProduct(product.id, quantity, notes: notes);
      }
    }
  }

  // Decrement stocks for active POS cart items
  void decrementStockForCart(List<cart_present.CartItem> cartItems) {
    for (var item in cartItems) {
      decrementStockForProduct(item.id, item.quantity, notes: item.notes);
    }
  }
}

final inventoryProvider = NotifierProvider<InventoryNotifier, List<Ingredient>>(() {
  return InventoryNotifier();
});

// Returns only the ingredients running below or equal to their safety threshold
final lowStockIngredientsProvider = Provider<List<Ingredient>>((ref) {
  final ingredients = ref.watch(inventoryProvider);
  return ingredients.where((ing) => ing.inStock <= ing.minStock).toList();
});
