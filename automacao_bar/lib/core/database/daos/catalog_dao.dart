import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../tables.dart';

part 'catalog_dao.g.dart';

@DriftAccessor(tables: [Categories, Products])
class CatalogDao extends DatabaseAccessor<AppDatabase> with _$CatalogDaoMixin {
  CatalogDao(super.db);

  Stream<List<Category>> watchCategories() {
    return (select(categories)
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder), (c) => OrderingTerm.asc(c.name)]))
        .watch();
  }

  Stream<List<Product>> watchProductsByCategory(String categoryId) {
    return (select(products)
          ..where((p) => p.categoryId.equals(categoryId) & p.isActive.equals(true))
          ..orderBy([(p) => OrderingTerm.asc(p.name)]))
        .watch();
  }

  Future<void> insertCategory(String name) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = const Uuid().v7();
    await into(categories).insert(
      CategoriesCompanion.insert(
        id: id,
        name: name,
        updatedAt: now,
      ),
    );
  }

  Future<void> insertProduct({
    required String categoryId,
    required String name,
    required double price,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = const Uuid().v7();
    await into(products).insert(
      ProductsCompanion.insert(
        id: id,
        categoryId: categoryId,
        name: name,
        price: price,
        updatedAt: now,
      ),
    );
  }
}
