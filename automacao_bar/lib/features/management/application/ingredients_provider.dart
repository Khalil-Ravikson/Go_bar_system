import '../../inventory/application/inventory_provider.dart';

class Ingredient {
  final String id;
  final String name;
  final String unitMeasure;
  final double inStock;
  final double minStock;
  final double averageCost;
  final double lastPurchaseCost;

  const Ingredient({
    required this.id,
    required this.name,
    required this.unitMeasure,
    required this.inStock,
    this.minStock = 15.0, // Default minimum warning threshold
    this.averageCost = 0.0,
    this.lastPurchaseCost = 0.0,
  });

  Ingredient copyWith({
    String? id,
    String? name,
    String? unitMeasure,
    double? inStock,
    double? minStock,
    double? averageCost,
    double? lastPurchaseCost,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      unitMeasure: unitMeasure ?? this.unitMeasure,
      inStock: inStock ?? this.inStock,
      minStock: minStock ?? this.minStock,
      averageCost: averageCost ?? this.averageCost,
      lastPurchaseCost: lastPurchaseCost ?? this.lastPurchaseCost,
    );
  }
}

// Redirect ingredientsProvider to inventoryProvider to maintain backward compatibility
final ingredientsProvider = inventoryProvider;
