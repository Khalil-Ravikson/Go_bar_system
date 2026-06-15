import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../tables.dart';

part 'products_dao.g.dart';

@DriftAccessor(tables: [Products, Categories, SyncQueue])
class ProductsDao extends DatabaseAccessor<AppDatabase> with _$ProductsDaoMixin {
  ProductsDao(super.db);

  Stream<List<Product>> watchActiveProducts() {
    return (select(products)..where((tbl) => tbl.isActive.equals(true))).watch();
  }

  Stream<List<Product>> watchProductsByCategory(String categoryId) {
    return (select(products)
          ..where((tbl) => tbl.categoryId.equals(categoryId))
          ..where((tbl) => tbl.isActive.equals(true)))
        .watch();
  }

  Stream<List<Category>> watchActiveCategories() {
    return select(categories).watch();
  }

  Future<void> insertProduct(Product product) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final syncId = const Uuid().v7();

    await transaction(() async {
      await into(products).insert(product);

      final payload = {
        'id': product.id,
        'category_id': product.categoryId,
        'name': product.name,
        'price': product.price,
        'stock_qty': product.stockQty,
        'min_stock': product.minStock,
        'is_active': product.isActive,
        'updated_at': now,
      };

      await into(syncQueue).insert(
        SyncQueueCompanion.insert(
          id: syncId,
          targetTable: 'products',
          operation: 'INSERT',
          payloadJson: jsonEncode(payload),
          createdAt: now,
          syncStatus: const Value(SyncStatus.pending),
        ),
      );
    });
  }

  Future<void> insertCategory(Category category) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final syncId = const Uuid().v7();

    await transaction(() async {
      await into(categories).insert(category);

      final payload = {
        'id': category.id,
        'name': category.name,
        'color_code': category.colorCode,
        'updated_at': now,
      };

      await into(syncQueue).insert(
        SyncQueueCompanion.insert(
          id: syncId,
          targetTable: 'categories',
          operation: 'INSERT',
          payloadJson: jsonEncode(payload),
          createdAt: now,
          syncStatus: const Value(SyncStatus.pending),
        ),
      );
    });
  }
}
