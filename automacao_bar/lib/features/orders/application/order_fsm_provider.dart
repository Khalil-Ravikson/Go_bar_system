import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/database/database_provider.dart';
import '../../tables/application/table_fsm_provider.dart';

class OrderFsmNotifier extends Notifier<void> {
  @override
  void build() {}

  /// Comando: Iniciar Pedido/Comanda para Mesa
  Future<String> openOrder(String tableId) async {
    final orderId = const Uuid().v7();
    final orderRepo = ref.read(orderRepositoryProvider);
    
    // 1. Abrir a comanda no banco
    await orderRepo.openOrder(orderId, tableId);
    
    return orderId;
  }

  /// Comando: Adicionar Item na Comanda
  Future<void> addProductToOrder({
    required String orderId,
    required String productId,
    required double quantity,
    required double unitPrice,
    String? notes,
  }) async {
    final orderRepo = ref.read(orderRepositoryProvider);
    await orderRepo.addOrderItem(
      orderId: orderId,
      productId: productId,
      quantity: quantity,
      unitPrice: unitPrice,
      notes: notes,
    );
  }

  /// Comando: Solicitar Fechamento de Conta (Muda status da mesa para conta_solicitada)
  Future<void> requestOrderBill({
    required String orderId,
    required RestaurantTable table,
  }) async {
    // 1. Atualizar o estado da mesa via FSM
    await ref.read(tableFsmProvider.notifier).requestBill(table);
  }

  /// Comando: Finalizar e Pagar Pedido (Muda comanda para fechada e libera a mesa)
  Future<void> payAndCloseOrder({
    required String orderId,
    required RestaurantTable table,
  }) async {
    final orderRepo = ref.read(orderRepositoryProvider);
    final inventoryDao = ref.read(inventoryDaoProvider);

    // 1. Fechar comanda no SQLite
    await orderRepo.closeOrder(orderId);
    
    // 2. Dar baixa automática nos ingredientes das receitas
    await inventoryDao.deductStockForOrder(orderId);

    // 3. Liberar mesa na máquina de estados (FSM)
    await ref.read(tableFsmProvider.notifier).releaseTable(table);
  }
}

final orderFsmProvider = NotifierProvider<OrderFsmNotifier, void>(() {
  return OrderFsmNotifier();
});

final activeOrderForTableProvider = StreamProvider.family<Order?, String>((ref, tableId) {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.watchActiveOrderForTable(tableId);
});

final orderItemsProvider = StreamProvider.family<List<OrderItem>, String>((ref, orderId) {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.watchOrderItems(orderId);
});

final activeProductsStreamProvider = StreamProvider<List<Product>>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  return repo.watchActiveProducts();
});
