import 'package:drift/drift.dart';

import 'tables.dart';
import 'daos/orders_dao.dart';
import 'daos/catalog_dao.dart';

import 'connection/connection.dart'
    if (dart.library.js_util) 'connection/web.dart'
    if (dart.library.io) 'connection/native.dart' as impl;

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Orders,
    OrderItems,
    SyncOutbox,
    Categories,
    Products,
    Ingredients,
    ProductIngredients,
    Customers,
    Promotions,
    Shifts,
    Wastes,
    Suppliers,
    PurchaseOrders,
    InventoryLogs,
    Couriers,
    DeliveryOrders,
  ],
  daos: [OrdersDao, CatalogDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(impl.openConnection());

  @override
  int get schemaVersion => 1;
}