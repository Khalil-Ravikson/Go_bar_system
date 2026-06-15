import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart';
import 'daos/orders_dao.dart';
import 'daos/products_dao.dart';
import 'daos/tables_dao.dart';
import 'daos/catalog_dao.dart';
import 'daos/inventory_dao.dart';
import 'daos/customers_dao.dart';
import 'daos/payments_dao.dart';
import '../network/sync_service.dart';

// ── Database ──────────────────────────────────────────────────────────────────
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// ── DAOs ──────────────────────────────────────────────────────────────────────
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

final inventoryDaoProvider = Provider<InventoryDao>((ref) {
  return ref.watch(databaseProvider).inventoryDao;
});

final customersDaoProvider = Provider<CustomersDao>((ref) {
  return ref.watch(databaseProvider).customersDao;
});

final paymentsDaoProvider = Provider<PaymentsDao>((ref) {
  return ref.watch(databaseProvider).paymentsDao;
});

// ── Sync ──────────────────────────────────────────────────────────────────────
final syncServiceProvider = Provider<SyncService>((ref) {
  final dao = ref.watch(ordersDaoProvider);
  return SyncService(dao);
});

final pendingSyncEventsProvider = StreamProvider<List<SyncQueueData>>((ref) {
  return ref.watch(ordersDaoProvider).watchPendingSyncEvents();
});

// ── Order Stream Providers ────────────────────────────────────────────────────
final openOrdersProvider = StreamProvider<List<Order>>((ref) {
  return ref.watch(ordersDaoProvider).watchActiveOrders();
});

final orderItemsProvider = StreamProvider.family<List<OrderItem>, String>((ref, orderId) {
  return ref.watch(ordersDaoProvider).watchOrderItems(orderId);
});

// ── Product Stream Providers ──────────────────────────────────────────────────
final watchCategoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(productsDaoProvider).watchActiveCategories();
});

final watchProductsByCategoryProvider = StreamProvider.family<List<Product>, String>((ref, categoryId) {
  return ref.watch(productsDaoProvider).watchProductsByCategory(categoryId);
});

final watchAllProductsProvider = StreamProvider<List<Product>>((ref) {
  return ref.watch(productsDaoProvider).watchAllActiveProducts();
});

// ── Inventory Stream Providers ─────────────────────────────────────────────────
final allProductBalancesProvider = StreamProvider<List<ProductBalance>>((ref) {
  return ref.watch(inventoryDaoProvider).watchAllProductBalances();
});

final lowStockProductsProvider = StreamProvider<List<ProductBalance>>((ref) {
  return ref.watch(inventoryDaoProvider).watchLowStockProducts();
});

final productBalanceProvider = StreamProvider.family<double, String>((ref, productId) {
  return ref.watch(inventoryDaoProvider).watchProductBalance(productId);
});

final recentMovementsProvider = StreamProvider<List<InventoryMovement>>((ref) {
  return ref.watch(inventoryDaoProvider).watchRecentMovements();
});

// ── Dashboard Stream Providers ─────────────────────────────────────────────────
final revenueTodayProvider = StreamProvider<double>((ref) {
  return ref.watch(paymentsDaoProvider).watchRevenueToday();
});

final revenueYesterdayProvider = StreamProvider<double>((ref) {
  return ref.watch(paymentsDaoProvider).watchRevenueYesterday();
});

final orderCountTodayProvider = StreamProvider<int>((ref) {
  return ref.watch(paymentsDaoProvider).watchOrderCountToday();
});

final revenueByMethodTodayProvider = StreamProvider<Map<String, double>>((ref) {
  return ref.watch(paymentsDaoProvider).watchRevenueByMethodToday();
});

final topProductsTodayProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(paymentsDaoProvider).watchTopProductsToday();
});

// ── Customer Providers ────────────────────────────────────────────────────────
final allCustomersProvider = StreamProvider<List<Customer>>((ref) {
  return ref.watch(customersDaoProvider).watchAllCustomers();
});

// ── Stock & Recipe Providers ─────────────────────────────────────────────────
final allStockItemsProvider = StreamProvider<List<StockItem>>((ref) {
  return ref.watch(inventoryDaoProvider).watchAllStockItems();
});

final stockItemProvider = StreamProvider.family<StockItem, String>((ref, id) {
  return ref.watch(inventoryDaoProvider).watchStockItem(id);
});

final stockPriceHistoryProvider = StreamProvider.family<List<StockPriceHistoryData>, String>((ref, stockItemId) {
  return ref.watch(inventoryDaoProvider).watchPriceHistory(stockItemId);
});

final allWasteRecordsProvider = StreamProvider<List<WasteRecord>>((ref) {
  return ref.watch(inventoryDaoProvider).watchAllWasteRecords();
});

final productRecipesProvider = StreamProvider.family<List<ProductRecipe>, String>((ref, productId) {
  return ref.watch(inventoryDaoProvider).watchRecipesForProduct(productId);
});

// ── Unpaid Orders Providers ──────────────────────────────────────────────────
final unpaidOrdersProvider = StreamProvider<List<UnpaidOrder>>((ref) {
  return ref.watch(paymentsDaoProvider).watchUnpaidOrders();
});

final pendingUnpaidOrdersProvider = StreamProvider<List<UnpaidOrder>>((ref) {
  return ref.watch(paymentsDaoProvider).watchPendingUnpaidOrders();
});

final allRecipesProvider = StreamProvider<List<ProductRecipe>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.productRecipes).watch();
});

// ── KDS Active Tickets Provider ──────────────────────────────────────────────
final kdsTicketsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final db = ref.watch(databaseProvider);
  final query = db.customSelect(
    '''
    SELECT 
      oi.id AS item_id,
      oi.order_id,
      oi.quantity,
      oi.status AS item_status,
      oi.notes,
      oi.updated_at,
      p.name AS product_name,
      o.opened_at,
      t.number AS table_number
    FROM order_items oi
    JOIN orders o ON o.id = oi.order_id
    JOIN "tables" t ON t.id = o.table_id
    JOIN products p ON p.id = oi.product_id
    WHERE oi.status = 'preparando' AND o.status = 'aberto'
    ORDER BY o.opened_at ASC
    ''',
    readsFrom: {db.orderItems, db.orders, db.tables, db.products},
  );

  return query.watch().map((rows) {
    final Map<String, Map<String, dynamic>> ticketsMap = {};

    for (final row in rows) {
      final orderId = row.read<String>('order_id');
      final itemId = row.read<String>('item_id');
      final qty = row.read<double>('quantity');
      final notes = row.readNullable<String>('notes');
      final productName = row.read<String>('product_name');
      final openedAt = row.read<int>('opened_at');
      final tableNum = row.read<int>('table_number').toString();

      final ticket = ticketsMap.putIfAbsent(orderId, () => {
        'id': orderId,
        'tableNumber': tableNum.padLeft(2, '0'),
        'openedAt': openedAt,
        'items': <Map<String, dynamic>>[],
      });

      (ticket['items'] as List<Map<String, dynamic>>).add({
        'itemId': itemId,
        'name': productName,
        'quantity': qty.toInt(),
        'notes': notes,
      });
    }

    return ticketsMap.values.toList();
  });
});