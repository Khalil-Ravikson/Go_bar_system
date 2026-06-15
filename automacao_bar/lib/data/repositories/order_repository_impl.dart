import '../../core/database/app_database.dart';
import '../../core/database/daos/orders_dao.dart';
import '../../domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements IOrderRepository {
  final OrdersDao _ordersDao;

  OrderRepositoryImpl(this._ordersDao);

  @override
  Stream<List<Order>> watchActiveOrders() => _ordersDao.watchActiveOrders();

  @override
  Stream<List<OrderItem>> watchOrderItems(String orderId) => _ordersDao.watchOrderItems(orderId);

  @override
  Future<void> openOrder(String orderId, String tableId) => _ordersDao.openOrder(orderId, tableId);

  @override
  Future<void> addOrderItem({
    required String orderId,
    required String productId,
    required double quantity,
    required double unitPrice,
    String? notes,
  }) {
    return _ordersDao.addOrderItem(
      orderId: orderId,
      productId: productId,
      quantity: quantity,
      unitPrice: unitPrice,
      notes: notes,
    );
  }

  @override
  Future<void> closeOrder(String orderId) => _ordersDao.closeOrder(orderId);
}
