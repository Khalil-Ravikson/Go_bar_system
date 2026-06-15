import 'package:drift/drift.dart';

import 'tables.dart';
import 'daos/orders_dao.dart';
import 'daos/products_dao.dart';
import 'daos/tables_dao.dart';
import 'daos/catalog_dao.dart';

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
    SyncQueue,
  ],
  daos: [
    OrdersDao,
    ProductsDao,
    TablesDao,
    CatalogDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(impl.openConnection());

  late final OrdersDao ordersDao = OrdersDao(this);
  late final ProductsDao productsDao = ProductsDao(this);
  late final TablesDao tablesDao = TablesDao(this);
  late final CatalogDao catalogDao = CatalogDao(this);

  @override
  int get schemaVersion => 1;
}