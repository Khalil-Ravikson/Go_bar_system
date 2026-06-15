import '../../core/database/app_database.dart';

abstract class IProductRepository {
  Stream<List<Product>> watchActiveProducts();
  Stream<List<Product>> watchProductsByCategory(String categoryId);
  Stream<List<Category>> watchActiveCategories();
  Future<void> insertProduct(Product product);
  Future<void> insertCategory(Category category);
}
