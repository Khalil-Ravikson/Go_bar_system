import '../../core/database/app_database.dart';

abstract class IProductRepository {
  Stream<List<Product>> watchActiveProducts();
  Stream<List<Product>> watchProductsByCategory(String categoryId);
  Stream<List<Category>> watchActiveCategories();
  Future<String> insertProduct({
    required String categoryId,
    required String name,
    required double price,
    double minStock,
    String? description,
  });
  Future<String> insertCategory({
    required String name,
    String? colorCode,
    int sortOrder,
  });
  Future<void> updateProduct({
    required String id,
    String? categoryId,
    String? name,
    double? price,
    double? minStock,
    String? description,
    bool? isActive,
  });
  Future<void> deleteProduct(String id);
}
