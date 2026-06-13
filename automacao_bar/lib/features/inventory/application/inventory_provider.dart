import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../management/application/ingredients_provider.dart';
import '../../management/application/recipe_provider.dart';
import '../../management/application/products_provider.dart';
import '../../pos/presentation/providers/cart_provider.dart' as cart_present;

// Supplier Model
class Supplier {
  final String id;
  final String name;
  final String contact;

  const Supplier({required this.id, required this.name, required this.contact});
}

// InventoryLog Model (Stock movement log)
class InventoryLog {
  final String id;
  final String ingredientId;
  final double quantityAdded;
  final double costPerUnit;
  final String? purchaseOrderId;

  const InventoryLog({
    required this.id,
    required this.ingredientId,
    required this.quantityAdded,
    required this.costPerUnit,
    this.purchaseOrderId,
  });
}

// PurchaseOrder Model
class PurchaseOrder {
  final String id;
  final String supplierId;
  final double totalCost;
  final DateTime date;
  final List<InventoryLog> items;

  const PurchaseOrder({
    required this.id,
    required this.supplierId,
    required this.totalCost,
    required this.date,
    required this.items,
  });
}

// Supplier list provider
final suppliersProvider = Provider<List<Supplier>>((ref) {
  return [
    const Supplier(id: 's1', name: 'Distribuidora MF (Carnes & Pães)', contact: 'contato@distribuidoramf.com'),
    const Supplier(id: 's2', name: 'Hortifruti Cia (Vegetais)', contact: 'vendas@hortifruticia.com'),
    const Supplier(id: 's3', name: 'Laticínios Premium', contact: 'comercial@laticiniospremium.com'),
  ];
});

// Purchases state manager
class PurchasesNotifier extends Notifier<List<PurchaseOrder>> {
  @override
  List<PurchaseOrder> build() {
    return [
      PurchaseOrder(
        id: 'p_init1',
        supplierId: 's1',
        totalCost: 680.00,
        date: DateTime.now().subtract(const Duration(days: 2)),
        items: const [
          InventoryLog(id: 'log_init1', ingredientId: 'i3', quantityAdded: 100, costPerUnit: 2.00, purchaseOrderId: 'p_init1'),
          InventoryLog(id: 'log_init2', ingredientId: 'i4', quantityAdded: 80, costPerUnit: 6.00, purchaseOrderId: 'p_init1'),
        ],
      ),
      PurchaseOrder(
        id: 'p_init2',
        supplierId: 's2',
        totalCost: 163.00,
        date: DateTime.now().subtract(const Duration(days: 1)),
        items: const [
          InventoryLog(id: 'log_init3', ingredientId: 'i1', quantityAdded: 50, costPerUnit: 1.50, purchaseOrderId: 'p_init2'),
          InventoryLog(id: 'log_init4', ingredientId: 'i2', quantityAdded: 30, costPerUnit: 1.00, purchaseOrderId: 'p_init2'),
          InventoryLog(id: 'log_init5', ingredientId: 'i6', quantityAdded: 40, costPerUnit: 1.45, purchaseOrderId: 'p_init2'),
        ],
      ),
    ];
  }

  void addPurchase(PurchaseOrder order) {
    state = [...state, order];
  }
}

final purchasesProvider = NotifierProvider<PurchasesNotifier, List<PurchaseOrder>>(() {
  return PurchasesNotifier();
});

class InventoryNotifier extends Notifier<List<Ingredient>> {
  @override
  List<Ingredient> build() {
    // Ingredients populated with starting average costs and last purchase costs
    return [
      const Ingredient(id: 'i1', name: 'Tomate', unitMeasure: 'un', inStock: 50.0, minStock: 15.0, averageCost: 1.50, lastPurchaseCost: 1.50),
      const Ingredient(id: 'i2', name: 'Cebola', unitMeasure: 'un', inStock: 30.0, minStock: 10.0, averageCost: 1.00, lastPurchaseCost: 1.00),
      const Ingredient(id: 'i3', name: 'Pão de Hambúrguer', unitMeasure: 'un', inStock: 100.0, minStock: 20.0, averageCost: 2.00, lastPurchaseCost: 2.00),
      const Ingredient(id: 'i4', name: 'Carne de Hambúrguer', unitMeasure: 'un', inStock: 80.0, minStock: 20.0, averageCost: 6.00, lastPurchaseCost: 6.00),
      const Ingredient(id: 'i5', name: 'Queijo Cheddar', unitMeasure: 'un', inStock: 120.0, minStock: 30.0, averageCost: 3.00, lastPurchaseCost: 3.00),
      const Ingredient(id: 'i6', name: 'Alface', unitMeasure: 'un', inStock: 40.0, minStock: 15.0, averageCost: 1.20, lastPurchaseCost: 1.20),
    ];
  }

