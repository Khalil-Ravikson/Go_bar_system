import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String? notes;

  const CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.notes,
  });

  CartItem copyWith({
    String? id,
    String? name,
    double? price,
    int? quantity,
    String? notes,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
    );
  }
}

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() {
    return [];
  }

  void addItem(String id, String name, double price, {String? notes}) {
    final existingIndex = state.indexWhere((item) => item.id == id && item.notes == notes);
    if (existingIndex >= 0) {
      final existingItem = state[existingIndex];
      state = [
        ...state.sublist(0, existingIndex),
        existingItem.copyWith(quantity: existingItem.quantity + 1),
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      state = [
        ...state,
        CartItem(id: id, name: name, price: price, quantity: 1, notes: notes),
      ];
    }
  }

  void removeItem(String id, {String? notes}) {
    state = state.where((item) => !(item.id == id && item.notes == notes)).toList();
  }

  void incrementQuantity(String id, {String? notes}) {
    final index = state.indexWhere((item) => item.id == id && item.notes == notes);
    if (index >= 0) {
      final item = state[index];
      state = [
        ...state.sublist(0, index),
        item.copyWith(quantity: item.quantity + 1),
        ...state.sublist(index + 1),
      ];
    }
  }

  void decrementQuantity(String id, {String? notes}) {
    final index = state.indexWhere((item) => item.id == id && item.notes == notes);
    if (index >= 0) {
      final item = state[index];
      if (item.quantity > 1) {
        state = [
          ...state.sublist(0, index),
          item.copyWith(quantity: item.quantity - 1),
          ...state.sublist(index + 1),
        ];
      } else {
        removeItem(id, notes: notes);
      }
    }
  }

  void clearCart() {
    state = [];
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(() {
  return CartNotifier();
});

final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0.0, (total, item) => total + (item.price * item.quantity));
});
