import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../tables.dart';

part 'inventory_dao.g.dart';

/// Product balance DTO — combines product metadata with computed stock balance
class ProductBalance {
  final Product product;
  final double balance;
  final String? categoryName;

  const ProductBalance({
    required this.product,
    required this.balance,
    this.categoryName,
  });

  bool get isLowStock => balance < product.minStock && product.minStock > 0;
}

@DriftAccessor(tables: [
  Products,
  Categories,
  InventoryMovements,
  SyncQueue,
  StockItems,
  StockPriceHistory,
  ProductRecipes,
  WasteRecords,
  OrderItems,
])
class InventoryDao extends DatabaseAccessor<AppDatabase> with _$InventoryDaoMixin {
  InventoryDao(super.db);

  // ── Queries ─────────────────────────────────────────────────────────────────

  /// Stream: Real-time balance for a single product (SUM of deltas)
  Stream<double> watchProductBalance(String productId) {
    final query = customSelect(
      'SELECT COALESCE(SUM(delta), 0.0) AS balance FROM inventory_movements WHERE product_id = ?',
      variables: [Variable.withString(productId)],
      readsFrom: {inventoryMovements},
    );
    return query.watchSingle().map((row) => row.read<double>('balance'));
  }

  /// Stream: All active products with their computed balances
  Stream<List<ProductBalance>> watchAllProductBalances() {
    final query = customSelect(
      '''
      SELECT 
        p.id, p.category_id, p.name, p.price, p.min_stock, 
        p.description, p.is_active, p.updated_at,
        COALESCE(SUM(m.delta), 0.0) AS balance,
        c.name AS category_name
      FROM products p
      LEFT JOIN inventory_movements m ON m.product_id = p.id
      LEFT JOIN categories c ON c.id = p.category_id
      WHERE p.is_active = 1
      GROUP BY p.id
      ORDER BY p.name ASC
      ''',
      readsFrom: {products, inventoryMovements, categories},
    );

    return query.watch().map((rows) => rows.map((row) {
      final product = Product(
        id: row.read<String>('id'),
        categoryId: row.read<String>('category_id'),
        name: row.read<String>('name'),
        price: row.read<double>('price'),
        minStock: row.read<double>('min_stock'),
        description: row.readNullable<String>('description'),
        isActive: row.read<bool>('is_active'),
        updatedAt: row.read<int>('updated_at'),
      );
      return ProductBalance(
        product: product,
        balance: row.read<double>('balance'),
        categoryName: row.readNullable<String>('category_name'),
      );
    }).toList());
  }

  /// Stream: Only products where balance < minStock
  Stream<List<ProductBalance>> watchLowStockProducts() {
    return watchAllProductBalances().map(
      (list) => list.where((pb) => pb.isLowStock).toList(),
    );
  }

  /// Stream: Movement history for a product
  Stream<List<InventoryMovement>> watchMovementsForProduct(String productId) {
    return (select(inventoryMovements)
          ..where((m) => m.productId.equals(productId))
          ..orderBy([(m) => OrderingTerm.desc(m.createdAt)]))
        .watch();
  }

  /// Stream: Recent movements (all products)
  Stream<List<InventoryMovement>> watchRecentMovements({int limit = 50}) {
    return (select(inventoryMovements)
          ..orderBy([(m) => OrderingTerm.desc(m.createdAt)])
          ..limit(limit))
        .watch();
  }

  // ── Commands ─────────────────────────────────────────────────────────────────

  /// Insert a single stock movement (positive = entrada, negative = saída)
  Future<void> insertMovement({
    required String productId,
    required double delta,
    required String reason,
    String? userId,
    String? orderId,
    String? notes,
  }) async {
    final movementId = const Uuid().v7();
    final syncId = const Uuid().v7();
    final now = DateTime.now().millisecondsSinceEpoch;

    await transaction(() async {
      await into(inventoryMovements).insert(
        InventoryMovementsCompanion.insert(
          id: movementId,
          productId: productId,
          delta: delta,
          reason: reason,
          userId: Value(userId),
          orderId: Value(orderId),
          notes: Value(notes),
          createdAt: now,
        ),
      );

      await into(syncQueue).insert(
        SyncQueueCompanion.insert(
          id: syncId,
          targetTable: 'inventory_movements',
          operation: 'INSERT',
          payloadJson: jsonEncode({
            'id': movementId,
            'product_id': productId,
            'delta': delta,
            'reason': reason,
            'user_id': userId,
            'order_id': orderId,
            'notes': notes,
            'created_at': now,
          }),
          createdAt: now,
          syncStatus: const Value(SyncStatus.pending),
        ),
      );
    });
  }

