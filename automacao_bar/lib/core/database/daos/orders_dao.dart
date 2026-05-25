import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../tables.dart';

part 'orders_dao.g.dart';

@DriftAccessor(tables: [Orders, OrderItems, SyncOutbox])
class OrdersDao extends DatabaseAccessor<AppDatabase> with _$OrdersDaoMixin {
  OrdersDao(AppDatabase db) : super(db);

  // ==========================================
  // MÉTODOS DA TELA INICIAL (MESAS)
  // ==========================================
  Stream<List<Order>> watchOpenOrders() {
    return (select(orders)..where((tbl) => tbl.status.equals('OPEN'))).watch();
  }

  Future<void> openTable(int tableNumber, String tenantId) async {
    final uuid = const Uuid().v7();
    final now = DateTime.now().millisecondsSinceEpoch;

    await transaction(() async {
      await into(orders).insert(
        OrdersCompanion.insert(
          id: uuid, tenantId: tenantId, tableNumber: tableNumber, status: 'OPEN', openedAt: now,
        ),
      );
      await into(syncOutbox).insert(
        SyncOutboxCompanion.insert(
          id: const Uuid().v7(), eventType: 'ORDER_OPENED', aggregateId: uuid,
          payload: jsonEncode({'tableNumber': tableNumber}), occurredAt: now,
        ),
      );
    });
  }

  // ==========================================
  // MÉTODOS DO PDV (O NOVO CARRINHO)
  // ==========================================
  
  /// Salva uma comanda inteira com vários itens de uma vez (Usado no PosScreen)
  Future<void> createOrderOffline(int tableNumber, String tenantId, List<Map<String, dynamic>> items) async {
    await transaction(() async {
      final orderId = const Uuid().v7();
      final now = DateTime.now().millisecondsSinceEpoch;

      // 1. Cria a Comanda
      await into(orders).insert(
        OrdersCompanion.insert(id: orderId, tenantId: tenantId, tableNumber: tableNumber, status: 'OPEN', openedAt: now),
      );

      // 2. Adiciona os Itens
      for (final item in items) {
        await into(orderItems).insert(
          OrderItemsCompanion.insert(
            id: const Uuid().v7(), orderId: orderId, productId: item['product_id'] as String, quantity: item['quantity'] as int,
          ),
        );
      }

      // 3. Joga na fila de sincronização
      await into(syncOutbox).insert(
        SyncOutboxCompanion.insert(
          id: const Uuid().v7(), eventType: 'ORDER_CREATED', aggregateId: orderId,
          payload: jsonEncode({'table_number': tableNumber, 'items': items}), occurredAt: now,
        ),
      );
    });
  }

  // ==========================================
  // MÉTODOS ANTIGOS DE ITENS INDIVIDUAIS
  // ==========================================
  Stream<List<OrderItem>> watchOrderItems(String orderId) {
    return (select(orderItems)..where((tbl) => tbl.orderId.equals(orderId))).watch();
  }

  Future<void> addItemToOrder(String orderId, String productId, int quantity, String notes) async {
    final itemId = const Uuid().v7();
    final now = DateTime.now().millisecondsSinceEpoch;

    await transaction(() async {
      await into(orderItems).insert(
        OrderItemsCompanion.insert(
          id: itemId, orderId: orderId, productId: productId, quantity: quantity, notes: Value(notes), syncStatus: const Value('PENDING'),
        ),
      );
      await into(syncOutbox).insert(
        SyncOutboxCompanion.insert(
          id: const Uuid().v7(), eventType: 'ITEM_ADDED', aggregateId: orderId,
          payload: jsonEncode({'item_id': itemId, 'product_id': productId, 'quantity': quantity, 'notes': notes}), occurredAt: now,
        ),
      );
    });
  }

  // ==========================================
  // MÉTODOS DE SINCRONIZAÇÃO (OUTBOX)
  // ==========================================
  Future<List<SyncOutboxData>> getPendingSyncEvents() async {
    return (select(syncOutbox)..limit(50)).get();
  }

  Future<void> removeSyncedEvents(List<String> syncedIds) async {
    await (delete(syncOutbox)..where((tbl) => tbl.id.isIn(syncedIds))).go();
    await (update(orderItems)..where((tbl) => tbl.syncStatus.equals('PENDING')))
        .write(const OrderItemsCompanion(syncStatus: Value('SYNCED')));
  }
}