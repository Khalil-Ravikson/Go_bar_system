import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../tables.dart';

part 'orders_dao.g.dart';

@DriftAccessor(tables: [Orders, OrderItems, SyncQueue])
class OrdersDao extends DatabaseAccessor<AppDatabase> with _$OrdersDaoMixin {
  OrdersDao(super.db);

  Stream<List<Order>> watchActiveOrders() {
    return (select(orders)..where((tbl) => tbl.status.equals('aberto'))).watch();
  }

  Stream<List<OrderItem>> watchOrderItems(String orderId) {
    return (select(orderItems)..where((tbl) => tbl.orderId.equals(orderId))).watch();
  }

  Future<void> openOrder(String orderId, String tableId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final uuid = const Uuid().v7();

    await transaction(() async {
      await into(orders).insert(
        OrdersCompanion.insert(
          id: orderId,
          tableId: tableId,
          openedAt: now,
          status: 'aberto',
          totalAmount: const Value(0.0),
          updatedAt: now,
        ),
      );

      final payload = {
        'id': orderId,
        'table_id': tableId,
        'opened_at': now,
        'status': 'aberto',
        'total_amount': 0.0,
        'updated_at': now,
      };

      await into(syncQueue).insert(
        SyncQueueCompanion.insert(
          id: uuid,
          targetTable: 'orders',
          operation: 'INSERT',
          payloadJson: jsonEncode(payload),
          createdAt: now,
          syncStatus: const Value(SyncStatus.pending),
        ),
      );
    });
  }

  Future<void> addOrderItem({
    required String orderId,
    required String productId,
    required double quantity,
    required double unitPrice,
    String? notes,
  }) async {
    final itemId = const Uuid().v7();
    final syncId = const Uuid().v7();
    final now = DateTime.now().millisecondsSinceEpoch;

    await transaction(() async {
      // 1. Insert item into OrderItems table
      await into(orderItems).insert(
        OrderItemsCompanion.insert(
          id: itemId,
          orderId: orderId,
          productId: productId,
          quantity: quantity,
          unitPrice: unitPrice,
          status: const Value('preparando'),
          notes: Value(notes),
          updatedAt: now,
        ),
      );

      // 2. Prepare payload for SyncQueue (Outbox)
      final payload = {
        'id': itemId,
        'order_id': orderId,
        'product_id': productId,
        'quantity': quantity,
        'unit_price': unitPrice,
        'status': 'preparando',
        'notes': notes,
        'updated_at': now,
      };

      // 3. Insert record in SyncQueue
      await into(syncQueue).insert(
        SyncQueueCompanion.insert(
          id: syncId,
          targetTable: 'order_items',
          operation: 'INSERT',
          payloadJson: jsonEncode(payload),
          createdAt: now,
          syncStatus: const Value(SyncStatus.pending),
        ),
      );

      // 4. Update the order total amount
      final order = await (select(orders)..where((tbl) => tbl.id.equals(orderId))).getSingle();
      final newTotal = order.totalAmount + (quantity * unitPrice);
      await (update(orders)..where((tbl) => tbl.id.equals(orderId))).write(
        OrdersCompanion(
          totalAmount: Value(newTotal),
          updatedAt: Value(now),
        ),
      );

      // 5. Add order update event to SyncQueue
      await into(syncQueue).insert(
        SyncQueueCompanion.insert(
          id: const Uuid().v7(),
          targetTable: 'orders',
          operation: 'UPDATE',
          payloadJson: jsonEncode({
            'id': orderId,
            'total_amount': newTotal,
            'updated_at': now,
          }),
          createdAt: now,
          syncStatus: const Value(SyncStatus.pending),
        ),
      );
    });
  }

  Future<void> addItemToOrder(String orderId, String productId, int quantity, String notes) async {
    await addOrderItem(
      orderId: orderId,
      productId: productId,
      quantity: quantity.toDouble(),
      unitPrice: 0.0,
      notes: notes,
    );
  }

  Future<List<SyncQueueData>> getPendingSyncEvents() async {
    return (select(syncQueue)..where((tbl) => tbl.syncStatus.equals(SyncStatus.pending.name))).get();
  }

  Future<void> removeSyncedEvents(List<String> syncedIds) async {
    await (delete(syncQueue)..where((tbl) => tbl.id.isIn(syncedIds))).go();
  }

  Future<void> closeOrder(String orderId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final syncId = const Uuid().v7();

    await transaction(() async {
      await (update(orders)..where((tbl) => tbl.id.equals(orderId))).write(
        OrdersCompanion(
          status: const Value('fechado'),
          closedAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      await into(syncQueue).insert(
        SyncQueueCompanion.insert(
          id: syncId,
          targetTable: 'orders',
          operation: 'UPDATE',
          payloadJson: jsonEncode({
            'id': orderId,
            'status': 'fechado',
            'closed_at': now,
            'updated_at': now,
          }),
          createdAt: now,
          syncStatus: const Value(SyncStatus.pending),
        ),
      );
    });
  }
}