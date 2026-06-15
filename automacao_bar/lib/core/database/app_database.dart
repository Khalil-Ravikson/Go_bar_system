import 'package:drift/drift.dart';

import 'tables.dart';
import 'daos/orders_dao.dart';
import 'daos/products_dao.dart';
import 'daos/tables_dao.dart';
import 'daos/catalog_dao.dart';
import 'daos/inventory_dao.dart';
import 'daos/customers_dao.dart';
import 'daos/payments_dao.dart';

import 'connection/connection.dart'
    if (dart.library.js_util) 'connection/web.dart'
    if (dart.library.io) 'connection/native.dart' as impl;

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Users,
    Categories,
    Products,
    Tables,
    Orders,
    OrderItems,
    Payments,
    InventoryMovements,
    Customers,
    LoyaltyTransactions,
    SyncQueue,
    StockItems,
    StockPriceHistory,
    ProductRecipes,
    WasteRecords,
    UnpaidOrders,
  ],
  daos: [
    OrdersDao,
    ProductsDao,
    TablesDao,
    CatalogDao,
    InventoryDao,
    CustomersDao,
    PaymentsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(impl.openConnection());

  @override
  late final OrdersDao ordersDao = OrdersDao(this);
  @override
  late final ProductsDao productsDao = ProductsDao(this);
  @override
  late final TablesDao tablesDao = TablesDao(this);
  @override
  late final CatalogDao catalogDao = CatalogDao(this);
  @override
  late final InventoryDao inventoryDao = InventoryDao(this);
  @override
  late final CustomersDao customersDao = CustomersDao(this);
  @override
  late final PaymentsDao paymentsDao = PaymentsDao(this);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // Add new tables introduced in v2
        await m.createTable(inventoryMovements);
        await m.createTable(customers);
        await m.createTable(loyaltyTransactions);
        
        // Alter Orders: add customerId, serverId, paymentMethod columns
        await m.addColumn(orders, orders.customerId);
        await m.addColumn(orders, orders.serverId);
        await m.addColumn(orders, orders.paymentMethod);

        // Alter Tables: add label, capacity columns
        await m.addColumn(tables, tables.label);
        await m.addColumn(tables, tables.capacity);
        
        // Alter Payments: add notes column
        await m.addColumn(payments, payments.notes);

        // Alter Categories: add sortOrder column  
        await m.addColumn(categories, categories.sortOrder);

        // Alter Products: add description column
        await m.addColumn(products, products.description);
      }
      if (from < 3) {
        // Add new tables introduced in v3
        await m.createTable(stockItems);
        await m.createTable(stockPriceHistory);
        await m.createTable(productRecipes);
        await m.createTable(wasteRecords);
        await m.createTable(unpaidOrders);
      }
    },
  );
}