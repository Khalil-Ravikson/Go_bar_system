import 'package:drift/drift.dart';

// Tabela de Comandas/Mesas
class Orders extends Table {
  TextColumn get id => text()(); // UUIDv7
  TextColumn get tenantId => text()();
  IntColumn get tableNumber => integer()();
  TextColumn get status => text()(); // OPEN, CLOSED, CANCELED
  IntColumn get openedAt => integer()(); // Timestamp epoch

  @override
  Set<Column> get primaryKey => {id};
}

// Tabela de Itens (Cerveja, Batata, etc)
class OrderItems extends Table {
  TextColumn get id => text()(); // UUIDv7
  TextColumn get orderId => text().references(Orders, #id)();
  TextColumn get productId => text()();
  IntColumn get quantity => integer()();
  TextColumn get notes => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('PENDING'))(); // PENDING ou SYNCED

  @override
  Set<Column> get primaryKey => {id};
}

// Tabela do Coração Offline (Padrão Outbox)
class SyncOutbox extends Table {
  TextColumn get id => text()(); // UUIDv7
  TextColumn get eventType => text()(); // Ex: ITEM_ADDED
  TextColumn get aggregateId => text()(); // ID do Pedido
  TextColumn get payload => text()(); // JSON com os dados
  IntColumn get occurredAt => integer()(); // Timestamp exato da ação

  @override
  Set<Column> get primaryKey => {id};
}