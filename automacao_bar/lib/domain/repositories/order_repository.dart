import '../../core/database/app_database.dart';

abstract class IOrderRepository {
  Stream<List<Order>> watchActiveOrders();
  Stream<List<OrderItem>> watchOrderItems(String orderId);
  Future<void> openOrder(String orderId, String tableId);
  Future<void> addOrderItem({
    required String orderId,
    required String productId,
    required double quantity,
    required double unitPrice,
    String? notes,
  });
  Future<void> closeOrder(String orderId);
}
