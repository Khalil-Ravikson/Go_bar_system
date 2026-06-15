import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart';
import 'daos/orders_dao.dart';
import 'daos/products_dao.dart';
import 'daos/tables_dao.dart';
import 'daos/catalog_dao.dart';
import '../network/sync_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final dao = ref.watch(ordersDaoProvider);
  return SyncService(dao);
});

final catalogDaoProvider = Provider<CatalogDao>((ref) {
  return ref.watch(databaseProvider).catalogDao;
});

final ordersDaoProvider = Provider<OrdersDao>((ref) {
  return ref.watch(databaseProvider).ordersDao;
});

final productsDaoProvider = Provider<ProductsDao>((ref) {
  return ref.watch(databaseProvider).productsDao;
});

final tablesDaoProvider = Provider<TablesDao>((ref) {
  return ref.watch(databaseProvider).tablesDao;
});

// Fornece a LISTA AO VIVO de comandas ativas
final openOrdersProvider = StreamProvider<List<Order>>((ref) {
  final dao = ref.watch(ordersDaoProvider);
  return dao.watchActiveOrders();
});

// Provedor que busca os itens de uma comanda específica
final orderItemsProvider = StreamProvider.family<List<OrderItem>, String>((ref, orderId) {
  final dao = ref.watch(ordersDaoProvider);
  return dao.watchOrderItems(orderId);
});

// Provedores de Leitura (Para a tela do Garçom)
final watchCategoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(productsDaoProvider).watchActiveCategories();
});

final watchProductsByCategoryProvider = StreamProvider.family<List<Product>, String>((ref, categoryId) {
  return ref.watch(productsDaoProvider).watchProductsByCategory(categoryId);
});