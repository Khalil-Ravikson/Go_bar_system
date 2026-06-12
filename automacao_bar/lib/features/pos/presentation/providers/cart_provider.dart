import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String? notes;
  final double discount;
  final bool isSent;

  const CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.notes,
    this.discount = 0.0,
    this.isSent = false,
  });

  CartItem copyWith({
    String? id,
    String? name,
    double? price,
    int? quantity,
    String? notes,
    double? discount,
    bool? isSent,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      discount: discount ?? this.discount,
      isSent: isSent ?? this.isSent,
    );
  }

  double get total => (price * quantity) - discount;
}

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() {
    return [];
  }

  void applyAutoPromotions() {
    state = state.map((item) {
      double discount = 0.0;
      // Promo 1: Hambúrguer Clássico (id: 'p1') - "Pague 2, Leve 3"
      if (item.id == 'p1' && item.quantity >= 3) {
        final promoGroups = item.quantity ~/ 3;
        discount = promoGroups * item.price;
      }
      // Promo 2: Heineken Long Neck (id: 'p2') - "10% de desconto a partir de 2"
      if (item.id == 'p2' && item.quantity >= 2) {
        discount = item.price * item.quantity * 0.10;
      }
      return item.copyWith(discount: discount);
    }).toList();
  }

  void markAllAsSent() {
    state = state.map((item) => item.copyWith(isSent: true)).toList();
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
    applyAutoPromotions();
  }

  void removeItem(String id, {String? notes}) {
    state = state.where((item) => !(item.id == id && item.notes == notes)).toList();
    applyAutoPromotions();
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
      applyAutoPromotions();
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
        applyAutoPromotions();
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
  return cart.fold(0.0, (total, item) => total + item.total);
});
