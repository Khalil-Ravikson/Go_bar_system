import 'package:drift/drift.dart';

enum SyncStatus {
  pending,
  synced,
}

// Tabela de Comandas/Mesas
class Orders extends Table {
  TextColumn get id => text()(); // UUIDv7
  TextColumn get tenantId => text()();
  IntColumn get tableNumber => integer()();
  TextColumn get status => text()(); // OPEN, CLOSED, CANCELED (or aberto, pago)
  IntColumn get openedAt => integer()(); // Timestamp epoch
  RealColumn get total => real().withDefault(const Constant(0.0))(); // New
  TextColumn get syncStatus => textEnum<SyncStatus>().withDefault(const Constant('pending'))(); // New
  IntColumn get createdAt => integer().nullable()(); // New: Timestamp epoch

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
  TextColumn get syncStatus => text().withDefault(const Constant('PENDING'))();
  TextColumn get status => text().withDefault(const Constant('preparando'))(); // New: preparando, pronto

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

// Categoria dos produtos
class Categories extends Table {
  TextColumn get id => text()(); // UUIDv7
  TextColumn get tenantId => text()();
  TextColumn get name => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

// Tabela de Produtos
class Products extends Table {
  TextColumn get id => text()(); // UUIDv7
  TextColumn get tenantId => text()();
  TextColumn get categoryId => text().references(Categories, #id)();
  TextColumn get name => text()();
  RealColumn get price => real()(); // User requested price
  IntColumn get currentPrice => integer()(); // Legacy price (cents)
  BoolColumn get isAvailable => boolean().withDefault(const Constant(true))();
  BoolColumn get isHappyHour => boolean().withDefault(const Constant(false))(); // New
  BoolColumn get isSoldOut => boolean().withDefault(const Constant(false))(); // New
  TextColumn get category => text().nullable()(); // New: String category name
  IntColumn get createdAt => integer().nullable()(); // New

  @override
  Set<Column> get primaryKey => {id};
}

// Tabela de Ingredientes
class Ingredients extends Table {
  TextColumn get id => text()(); // UUIDv7
  TextColumn get name => text()();
  TextColumn get unitMeasure => text()(); // e.g. 'un', 'g', 'ml'
  RealColumn get inStock => real()();

  @override
  Set<Column> get primaryKey => {id};
}

// Tabela de Associação de Produtos e Ingredientes (Ficha Técnica / Bill of Materials)
class ProductIngredients extends Table {
  TextColumn get id => text()(); // UUIDv7
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get ingredientId => text().references(Ingredients, #id)();
  RealColumn get defaultQuantity => real()();
  BoolColumn get isRemovable => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

// Tabela de Clientes (CRM)
class Customers extends Table {
  TextColumn get id => text()(); // UUIDv7
  TextColumn get name => text()();
  TextColumn get phone => text()();
  RealColumn get currentBalance => real().withDefault(const Constant(0.0))(); // Saldo Devedor/Fiado

  @override
  Set<Column> get primaryKey => {id};
}

// Tabela de Promoções / Combos (Motor de Promoções)
class Promotions extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get triggerProductId => text().references(Products, #id)();
  IntColumn get requiredQuantity => integer()();
  RealColumn get discountPercentage => real()();

  @override
  Set<Column> get primaryKey => {id};
}

// Tabela de Turnos/RH (Controlo de Horas e Gorjetas)
class Shifts extends Table {
  TextColumn get id => text()();
  TextColumn get waiterName => text()();
  IntColumn get startTime => integer()(); // Epoch timestamp
  IntColumn get endTime => integer().nullable()(); // Epoch timestamp
  RealColumn get totalSales => real().withDefault(const Constant(0.0))();
  RealColumn get tipsEarned => real().withDefault(const Constant(0.0))();

  @override
  Set<Column> get primaryKey => {id};
}

// Tabela de Desperdício (Controlo de Quebras)
class Wastes extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text().references(Products, #id)();
  RealColumn get quantity => real()();
  TextColumn get reason => text()(); // Erro do cliente, quebra de stock, etc.
  IntColumn get reportedAt => integer()(); // Epoch timestamp

  @override
  Set<Column> get primaryKey => {id};
}