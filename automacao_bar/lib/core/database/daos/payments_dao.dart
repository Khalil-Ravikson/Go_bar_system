import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../tables.dart';

part 'payments_dao.g.dart';

/// Aggregated revenue summary for dashboard
class RevenueSummary {
  final double totalToday;
  final double totalYesterday;
  final int ordersToday;
  final double averageTicket;
  final Map<String, double> byPaymentMethod;

  const RevenueSummary({
    required this.totalToday,
    required this.totalYesterday,
    required this.ordersToday,
    required this.averageTicket,
    required this.byPaymentMethod,
  });
}

class HourlySalesBucket {
  final int hour;
  final double total;
  const HourlySalesBucket({required this.hour, required this.total});
}

@DriftAccessor(tables: [
  Payments,
  Orders,
  OrderItems,
  Products,
  Categories,
  SyncQueue,
  UnpaidOrders,
])
class PaymentsDao extends DatabaseAccessor<AppDatabase> with _$PaymentsDaoMixin {
  PaymentsDao(super.db);

  // ── Queries ─────────────────────────────────────────────────────────────────

  Stream<List<Payment>> watchPaymentsForOrder(String orderId) {
    return (select(payments)..where((p) => p.orderId.equals(orderId))).watch();
  }

  /// Stream: revenue for today (epoch-based date comparison)
  Stream<double> watchRevenueToday() {
    final todayStart = _todayStartMs();
    final todayEnd = _todayEndMs();
    final query = customSelect(
      '''SELECT COALESCE(SUM(amount), 0.0) AS total 
         FROM payments 
         WHERE paid_at >= ? AND paid_at < ?''',
      variables: [Variable.withInt(todayStart), Variable.withInt(todayEnd)],
      readsFrom: {payments},
    );
    return query.watchSingle().map((row) => row.read<double>('total'));
  }

  /// Stream: revenue for yesterday
  Stream<double> watchRevenueYesterday() {
    final start = _todayStartMs() - const Duration(days: 1).inMilliseconds;
    final end = _todayStartMs();
    final query = customSelect(
      '''SELECT COALESCE(SUM(amount), 0.0) AS total 
         FROM payments 
         WHERE paid_at >= ? AND paid_at < ?''',
      variables: [Variable.withInt(start), Variable.withInt(end)],
      readsFrom: {payments},
    );
    return query.watchSingle().map((row) => row.read<double>('total'));
  }

  /// Stream: order count today (orders with at least one payment)
  Stream<int> watchOrderCountToday() {
    final todayStart = _todayStartMs();
    final todayEnd = _todayEndMs();
    final query = customSelect(
      '''SELECT COUNT(DISTINCT order_id) AS cnt 
         FROM payments 
         WHERE paid_at >= ? AND paid_at < ?''',
      variables: [Variable.withInt(todayStart), Variable.withInt(todayEnd)],
      readsFrom: {payments},
    );
    return query.watchSingle().map((row) => row.read<int>('cnt'));
  }

  /// Stream: order count yesterday
  Stream<int> watchOrderCountYesterday() {
    final start = _todayStartMs() - const Duration(days: 1).inMilliseconds;
    final end = _todayStartMs();
    final query = customSelect(
      '''SELECT COUNT(DISTINCT order_id) AS cnt 
         FROM payments 
         WHERE paid_at >= ? AND paid_at < ?''',
      variables: [Variable.withInt(start), Variable.withInt(end)],
      readsFrom: {payments},
    );
    return query.watchSingle().map((row) => row.read<int>('cnt'));
  }

  /// Revenue grouped by payment method for today
  Stream<Map<String, double>> watchRevenueByMethodToday() {
    final todayStart = _todayStartMs();
    final todayEnd = _todayEndMs();
    final query = customSelect(
      '''SELECT method, COALESCE(SUM(amount), 0.0) AS total 
         FROM payments 
         WHERE paid_at >= ? AND paid_at < ?
         GROUP BY method''',
      variables: [Variable.withInt(todayStart), Variable.withInt(todayEnd)],
      readsFrom: {payments},
    );
    return query.watch().map((rows) {
      final result = <String, double>{};
      for (final row in rows) {
        result[row.read<String>('method')] = row.read<double>('total');
      }
      return result;
    });
  }