  /// Bulk insert movements (used when closing an order)
  Future<void> insertMovementsForOrder({
    required String orderId,
    required List<Map<String, dynamic>> items, // [{productId, quantity}]
    String? userId,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    await transaction(() async {
      for (final item in items) {
        final productId = item['productId'] as String;
        final quantity = (item['quantity'] as num).toDouble();
        final movementId = const Uuid().v7();
        final syncId = const Uuid().v7();

        await into(inventoryMovements).insert(
          InventoryMovementsCompanion.insert(
            id: movementId,
            productId: productId,
            delta: -quantity, // negative = saída/venda
            reason: 'venda',
            userId: Value(userId),
            orderId: Value(orderId),
            createdAt: now,
          ),
        );

        await into(syncQueue).insert(
          SyncQueueCompanion.insert(
            id: syncId,
            targetTable: 'inventory_movements',
            operation: 'INSERT',
            payloadJson: jsonEncode({
              'id': movementId,
              'product_id': productId,
              'delta': -quantity,
              'reason': 'venda',
              'order_id': orderId,
              'user_id': userId,
              'created_at': now,
            }),
            createdAt: now,
            syncStatus: const Value(SyncStatus.pending),
          ),
        );
      }
    });
  }

  // ── Stock Items & Recipes Queries ──────────────────────────────────────────

  Stream<List<StockItem>> watchAllStockItems() {
    return select(stockItems).watch();
  }

  Stream<StockItem> watchStockItem(String id) {
    return (select(stockItems)..where((s) => s.id.equals(id))).watchSingle();
  }

  Stream<List<StockPriceHistoryData>> watchPriceHistory(String stockItemId) {
    return (select(stockPriceHistory)
          ..where((h) => h.stockItemId.equals(stockItemId))
          ..orderBy([(h) => OrderingTerm.desc(h.recordedAt)]))
        .watch();
  }

  Stream<List<WasteRecord>> watchAllWasteRecords() {
    return (select(wasteRecords)
          ..orderBy([(w) => OrderingTerm.desc(w.recordedAt)]))
        .watch();
  }

  Stream<List<ProductRecipe>> watchRecipesForProduct(String productId) {
    return (select(productRecipes)
          ..where((r) => r.productId.equals(productId)))
        .watch();
  }

  // ── Stock Items & Recipes Commands ─────────────────────────────────────────

  Future<void> insertStockItem(StockItem stockItem) async {
    final historyId = const Uuid().v7();
    final now = DateTime.now().millisecondsSinceEpoch;

    await transaction(() async {
      await into(stockItems).insert(stockItem);
      await into(stockPriceHistory).insert(
        StockPriceHistoryCompanion.insert(
          id: historyId,
          stockItemId: stockItem.id,
          costPrice: stockItem.costPrice,
          recordedAt: now,
        ),
      );
    });
  }

  Future<void> updateStockItemCost(String stockItemId, double newCostPrice) async {
    final historyId = const Uuid().v7();
    final now = DateTime.now().millisecondsSinceEpoch;

    await transaction(() async {
      await (update(stockItems)..where((s) => s.id.equals(stockItemId))).write(
        StockItemsCompanion(
          costPrice: Value(newCostPrice),
          updatedAt: Value(now),
        ),
      );

      await into(stockPriceHistory).insert(
        StockPriceHistoryCompanion.insert(
          id: historyId,
          stockItemId: stockItemId,
          costPrice: newCostPrice,
          recordedAt: now,
        ),
      );
    });
  }

  Future<void> addStockQuantity(String stockItemId, double delta) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await transaction(() async {
      final item = await (select(stockItems)..where((s) => s.id.equals(stockItemId))).getSingle();
      await (update(stockItems)..where((s) => s.id.equals(stockItemId))).write(
        StockItemsCompanion(
          quantity: Value(item.quantity + delta),
          updatedAt: Value(now),
        ),
      );
    });
  }

  Future<void> registerWaste({
    required String stockItemId,
    required double quantity,
    required String reason,
  }) async {
    final id = const Uuid().v7();
    final now = DateTime.now().millisecondsSinceEpoch;

    await transaction(() async {
      final item = await (select(stockItems)..where((s) => s.id.equals(stockItemId))).getSingle();
      final costLost = quantity * item.costPrice;

      await into(wasteRecords).insert(
        WasteRecordsCompanion.insert(
          id: id,
          stockItemId: stockItemId,
          quantity: quantity,
          reason: reason,
          costLost: costLost,
          recordedAt: now,
        ),
      );

      await (update(stockItems)..where((s) => s.id.equals(stockItemId))).write(
        StockItemsCompanion(
          quantity: Value(item.quantity - quantity),
          updatedAt: Value(now),
        ),
      );
    });
  }

  Future<void> saveRecipe(String productId, List<ProductRecipesCompanion> ingredients) async {
    await transaction(() async {
      // 1. Delete old ingredients
      await (delete(productRecipes)..where((r) => r.productId.equals(productId))).go();

      // 2. Insert new ingredients
      for (final ing in ingredients) {
        await into(productRecipes).insert(ing);
      }
    });
  }

  /// Deduct stock items from recipe when order items are sold
  Future<void> deductStockForOrder(String orderId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await transaction(() async {
      // Get all items in the order
      final items = await (select(orderItems)..where((oi) => oi.orderId.equals(orderId))).get();
      for (final item in items) {
        // Get recipe for product
        final recipeList = await (select(productRecipes)..where((r) => r.productId.equals(item.productId))).get();
        for (final recipe in recipeList) {
          final totalQtyToDeduct = recipe.quantity * item.quantity;
          final stockItem = await (select(stockItems)..where((s) => s.id.equals(recipe.stockItemId))).getSingle();
          await (update(stockItems)..where((s) => s.id.equals(recipe.stockItemId))).write(
            StockItemsCompanion(
              quantity: Value(stockItem.quantity - totalQtyToDeduct),
              updatedAt: Value(now),
            ),
          );
        }
      }
    });
  }
}
