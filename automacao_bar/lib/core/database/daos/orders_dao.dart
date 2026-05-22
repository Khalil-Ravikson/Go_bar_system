import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../tables.dart';

// O Drift vai gerar este arquivo
part 'orders_dao.g.dart';

@DriftAccessor(tables: [Orders, OrderItems, SyncOutbox])
class OrdersDao extends DatabaseAccessor<AppDatabase> with _$OrdersDaoMixin {
  // ignore: use_super_parameters
  OrdersDao(AppDatabase db) : super(db);

  // ==========================================
  // MÉTODOS DA TELA INICIAL (MESAS)
  // ==========================================

  /// Escuta todas as mesas abertas
  Stream<List<Order>> watchOpenOrders() {
    return (select(orders)..where((tbl) => tbl.status.equals('OPEN'))).watch();
  }

  /// Abre uma nova mesa e gera o log no Outbox
  Future<void> openTable(int tableNumber, String tenantId) async {
    final uuid = const Uuid().v7(); // Gerado no cliente
    final now = DateTime.now().millisecondsSinceEpoch;

    await transaction(() async {
      await into(orders).insert(
        OrdersCompanion.insert(
          id: uuid,
          tenantId: tenantId,
          tableNumber: tableNumber,
          status: 'OPEN',
          openedAt: now,
        ),
      );

      await into(syncOutbox).insert(
        SyncOutboxCompanion.insert(
          id: const Uuid().v7(),
          eventType: 'ORDER_OPENED',
          aggregateId: uuid,
          payload: jsonEncode({'tableNumber': tableNumber}),
          occurredAt: now,
        ),
      );
    });
  }

  // ==========================================
  // MÉTODOS DA TELA DE COMANDAS (ITENS)
  // ==========================================

  /// Escuta os itens de um pedido específico em tempo real
  Stream<List<OrderItem>> watchOrderItems(String orderId) {
    return (select(orderItems)
          ..where((tbl) => tbl.orderId.equals(orderId)))
        .watch();
  }

  /// Adiciona um item na comanda e joga na fila de sincronização (Outbox)
  Future<void> addItemToOrder(String orderId, String productId, int quantity, String notes) async {
    final itemId = const Uuid().v7();
    final now = DateTime.now().millisecondsSinceEpoch;

    await transaction(() async {
      // 1. Salva o item na tela (Offline) com status PENDING
      await into(orderItems).insert(
        OrderItemsCompanion.insert(
          id: itemId,
          orderId: orderId,
          productId: productId,
          quantity: quantity,
          notes: Value(notes),
          syncStatus: const Value('PENDING'), 
        ),
      );

      // 2. Salva o evento para o Go processar quando tiver internet
      await into(syncOutbox).insert(
        SyncOutboxCompanion.insert(
          id: const Uuid().v7(),
          eventType: 'ITEM_ADDED',
          aggregateId: orderId,
          payload: jsonEncode({
            'item_id': itemId,
            'product_id': productId,
            'quantity': quantity,
            'notes': notes,
          }),
          occurredAt: now,
        ),
      );
    });
  } // <--- AQUI ESTAVA FALTANDO A CHAVE NO SEU CÓDIGO!

  // ==========================================
  // MÉTODOS DE SINCRONIZAÇÃO (ÉPICO 3)
  // ==========================================

  /// Busca todos os eventos pendentes no Outbox (limite de 50 para não sobrecarregar)
  Future<List<SyncOutboxData>> getPendingSyncEvents() async {
    return (select(syncOutbox)..limit(50)).get();
  }

  /// Apaga os eventos que o Go confirmou que recebeu com sucesso
  Future<void> removeSyncedEvents(List<String> syncedIds) async {
    await (delete(syncOutbox)..where((tbl) => tbl.id.isIn(syncedIds))).go();
    
    // Atualiza o status visual dos itens para "SYNCED" (Nuvem Verde na tela)
    // Na vida real, o ideal é o Go mandar o status atualizado, mas vamos otimizar aqui
    await (update(orderItems)..where((tbl) => tbl.syncStatus.equals('PENDING')))
        .write(const OrderItemsCompanion(syncStatus: Value('SYNCED')));
  }
}