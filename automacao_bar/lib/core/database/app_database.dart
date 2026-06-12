import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';
import 'daos/orders_dao.dart';
import 'daos/catalog_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Orders, OrderItems, SyncOutbox, Categories, Products, Ingredients, ProductIngredients],
  daos: [OrdersDao, CatalogDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'bar_offline.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}