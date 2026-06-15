// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_dao.dart';

// ignore_for_file: type=lint
mixin _$InventoryDaoMixin on DatabaseAccessor<AppDatabase> {
  $CategoriesTable get categories => attachedDatabase.categories;
  $ProductsTable get products => attachedDatabase.products;
  $InventoryMovementsTable get inventoryMovements =>
      attachedDatabase.inventoryMovements;
  $SyncQueueTable get syncQueue => attachedDatabase.syncQueue;
  $StockItemsTable get stockItems => attachedDatabase.stockItems;
  $StockPriceHistoryTable get stockPriceHistory =>
      attachedDatabase.stockPriceHistory;
  $ProductRecipesTable get productRecipes => attachedDatabase.productRecipes;
  $WasteRecordsTable get wasteRecords => attachedDatabase.wasteRecords;
  $TablesTable get tables => attachedDatabase.tables;
  $OrdersTable get orders => attachedDatabase.orders;
  $OrderItemsTable get orderItems => attachedDatabase.orderItems;
  InventoryDaoManager get managers => InventoryDaoManager(this);
}

class InventoryDaoManager {
  final _$InventoryDaoMixin _db;
  InventoryDaoManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db.attachedDatabase, _db.products);
  $$InventoryMovementsTableTableManager get inventoryMovements =>
      $$InventoryMovementsTableTableManager(
        _db.attachedDatabase,
        _db.inventoryMovements,
      );
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db.attachedDatabase, _db.syncQueue);
  $$StockItemsTableTableManager get stockItems =>
      $$StockItemsTableTableManager(_db.attachedDatabase, _db.stockItems);
  $$StockPriceHistoryTableTableManager get stockPriceHistory =>
      $$StockPriceHistoryTableTableManager(
        _db.attachedDatabase,
        _db.stockPriceHistory,
      );
  $$ProductRecipesTableTableManager get productRecipes =>
      $$ProductRecipesTableTableManager(
        _db.attachedDatabase,
        _db.productRecipes,
      );
  $$WasteRecordsTableTableManager get wasteRecords =>
      $$WasteRecordsTableTableManager(_db.attachedDatabase, _db.wasteRecords);
  $$TablesTableTableManager get tables =>
      $$TablesTableTableManager(_db.attachedDatabase, _db.tables);
  $$OrdersTableTableManager get orders =>
      $$OrdersTableTableManager(_db.attachedDatabase, _db.orders);
  $$OrderItemsTableTableManager get orderItems =>
      $$OrderItemsTableTableManager(_db.attachedDatabase, _db.orderItems);
}