  /// Stream: top 5 products by quantity sold today
  Stream<List<Map<String, dynamic>>> watchTopProductsToday() {
    final todayStart = _todayStartMs();
    final todayEnd = _todayEndMs();
    final query = customSelect(
      '''SELECT 
           p.id AS product_id,
           p.name AS product_name,
           SUM(oi.quantity) AS total_qty,
           SUM(oi.quantity * oi.unit_price) AS total_revenue
         FROM order_items oi
         JOIN orders o ON o.id = oi.order_id
         JOIN products p ON p.id = oi.product_id
         WHERE o.closed_at >= ? AND o.closed_at < ? AND o.status = 'fechado'
         GROUP BY oi.product_id
         ORDER BY total_qty DESC
         LIMIT 5''',
      variables: [Variable.withInt(todayStart), Variable.withInt(todayEnd)],
      readsFrom: {payments, orders},
    );
    return query.watch().map((rows) => rows.map((row) => {
      'productId': row.read<String>('product_id'),
      'name': row.read<String>('product_name'),
      'qty': row.read<double>('total_qty'),
      'total': row.read<double>('total_revenue'),
    }).toList());
  }

  /// Stream: Category sales today
  Stream<List<Map<String, dynamic>>> watchCategorySalesToday() {
    final todayStart = _todayStartMs();
    final todayEnd = _todayEndMs();
    final query = customSelect(
      '''SELECT 
           c.name AS category_name,
           c.color_code AS category_color,
           COALESCE(SUM(oi.quantity * oi.unit_price), 0.0) AS total_revenue
         FROM order_items oi
         JOIN orders o ON o.id = oi.order_id
         JOIN products p ON p.id = oi.product_id
         JOIN categories c ON c.id = p.category_id
         WHERE o.closed_at >= ? AND o.closed_at < ? AND o.status = 'fechado'
         GROUP BY p.category_id''',
      variables: [Variable.withInt(todayStart), Variable.withInt(todayEnd)],
      readsFrom: {orders, orderItems, products, categories},
    );
    return query.watch().map((rows) => rows.map((row) => {
      'name': row.read<String>('category_name'),
      'total': row.read<double>('total_revenue'),
      'color': int.tryParse(row.readNullable<String>('category_color')?.replaceFirst('#', '0xFF') ?? '') ?? 0xFF00FF88,
    }).toList());
  }

  /// Stream: Hourly sales
  Stream<List<HourlySalesBucket>> watchSalesPerHour(int startMs, int endMs) {
    final query = customSelect(
      '''SELECT 
           CAST(strftime('%H', datetime(paid_at / 1000, 'unixepoch', 'localtime')) AS INTEGER) AS hr,
           COALESCE(SUM(amount), 0.0) AS total
         FROM payments
         WHERE paid_at >= ? AND paid_at < ?
         GROUP BY hr
         ORDER BY hr ASC''',
      variables: [Variable.withInt(startMs), Variable.withInt(endMs)],
      readsFrom: {payments},
    );
    return query.watch().map((rows) {
      return rows.map((row) {
        final hr = row.read<int>('hr');
        final total = row.read<double>('total');
        return HourlySalesBucket(hour: hr, total: total);
      }).toList();
    });
  }

  // ── Commands ─────────────────────────────────────────────────────────────────

  /// Insert payment and close order + update inventory via transaction
  Future<void> processPayment({
    required String orderId,
    required String method,
    required double amount,
    String? notes,
    String? customerId,
    List<Map<String, dynamic>> orderItems = const [],
    String? serverId,
  }) async {
    final paymentId = const Uuid().v7();
    final syncId = const Uuid().v7();
    final now = DateTime.now().millisecondsSinceEpoch;

    await transaction(() async {
      // 1. Insert payment record
      await into(payments).insert(
        PaymentsCompanion.insert(
          id: paymentId,
          orderId: orderId,
          method: method,
          amount: amount,
          notes: Value(notes),
          paidAt: now,
          updatedAt: now,
        ),
      );

      // 2. Close the order
      await (update(orders)..where((o) => o.id.equals(orderId))).write(
        OrdersCompanion(
          status: const Value('fechado'),
          closedAt: Value(now),
          paymentMethod: Value(method),
          updatedAt: Value(now),
        ),
      );

      // 3. Sync queue entries
      await into(syncQueue).insert(
        SyncQueueCompanion.insert(
          id: syncId,
          targetTable: 'payments',
          operation: 'INSERT',
          payloadJson: jsonEncode({
            'id': paymentId,
            'order_id': orderId,
            'method': method,
            'amount': amount,
            'notes': notes,
            'paid_at': now,
          }),
          createdAt: now,
          syncStatus: const Value(SyncStatus.pending),
        ),
      );
    });
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  int _todayStartMs() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
  }

