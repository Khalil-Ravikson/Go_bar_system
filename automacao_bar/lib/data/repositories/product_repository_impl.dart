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
  Future<void> insertProduct(Product product) => _productsDao.insertProduct(product);

  @override
  Future<void> insertCategory(Category category) => _productsDao.insertCategory(category);
}
