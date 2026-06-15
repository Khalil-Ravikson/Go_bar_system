import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../tables.dart';

part 'catalog_dao.g.dart';

@DriftAccessor(tables: [Categories, Products])
class CatalogDao extends DatabaseAccessor<AppDatabase> with _$CatalogDaoMixin {
  CatalogDao(super.db);

  Stream<List<Category>> watchCategories() {
    return select(categories).watch();
  }

  Stream<List<Product>> watchProductsByCategory(String categoryId) {
    return (select(products)..where((tbl) => tbl.categoryId.equals(categoryId))).watch();
  }

  Future<void> insertCategory(String name, String tenantId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final uuid = const Uuid().v7();
    await into(categories).insert(
      Category(
        id: uuid,
        name: name,
        colorCode: null,
        updatedAt: now,
      ),
    );
  }

  Future<void> insertProduct({
    required String tenantId,
    required String categoryId,
    required String name,
    required int currentPrice,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final uuid = const Uuid().v7();
    await into(products).insert(
      Product(
        id: uuid,
        categoryId: categoryId,
        name: name,
        price: currentPrice / 100.0,
        stockQty: 0,
        minStock: 0,
        isActive: true,
        updatedAt: now,
        currentPrice: currentPrice,
      ),
    );
  }
}
