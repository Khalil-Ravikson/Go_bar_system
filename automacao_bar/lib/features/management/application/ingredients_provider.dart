import 'package:flutter_riverpod/flutter_riverpod.dart';

class Ingredient {
  final String id;
  final String name;
  final String unitMeasure;
  final double inStock;

  const Ingredient({
    required this.id,
    required this.name,
    required this.unitMeasure,
    required this.inStock,
  });

  Ingredient copyWith({
    String? id,
    String? name,
    String? unitMeasure,
    double? inStock,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      unitMeasure: unitMeasure ?? this.unitMeasure,
      inStock: inStock ?? this.inStock,
    );
  }
}

class IngredientsNotifier extends Notifier<List<Ingredient>> {
  @override
  List<Ingredient> build() {
    return [
      const Ingredient(id: 'i1', name: 'Tomate', unitMeasure: 'un', inStock: 50.0),
      const Ingredient(id: 'i2', name: 'Cebola', unitMeasure: 'un', inStock: 30.0),
      const Ingredient(id: 'i3', name: 'Pão de Hambúrguer', unitMeasure: 'un', inStock: 100.0),
      const Ingredient(id: 'i4', name: 'Carne de Hambúrguer', unitMeasure: 'un', inStock: 80.0),
      const Ingredient(id: 'i5', name: 'Queijo Cheddar', unitMeasure: 'un', inStock: 120.0),
      const Ingredient(id: 'i6', name: 'Alface', unitMeasure: 'un', inStock: 40.0),
    ];
  }

  void addIngredient(String name, String unitMeasure, double inStock) {
    // Generate a simple unique ID
    final newId = 'i${DateTime.now().millisecondsSinceEpoch}';
    final newIngredient = Ingredient(
      id: newId,
      name: name,
      unitMeasure: unitMeasure,
      inStock: inStock,
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
}

final ingredientsProvider = NotifierProvider<IngredientsNotifier, List<Ingredient>>(() {
  return IngredientsNotifier();
});
