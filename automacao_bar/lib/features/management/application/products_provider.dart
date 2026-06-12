import 'package:flutter_riverpod/flutter_riverpod.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final bool isHappyHour;
  final bool isSoldOut;
  final int? createdAt;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.isHappyHour = false,
    this.isSoldOut = false,
    this.createdAt,
  });

  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? category,
    bool? isHappyHour,
    bool? isSoldOut,
    int? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      isHappyHour: isHappyHour ?? this.isHappyHour,
      isSoldOut: isSoldOut ?? this.isSoldOut,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ProductsNotifier extends Notifier<List<Product>> {
  @override
  List<Product> build() {
    return [
      const Product(
        id: 'p1',
        name: 'Hambúrguer Clássico',
        price: 29.90,
        category: 'Lanches',
        isHappyHour: false,
        isSoldOut: false,
      ),
      const Product(
        id: 'p2',
        name: 'Heineken Long Neck',
        price: 12.00,
        category: 'Bebidas',
        isHappyHour: true,
        isSoldOut: false,
      ),
      const Product(
        id: 'p3',
        name: 'Gin Tônica Tropical',
        price: 24.90,
        category: 'Bebidas',
        isHappyHour: false,
        isSoldOut: false,
      ),
      const Product(
        id: 'p4',
        name: 'Caipirinha de Limão',
        price: 15.00,
        category: 'Bebidas',
        isHappyHour: false,
        isSoldOut: true,
      ),
      const Product(
        id: 'p5',
        name: 'Porção de Batatas Fritas',
        price: 28.00,
        category: 'Porções',
        isHappyHour: false,
        isSoldOut: false,
      ),
    ];
  }

  void addProduct(String name, double price, String category) {
    final newId = 'p${DateTime.now().millisecondsSinceEpoch}';
    final newProduct = Product(
      id: newId,
      name: name,
      price: price,
      category: category,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    state = [...state, newProduct];
  }

  void toggleSoldOut(String id) {
    state = state.map((p) {
      if (p.id == id) {
        return p.copyWith(isSoldOut: !p.isSoldOut);
      }
      return p;
    }).toList();
  }
}

final productsProvider = NotifierProvider<ProductsNotifier, List<Product>>(() {
  return ProductsNotifier();
});
