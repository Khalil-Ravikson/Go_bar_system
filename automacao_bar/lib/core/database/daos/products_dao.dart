import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../tables.dart';

part 'products_dao.g.dart';

@DriftAccessor(tables: [Products, Categories, SyncQueue])
class ProductsDao extends DatabaseAccessor<AppDatabase> with _$ProductsDaoMixin {
  ProductsDao(super.db);

  // ── Product Streams ──────────────────────────────────────────────────────────

  Stream<List<Product>> watchAllActiveProducts() {
    return (select(products)
          ..where((p) => p.isActive.equals(true))
          ..orderBy([(p) => OrderingTerm.asc(p.name)]))
        .watch();
  }

  /// Alias kept for backward compatibility
  Stream<List<Product>> watchActiveProducts() => watchAllActiveProducts();

  Stream<List<Product>> watchProductsByCategory(String categoryId) {
    return (select(products)
          ..where((p) => p.categoryId.equals(categoryId) & p.isActive.equals(true))
          ..orderBy([(p) => OrderingTerm.asc(p.name)]))
        .watch();
  }

  Future<List<Product>> searchProducts(String query) {
    return (select(products)
          ..where((p) => p.name.like('%$query%') & p.isActive.equals(true))
          ..orderBy([(p) => OrderingTerm.asc(p.name)]))
        .get();
  }

  Future<Product?> getProductById(String id) {
    return (select(products)..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  // ── Category Streams ─────────────────────────────────────────────────────────

  Stream<List<Category>> watchActiveCategories() {
    return (select(categories)
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder), (c) => OrderingTerm.asc(c.name)]))
        .watch();
  }

  Future<List<Category>> getAllCategories() {
    return (select(categories)
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder), (c) => OrderingTerm.asc(c.name)]))
        .get();
  }

  // ── Product Commands ─────────────────────────────────────────────────────────

  Future<String> insertProduct({
    required String categoryId,
    required String name,
    required double price,
    double minStock = 0.0,
    String? description,
  }) async {
    final id = const Uuid().v7();
    final syncId = const Uuid().v7();
    final now = DateTime.now().millisecondsSinceEpoch;

    await transaction(() async {
      await into(products).insert(
        ProductsCompanion.insert(
          id: id,
          categoryId: categoryId,
          name: name,
          price: price,
          minStock: Value(minStock),
          description: Value(description),
          updatedAt: now,
        ),
      );

      await into(syncQueue).insert(
        SyncQueueCompanion.insert(
          id: syncId,
          targetTable: 'products',
          operation: 'INSERT',
          payloadJson: jsonEncode({
            'id': id,
            'category_id': categoryId,
            'name': name,
            'price': price,
            'min_stock': minStock,
            'description': description,
            'updated_at': now,
          }),
          createdAt: now,
          syncStatus: const Value(SyncStatus.pending),
        ),
      );
    });

    return id;
  }

  Future<void> updateProduct({
    required String id,
    String? categoryId,
    String? name,
    double? price,
    double? minStock,
    String? description,
    bool? isActive,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    await transaction(() async {
      await (update(products)..where((p) => p.id.equals(id))).write(
        ProductsCompanion(
          categoryId: categoryId != null ? Value(categoryId) : const Value.absent(),
          name: name != null ? Value(name) : const Value.absent(),
          price: price != null ? Value(price) : const Value.absent(),
          minStock: minStock != null ? Value(minStock) : const Value.absent(),
          description: description != null ? Value(description) : const Value.absent(),
          isActive: isActive != null ? Value(isActive) : const Value.absent(),
          updatedAt: Value(now),
        ),
      );

      await into(syncQueue).insert(
        SyncQueueCompanion.insert(
          id: const Uuid().v7(),
          targetTable: 'products',
          operation: 'UPDATE',
          payloadJson: jsonEncode({'id': id, 'updated_at': now}),
          createdAt: now,
          syncStatus: const Value(SyncStatus.pending),
        ),
      );
    });
  }

  Future<void> deleteProduct(String id) async {
    // Soft delete
    await updateProduct(id: id, isActive: false);
  }

  // ── Category Commands ────────────────────────────────────────────────────────

  Future<String> insertCategory({
    required String name,
    String? colorCode,
    int sortOrder = 0,
  }) async {
    final id = const Uuid().v7();
    final syncId = const Uuid().v7();
    final now = DateTime.now().millisecondsSinceEpoch;

    await transaction(() async {
      await into(categories).insert(
        CategoriesCompanion.insert(
          id: id,
          name: name,
          colorCode: Value(colorCode),
          sortOrder: Value(sortOrder),
          updatedAt: now,
        ),
      );

      await into(syncQueue).insert(
        SyncQueueCompanion.insert(
          id: syncId,
          targetTable: 'categories',
          operation: 'INSERT',
          payloadJson: jsonEncode({
            'id': id,
            'name': name,
            'color_code': colorCode,
            'sort_order': sortOrder,
            'updated_at': now,
          }),
          createdAt: now,
          syncStatus: const Value(SyncStatus.pending),
        ),
      );
    });

    return id;
  }

  Future<void> updateCategory({
    required String id,
    String? name,
    String? colorCode,
    int? sortOrder,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (update(categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        colorCode: colorCode != null ? Value(colorCode) : const Value.absent(),
        sortOrder: sortOrder != null ? Value(sortOrder) : const Value.absent(),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> deleteCategory(String id) async {
    await (delete(categories)..where((c) => c.id.equals(id))).go();
  }
}
