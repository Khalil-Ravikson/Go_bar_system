import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../core/database/app_database.dart'; // Para aceder ao modelo Product

// 1. O Modelo do Item na Comanda
class CartItem {
  final Product product;
  final int quantity;

  CartItem({required this.product, this.quantity = 1});

  CartItem copyWith({Product? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

// 2. O Gestor de Estado (O "Calculador" do Caderno)
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  // Adiciona um produto ou incrementa a quantidade se já existir
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

  // Remove um produto ou decrementa a quantidade
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

  // Limpa a comanda após o envio
  void clearCart() {
    state = [];
  }

  // Calcula o total em tempo real (em centavos)
  int get totalInCents {
    return state.fold(0, (total, item) => total + (item.product.currentPrice * item.quantity));
  }
}

// 3. O Provider Global para a interface ouvir
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});