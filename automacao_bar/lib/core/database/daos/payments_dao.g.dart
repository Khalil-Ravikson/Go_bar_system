// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payments_dao.dart';

// ignore_for_file: type=lint
mixin _$PaymentsDaoMixin on DatabaseAccessor<AppDatabase> {
  $TablesTable get tables => attachedDatabase.tables;
  $OrdersTable get orders => attachedDatabase.orders;
  $PaymentsTable get payments => attachedDatabase.payments;
  $CategoriesTable get categories => attachedDatabase.categories;
  $ProductsTable get products => attachedDatabase.products;
  $OrderItemsTable get orderItems => attachedDatabase.orderItems;
  $SyncQueueTable get syncQueue => attachedDatabase.syncQueue;
  $UnpaidOrdersTable get unpaidOrders => attachedDatabase.unpaidOrders;
  PaymentsDaoManager get managers => PaymentsDaoManager(this);
}

class PaymentsDaoManager {
  final _$PaymentsDaoMixin _db;
  PaymentsDaoManager(this._db);
  $$TablesTableTableManager get tables =>
      $$TablesTableTableManager(_db.attachedDatabase, _db.tables);
  $$OrdersTableTableManager get orders =>
      $$OrdersTableTableManager(_db.attachedDatabase, _db.orders);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db.attachedDatabase, _db.payments);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db.attachedDatabase, _db.products);
  $$OrderItemsTableTableManager get orderItems =>
      $$OrderItemsTableTableManager(_db.attachedDatabase, _db.orderItems);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db.attachedDatabase, _db.syncQueue);
  $$UnpaidOrdersTableTableManager get unpaidOrders =>
      $$UnpaidOrdersTableTableManager(_db.attachedDatabase, _db.unpaidOrders);
}
