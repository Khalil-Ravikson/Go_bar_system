import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../tables.dart';

part 'catalog_dao.g.dart';

@DriftAccessor(tables: [Categories, Products])
class CatalogDao extends DatabaseAccessor<AppDatabase> with _$CatalogDaoMixin {
  CatalogDao(AppDatabase db) : super(db);

  // ==========================================
  // MÉTODOS DE LEITURA (O Salão)
  // ==========================================

  /// Retorna todas as categorias ativas em tempo real
  Stream<List<Category>> watchCategories() {
    return (select(categories)
          ..where((tbl) => tbl.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  /// Retorna todos os produtos ativos de uma categoria específica
  Stream<List<Product>> watchProductsByCategory(String categoryId) {
    return (select(products)
          ..where((tbl) => tbl.categoryId.equals(categoryId))
          ..where((tbl) => tbl.isAvailable.equals(true)) // Só exibe se tiver em estoque
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  // ==========================================
  // MÉTODOS DE ESCRITA (A Gestão Manual)
  // ==========================================

  /// Insere uma nova categoria
  Future<void> insertCategory(String name, String tenantId) async {
    final uuid = const Uuid().v7(); // ID gerado no cliente
    
    await into(categories).insert(
      CategoriesCompanion.insert(
        id: uuid,
        tenantId: tenantId,
        name: name,
        isActive: const Value(true), // Ativo por padrão
      ),
    );
  }

  /// Insere um novo produto
  Future<void> insertProduct({
    required String tenantId,
    required String categoryId,
    required String name,
    required int currentPrice, // Em centavos para evitar erro de float
  }) async {
    final uuid = const Uuid().v7();
    
    await into(products).insert(
      ProductsCompanion.insert(
        id: uuid,
        tenantId: tenantId,
        categoryId: categoryId,
        name: name,
        currentPrice: currentPrice,
        isAvailable: const Value(true), // Em estoque por padrão
      ),
    );
  }
}