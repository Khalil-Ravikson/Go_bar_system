import '../../core/database/app_database.dart';
import '../../core/database/daos/products_dao.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements IProductRepository {
  final ProductsDao _productsDao;

  ProductRepositoryImpl(this._productsDao);

  @override
  Stream<List<Product>> watchActiveProducts() => _productsDao.watchActiveProducts();

  @override
  Stream<List<Product>> watchProductsByCategory(String categoryId) =>
      _productsDao.watchProductsByCategory(categoryId);

  @override
  Stream<List<Category>> watchActiveCategories() => _productsDao.watchActiveCategories();

  @override
  Future<String> insertProduct({
    required String categoryId,
    required String name,
    required double price,
    double minStock = 0.0,
    String? description,
  }) =>
      _productsDao.insertProduct(
        categoryId: categoryId,
        name: name,
        price: price,
        minStock: minStock,
        description: description,
      );

  @override
  Future<String> insertCategory({
    required String name,
    String? colorCode,
    int sortOrder = 0,
  }) =>
      _productsDao.insertCategory(
        name: name,
        colorCode: colorCode,
        sortOrder: sortOrder,
      );

  @override
  Future<void> updateProduct({
    required String id,
    String? categoryId,
    String? name,
    double? price,
    double? minStock,
    String? description,
    bool? isActive,
  }) =>
      _productsDao.updateProduct(
        id: id,
        categoryId: categoryId,
        name: name,
        price: price,
        minStock: minStock,
        description: description,
        isActive: isActive,
      );

  @override
  Future<void> deleteProduct(String id) => _productsDao.deleteProduct(id);
}
