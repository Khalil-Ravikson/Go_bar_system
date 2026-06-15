import 'package:drift/drift.dart';

enum SyncStatus {
  pending,
  synced,
}

// 1. Users
class Users extends Table {
  TextColumn get id => text()(); // UUIDv7
  TextColumn get name => text()();
  TextColumn get pinHash => text()();
  TextColumn get role => text()(); // admin, waiter, chef, caixa
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get updatedAt => integer()(); // Epoch timestamp in ms

  @override
  Set<Column> get primaryKey => {id};
}

// 2. Categories
class Categories extends Table {
  TextColumn get id => text()(); // UUIDv7
  TextColumn get name => text()();
  TextColumn get colorCode => text().nullable()();
  IntColumn get updatedAt => integer()(); // Epoch timestamp in ms

  @override
  Set<Column> get primaryKey => {id};
}

// 3. Products
class Products extends Table {
  TextColumn get id => text()(); // UUIDv7
  TextColumn get categoryId => text().references(Categories, #id)();
  TextColumn get name => text()();
  RealColumn get price => real()();
  IntColumn get currentPrice => integer().withDefault(const Constant(0))(); // Compatibility
  RealColumn get stockQty => real().withDefault(const Constant(0.0))();
  RealColumn get minStock => real().withDefault(const Constant(0.0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get updatedAt => integer()(); // Epoch timestamp in ms

  @override
  Set<Column> get primaryKey => {id};
}

// 4. Tables
@DataClassName('RestaurantTable')
class Tables extends Table {
  TextColumn get id => text()(); // UUIDv7
  IntColumn get number => integer()();
  TextColumn get status => text()(); // e.g. livre, ocupada, conta_solicitada, reservada
  RealColumn get x => real().withDefault(const Constant(0.0))();
  RealColumn get y => real().withDefault(const Constant(0.0))();
  IntColumn get updatedAt => integer()(); // Epoch timestamp in ms

  @override
  Set<Column> get primaryKey => {id};
}

// 5. Orders
class Orders extends Table {
  TextColumn get id => text()(); // UUIDv7
  TextColumn get tableId => text().references(Tables, #id)();
  IntColumn get openedAt => integer()(); // Epoch timestamp in ms
  IntColumn get closedAt => integer().nullable()(); // Epoch timestamp in ms
  TextColumn get status => text()(); // e.g. aberto, fechado, cancelado
  RealColumn get totalAmount => real().withDefault(const Constant(0.0))();
  IntColumn get updatedAt => integer()(); // Epoch timestamp in ms

  @override
  Set<Column> get primaryKey => {id};
}

// 6. OrderItems
class OrderItems extends Table {
  TextColumn get id => text()(); // UUIDv7
  TextColumn get orderId => text().references(Orders, #id)();
  TextColumn get productId => text().references(Products, #id)();
  RealColumn get quantity => real()();
  RealColumn get unitPrice => real()();
  TextColumn get status => text().withDefault(const Constant('preparando'))(); // e.g. preparando, pronto
  TextColumn get notes => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('PENDING'))(); // Compatibility
  IntColumn get updatedAt => integer()(); // Epoch timestamp in ms

  @override
  Set<Column> get primaryKey => {id};
}

// 7. Payments
class Payments extends Table {
  TextColumn get id => text()(); // UUIDv7
  TextColumn get orderId => text().references(Orders, #id)();
  TextColumn get method => text()(); // e.g. dinheiro, pix, cartao
  RealColumn get amount => real()();
  IntColumn get paidAt => integer()(); // Epoch timestamp in ms
  IntColumn get updatedAt => integer()(); // Epoch timestamp in ms

  @override
  Set<Column> get primaryKey => {id};
}

// 8. SyncQueue (Outbox Pattern)
class SyncQueue extends Table {
  TextColumn get id => text()(); // UUIDv7
  TextColumn get targetTable => text()(); // Name of target database table
  TextColumn get operation => text()(); // INSERT, UPDATE, DELETE
  TextColumn get payloadJson => text()(); // Serialized representation
  IntColumn get createdAt => integer()(); // Epoch timestamp in ms
  TextColumn get syncStatus => textEnum<SyncStatus>().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}