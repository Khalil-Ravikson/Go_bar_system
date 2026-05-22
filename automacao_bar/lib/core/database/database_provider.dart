import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart';
import 'daos/orders_dao.dart';
import '../network/sync_service.dart';
 // Adicione este import no topo
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// Fornece o DAO para o resto do app
final ordersDaoProvider = Provider<OrdersDao>((ref) {
  return ref.watch(databaseProvider).ordersDao;
});

// Fornece a LISTA AO VIVO de mesas abertas
final openOrdersProvider = StreamProvider<List<Order>>((ref) {
  final dao = ref.watch(ordersDaoProvider);
  return dao.watchOpenOrders();
});

// Provedor que busca os itens de uma comanda específica
final orderItemsProvider = StreamProvider.family<List<OrderItem>, String>((ref, orderId) {
  final dao = ref.watch(ordersDaoProvider);
  return dao.watchOrderItems(orderId);
});
// Fornece o Serviço de Sincronização
final syncServiceProvider = Provider<SyncService>((ref) {
  final dao = ref.watch(ordersDaoProvider);
  return SyncService(dao);
});