import 'package:drift/drift.dart';

enum SyncStatus { pending, synced }

// ─── 1. Users ────────────────────────────────────────────────────────────────
class Users extends Table {
  TextColumn get id      => text()();  // UUIDv7
  TextColumn get name    => text()();
  TextColumn get pinHash => text()();
  TextColumn get role    => text()();  // admin, waiter, chef, caixa
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn  get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

// ─── 2. Categories ───────────────────────────────────────────────────────────
class Categories extends Table {
  TextColumn get id        => text()();
  TextColumn get name      => text()();
  TextColumn get colorCode => text().nullable()(); // hex color string e.g. '#00FF88'
  IntColumn  get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn  get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

// ─── 3. Products ─────────────────────────────────────────────────────────────
class Products extends Table {
  TextColumn get id         => text()();
  TextColumn get categoryId => text().references(Categories, #id)();
  TextColumn get name       => text()();
  RealColumn get price      => real()();
  RealColumn get minStock   => real().withDefault(const Constant(0.0))();
  TextColumn get description => text().nullable()();
  BoolColumn get isActive   => boolean().withDefault(const Constant(true))();
  IntColumn  get updatedAt  => integer()();

  // NOTE: stockQty is intentionally removed — balance is computed from InventoryMovements
  @override
  Set<Column> get primaryKey => {id};
}

// ─── 4. Tables ───────────────────────────────────────────────────────────────
@DataClassName('RestaurantTable')
class Tables extends Table {
  TextColumn get id       => text()();
  IntColumn  get number   => integer()();
  TextColumn get label    => text().nullable()();   // e.g. "Mesa VIP", "Deck 3"
  IntColumn  get capacity => integer().withDefault(const Constant(4))();
  TextColumn get status   => text()();  // livre, ocupada, fechando
  RealColumn get x        => real().withDefault(const Constant(0.0))();
  RealColumn get y        => real().withDefault(const Constant(0.0))();
  IntColumn  get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

// ─── 5. Orders ───────────────────────────────────────────────────────────────
class Orders extends Table {
  TextColumn get id            => text()();
  TextColumn get tableId       => text().references(Tables, #id)();
  TextColumn get customerId    => text().nullable()(); // FK Customers (optional)
  TextColumn get serverId      => text().nullable()(); // FK Users (garçom responsável)
  IntColumn  get openedAt      => integer()();
  IntColumn  get closedAt      => integer().nullable()();
  TextColumn get status        => text()(); // aberto, fechado, cancelado
  RealColumn get totalAmount   => real().withDefault(const Constant(0.0))();
  TextColumn get paymentMethod => text().nullable()(); // pix, cartao, dinheiro, dividir
  IntColumn  get updatedAt     => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

// ─── 6. OrderItems ───────────────────────────────────────────────────────────
class OrderItems extends Table {
  TextColumn get id         => text()();
  TextColumn get orderId    => text().references(Orders, #id)();
  TextColumn get productId  => text().references(Products, #id)();
  RealColumn get quantity   => real()();
  RealColumn get unitPrice  => real()();
  TextColumn get status     => text().withDefault(const Constant('preparando'))();
  TextColumn get notes      => text().nullable()();
  IntColumn  get updatedAt  => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

// ─── 7. Payments ─────────────────────────────────────────────────────────────
class Payments extends Table {
  TextColumn get id         => text()();
  TextColumn get orderId    => text().references(Orders, #id)();
  TextColumn get method     => text()(); // pix, cartao, dinheiro, dividir
  RealColumn get amount     => real()();
  TextColumn get notes      => text().nullable()();
  IntColumn  get paidAt     => integer()();
  IntColumn  get updatedAt  => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

// ─── 8. InventoryMovements (Delta Ledger) ────────────────────────────────────
// REGRA: Saldo atual = SUM(delta) WHERE product_id = ?
// delta > 0 = entrada (compra/ajuste positivo)
// delta < 0 = saída (venda/ajuste negativo/quebra)
class InventoryMovements extends Table {
  TextColumn get id        => text()();
  TextColumn get productId => text().references(Products, #id)();
  RealColumn get delta     => real()(); // positive = in, negative = out
  TextColumn get reason    => text()(); // venda, compra, ajuste, quebra, devolucao
  TextColumn get userId    => text().nullable()();  // quem fez o movimento
  TextColumn get orderId   => text().nullable()();  // referência da comanda (vendas)
  TextColumn get notes     => text().nullable()();
  IntColumn  get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

// ─── 9. Customers (CRM) ──────────────────────────────────────────────────────
class Customers extends Table {
  TextColumn get id             => text()();
  TextColumn get name           => text()();
  TextColumn get phone          => text()();  // unique identifier
  TextColumn get email          => text().nullable()();
  IntColumn  get loyaltyPoints  => integer().withDefault(const Constant(0))();
  RealColumn get totalSpent     => real().withDefault(const Constant(0.0))();
  IntColumn  get visitCount     => integer().withDefault(const Constant(0))();
  IntColumn  get createdAt      => integer()();
  IntColumn  get updatedAt      => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

// ─── 10. LoyaltyTransactions ─────────────────────────────────────────────────
class LoyaltyTransactions extends Table {
  TextColumn get id          => text()();
  TextColumn get customerId  => text().references(Customers, #id)();
  TextColumn get orderId     => text().nullable()(); // referência da comanda
  IntColumn  get pointsDelta => integer()(); // positive = earned, negative = redeemed
  TextColumn get description => text()();
  IntColumn  get createdAt   => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

// ─── 11. SyncQueue (Outbox Pattern) ──────────────────────────────────────────
class SyncQueue extends Table {
  TextColumn get id           => text()();
  TextColumn get targetTable  => text()();
  TextColumn get operation    => text()(); // INSERT, UPDATE, DELETE
  TextColumn get payloadJson  => text()();
  IntColumn  get createdAt    => integer()();
  TextColumn get syncStatus   => textEnum<SyncStatus>().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

// ─── 12. StockItems (Raw ingredients in inventory) ───────────────────────────
class StockItems extends Table {
  TextColumn get id          => text()();
  TextColumn get name        => text()();
  TextColumn get unit        => text()(); // 'un', 'kg', 'g', 'l', 'ml'
  RealColumn get quantity    => real().withDefault(const Constant(0.0))(); // current stock level
  RealColumn get unitWeight  => real().nullable()(); // weight in grams if applicable (e.g. 50g per unit)
  RealColumn get costPrice   => real()(); // cost price per unit/kg
  RealColumn get alertMinQty => real().withDefault(const Constant(5.0))();
  IntColumn  get updatedAt   => integer()();
  
  @override
  Set<Column> get primaryKey => {id};
}

// ─── 13. StockPriceHistory (For tracking price evolution) ────────────────────
class StockPriceHistory extends Table {
  TextColumn get id          => text()();
  TextColumn get stockItemId => text().references(StockItems, #id)();
  RealColumn get costPrice   => real()();
  IntColumn  get recordedAt  => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

// ─── 14. ProductRecipes (Specs connecting Menu Product -> Stock Items) ─────────
class ProductRecipes extends Table {
  TextColumn get id          => text()();
  TextColumn get productId   => text().references(Products, #id)();
  TextColumn get stockItemId => text().references(StockItems, #id)();
  RealColumn get quantity    => real()(); // e.g. 0.150 for 150g, 1.0 for 1 unit
  IntColumn  get updatedAt   => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

// ─── 15. WasteRecords (For registering spoilage) ─────────────────────────────
class WasteRecords extends Table {
  TextColumn get id          => text()();
  TextColumn get stockItemId => text().references(StockItems, #id)();
  RealColumn get quantity    => real()();
  TextColumn get reason      => text()(); // 'expired', 'spoiled', etc.
  RealColumn get costLost    => real()(); // quantity * costPrice
  IntColumn  get recordedAt  => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

// ─── 16. UnpaidOrders (Fiado / Pendente) ─────────────────────────────────────
class UnpaidOrders extends Table {
  TextColumn get id           => text()();
  TextColumn get orderId      => text().references(Orders, #id)();
  TextColumn get customerName => text()();
  RealColumn get amount       => real()();
  IntColumn  get createdAt    => integer()();
  TextColumn get status       => text().withDefault(const Constant('pending'))(); // pending, paid

  @override
  Set<Column> get primaryKey => {id};
}