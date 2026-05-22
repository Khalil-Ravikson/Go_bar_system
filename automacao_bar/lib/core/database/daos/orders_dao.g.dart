// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_dao.dart';

// ignore_for_file: type=lint
mixin _$OrdersDaoMixin on DatabaseAccessor<AppDatabase> {
  $OrdersTable get orders => attachedDatabase.orders;
  $OrderItemsTable get orderItems => attachedDatabase.orderItems;
  $SyncOutboxTable get syncOutbox => attachedDatabase.syncOutbox;
  OrdersDaoManager get managers => OrdersDaoManager(this);
}

class OrdersDaoManager {
  final _$OrdersDaoMixin _db;
  OrdersDaoManager(this._db);
  $$OrdersTableTableManager get orders =>
      $$OrdersTableTableManager(_db.attachedDatabase, _db.orders);
  $$OrderItemsTableTableManager get orderItems =>
      $$OrderItemsTableTableManager(_db.attachedDatabase, _db.orderItems);
  $$SyncOutboxTableTableManager get syncOutbox =>
      $$SyncOutboxTableTableManager(_db.attachedDatabase, _db.syncOutbox);
}