  void addIngredient(String name, String unitMeasure, double inStock, {double minStock = 15.0, double cost = 0.0}) {
    final newId = 'i${DateTime.now().millisecondsSinceEpoch}';
    final newIngredient = Ingredient(
      id: newId,
      name: name,
      unitMeasure: unitMeasure,
      inStock: inStock,
      minStock: minStock,
      averageCost: cost,
      lastPurchaseCost: cost,
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

  // Record an incoming invoice / purchase order and adjust prices reactively
  void addPurchase(String supplierId, List<InventoryLog> items) {
    final purchaseId = 'po_${DateTime.now().millisecondsSinceEpoch}';
    double totalCost = 0.0;
    final logsWithOrderId = <InventoryLog>[];

    for (var item in items) {
      totalCost += item.quantityAdded * item.costPerUnit;
      logsWithOrderId.add(InventoryLog(
        id: 'log_${DateTime.now().millisecondsSinceEpoch}_${item.ingredientId}',
        ingredientId: item.ingredientId,
        quantityAdded: item.quantityAdded,
        costPerUnit: item.costPerUnit,
        purchaseOrderId: purchaseId,
      ));
    }

    final newPurchase = PurchaseOrder(
      id: purchaseId,
      supplierId: supplierId,
      totalCost: totalCost,
      date: DateTime.now(),
      items: logsWithOrderId,
    );

    state = state.map((ing) {
      final log = logsWithOrderId.firstWhere(
        (l) => l.ingredientId == ing.id,
        orElse: () => const InventoryLog(id: '', ingredientId: '', quantityAdded: 0, costPerUnit: 0),
      );

      if (log.ingredientId.isNotEmpty) {
        final double oldStock = ing.inStock;
        final double qtyAdded = log.quantityAdded;
        final double cost = log.costPerUnit;

        final double newStock = oldStock + qtyAdded;
        final double newAverageCost = (oldStock + qtyAdded) > 0
            ? ((oldStock * ing.averageCost) + (qtyAdded * cost)) / (oldStock + qtyAdded)
            : cost;

        return ing.copyWith(
          inStock: newStock,
          averageCost: newAverageCost,
          lastPurchaseCost: cost,
        );
      }
      return ing;
    }).toList();

    ref.read(purchasesProvider.notifier).addPurchase(newPurchase);
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

  // Decrement stocks for a list of table items
  void decrementStockForItems(List<Map<String, dynamic>> items) {
    final products = ref.read(productsProvider);
    for (var item in items) {
      final name = item['name'] as String;
      final quantity = item['quantity'] as int;
      final notes = item['notes'] as String?;

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

// CMV (Custo de Mercadoria Vendida) dynamic calculation provider family
final cmvProvider = Provider.family<double, String>((ref, productId) {
  final recipes = ref.watch(recipeProvider);
  final ingredients = ref.watch(inventoryProvider);

  final recipe = recipes[productId] ?? [];
  if (recipe.isEmpty) return 0.0;

  double totalCmv = 0.0;
  for (var recipeItem in recipe) {
    final ingredient = ingredients.firstWhere(
      (i) => i.id == recipeItem.ingredientId,
      orElse: () => const Ingredient(id: '', name: '', unitMeasure: '', inStock: 0),
    );
    if (ingredient.id.isNotEmpty) {
      totalCmv += recipeItem.defaultQuantity * ingredient.lastPurchaseCost;
    }
  }
  return totalCmv;
});
