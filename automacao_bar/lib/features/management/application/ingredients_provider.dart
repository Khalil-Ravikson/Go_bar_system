import '../../inventory/application/inventory_provider.dart';

class Ingredient {
  final String id;
  final String name;
  final String unitMeasure;
  final double inStock;
  final double minStock;

  const Ingredient({
    required this.id,
    required this.name,
    required this.unitMeasure,
    required this.inStock,
    this.minStock = 15.0, // Default minimum warning threshold
  });

  Ingredient copyWith({
    String? id,
    String? name,
    String? unitMeasure,
    double? inStock,
    double? minStock,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      unitMeasure: unitMeasure ?? this.unitMeasure,
      inStock: inStock ?? this.inStock,
      minStock: minStock ?? this.minStock,
    );
  }
}

// Redirect ingredientsProvider to inventoryProvider to maintain backward compatibility
final ingredientsProvider = inventoryProvider;