  int _todayEndMs() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1).millisecondsSinceEpoch;
  }

  // ── Unpaid Orders Queries ──────────────────────────────────────────────────

  Stream<List<UnpaidOrder>> watchUnpaidOrders() {
    return select(unpaidOrders).watch();
  }

  Stream<List<UnpaidOrder>> watchPendingUnpaidOrders() {
    return (select(unpaidOrders)..where((u) => u.status.equals('pending'))).watch();
  }

  // ── Unpaid Orders Commands ─────────────────────────────────────────────────

  Future<void> processUnpaidCheckout({
    required String orderId,
    required String customerName,
    required double amount,
  }) async {
    final unpaidId = const Uuid().v7();
    final now = DateTime.now().millisecondsSinceEpoch;

    await transaction(() async {
      // 1. Insert Unpaid Order record
      await into(unpaidOrders).insert(
        UnpaidOrdersCompanion.insert(
          id: unpaidId,
          orderId: orderId,
          customerName: customerName,
          amount: amount,
          createdAt: now,
          status: const Value('pending'),
        ),
      );

      // 2. Close order with status 'fechado' and 'fiado' payment method
      await (update(orders)..where((o) => o.id.equals(orderId))).write(
        OrdersCompanion(
          status: const Value('fechado'),
          closedAt: Value(now),
          paymentMethod: const Value('fiado'),
          updatedAt: Value(now),
        ),
      );

      // 3. Sync queue
      await into(syncQueue).insert(
        SyncQueueCompanion.insert(
          id: const Uuid().v7(),
          targetTable: 'unpaid_orders',
          operation: 'INSERT',
          payloadJson: jsonEncode({
            'id': unpaidId,
            'order_id': orderId,
            'customer_name': customerName,
            'amount': amount,
            'created_at': now,
            'status': 'pending',
          }),
          createdAt: now,
          syncStatus: const Value(SyncStatus.pending),
        ),
      );
    });
  }

  Future<void> markUnpaidOrderAsPaid({
    required String unpaidOrderId,
    required String paymentMethod,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await transaction(() async {
      // 1. Get unpaid order info
      final unpaid = await (select(unpaidOrders)..where((u) => u.id.equals(unpaidOrderId))).getSingle();
      
      // 2. Update unpaid order status
      await (update(unpaidOrders)..where((u) => u.id.equals(unpaidOrderId))).write(
        UnpaidOrdersCompanion(
          status: const Value('paid'),
        ),
      );

      // 3. Insert payment record
      final paymentId = const Uuid().v7();
      await into(payments).insert(
        PaymentsCompanion.insert(
          id: paymentId,
          orderId: unpaid.orderId,
          method: paymentMethod,
          amount: unpaid.amount,
          notes: Value('Pagamento de Fiado: ${unpaid.customerName}'),
          paidAt: now,
          updatedAt: now,
        ),
      );

      // 4. Sync queue
      await into(syncQueue).insert(
        SyncQueueCompanion.insert(
          id: const Uuid().v7(),
          targetTable: 'payments',
          operation: 'INSERT',
          payloadJson: jsonEncode({
            'id': paymentId,
            'order_id': unpaid.orderId,
            'method': paymentMethod,
            'amount': unpaid.amount,
            'notes': 'Pagamento de Fiado: ${unpaid.customerName}',
            'paid_at': now,
          }),
          createdAt: now,
          syncStatus: const Value(SyncStatus.pending),
        ),
      );
    });
  }
}
