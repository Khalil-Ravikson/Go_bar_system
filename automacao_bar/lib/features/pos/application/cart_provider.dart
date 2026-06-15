import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../core/database/app_database.dart';

// 1. Cart Item model
class CartItem {
  final Product product;
  final int quantity;
  final String? notes;

  CartItem({required this.product, this.quantity = 1, this.notes});

  CartItem copyWith({Product? product, int? quantity, String? notes}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
    );
  }

  double get lineTotal => product.price * quantity;

  // Legacy aliases used in other screens
  String get id => product.id;
  String get name => product.name;
}

// 2. State manager
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addProduct(Product product) {
    final existingIndex = state.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      final newState = [...state];
      newState[existingIndex] = newState[existingIndex].copyWith(
        quantity: newState[existingIndex].quantity + 1,
      );
      state = newState;
    } else {
      state = [...state, CartItem(product: product)];
    }
  }

  void removeProduct(String productId) {
    final existingIndex = state.indexWhere((item) => item.product.id == productId);
    if (existingIndex >= 0) {
      final currentQty = state[existingIndex].quantity;
      if (currentQty > 1) {
        final newState = [...state];
        newState[existingIndex] = newState[existingIndex].copyWith(quantity: currentQty - 1);
        state = newState;
      } else {
        state = state.where((item) => item.product.id != productId).toList();
      }
    }
  }

  void clearCart() => state = [];

  // Total in reais (not cents)
  double get total {
    return state.fold(0.0, (sum, item) => sum + item.lineTotal);
  }

  // Legacy int accessor (in cents) kept for backward compat
  int get totalInCents => (total * 100).round();
}

// 3. Global provider
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

// Derived providers
final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider.notifier);
  ref.watch(cartProvider);
  return cart.total;
});

final cartItemCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0, (sum, item) => sum + item.quantity);
});