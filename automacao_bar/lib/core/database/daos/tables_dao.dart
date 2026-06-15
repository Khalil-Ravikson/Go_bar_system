import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../tables.dart';

part 'tables_dao.g.dart';

@DriftAccessor(tables: [Tables, SyncQueue])
class TablesDao extends DatabaseAccessor<AppDatabase> with _$TablesDaoMixin {
  TablesDao(super.db);

  Stream<List<RestaurantTable>> watchTables() {
    return select(tables).watch();
  }

  Future<void> insertTable(RestaurantTable table) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final syncId = const Uuid().v7();

    await transaction(() async {
      await into(tables).insert(table);

      final payload = {
        'id': table.id,
        'number': table.number,
        'status': table.status,
        'updated_at': now,
      };

      await into(syncQueue).insert(
        SyncQueueCompanion.insert(
          id: syncId,
          targetTable: 'tables',
          operation: 'INSERT',
          payloadJson: jsonEncode(payload),
          createdAt: now,
          syncStatus: const Value(SyncStatus.pending),
        ),
      );
    });
  }

  Future<void> updateTableStatus(String tableId, String status) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final syncId = const Uuid().v7();

    await transaction(() async {
      await (update(tables)..where((tbl) => tbl.id.equals(tableId))).write(
        TablesCompanion(
          status: Value(status),
          updatedAt: Value(now),
        ),
      );

      final payload = {
        'id': tableId,
        'status': status,
        'updated_at': now,
      };

      await into(syncQueue).insert(
        SyncQueueCompanion.insert(
          id: syncId,
          targetTable: 'tables',
          operation: 'UPDATE',
          payloadJson: jsonEncode(payload),
          createdAt: now,
          syncStatus: const Value(SyncStatus.pending),
        ),
      );
    });
  }

  Future<void> updateTablePosition(String tableId, double x, double y) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final syncId = const Uuid().v7();

    await transaction(() async {
      await (update(tables)..where((tbl) => tbl.id.equals(tableId))).write(
        TablesCompanion(
          x: Value(x),
          y: Value(y),
          updatedAt: Value(now),
        ),
      );

      final payload = {
        'id': tableId,
        'x': x,
        'y': y,
        'updated_at': now,
      };

      await into(syncQueue).insert(
        SyncQueueCompanion.insert(
          id: syncId,
          targetTable: 'tables',
          operation: 'UPDATE',
          payloadJson: jsonEncode(payload),
          createdAt: now,
          syncStatus: const Value(SyncStatus.pending),
        ),
      );
    });
  }

  Future<void> updateTableNumber(String tableId, int number) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final syncId = const Uuid().v7();

    await transaction(() async {
      await (update(tables)..where((tbl) => tbl.id.equals(tableId))).write(
        TablesCompanion(
          number: Value(number),
          updatedAt: Value(now),
        ),
      );

      final payload = {
        'id': tableId,
        'number': number,
        'updated_at': now,
      };

      await into(syncQueue).insert(
        SyncQueueCompanion.insert(
          id: syncId,
          targetTable: 'tables',
          operation: 'UPDATE',
          payloadJson: jsonEncode(payload),
          createdAt: now,
          syncStatus: const Value(SyncStatus.pending),
        ),
      );
    });
  }

  Future<void> deleteTable(String tableId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final syncId = const Uuid().v7();

    await transaction(() async {
      await (delete(tables)..where((tbl) => tbl.id.equals(tableId))).go();

      final payload = {
        'id': tableId,
      };

      await into(syncQueue).insert(
        SyncQueueCompanion.insert(
          id: syncId,
          targetTable: 'tables',
          operation: 'DELETE',
          payloadJson: jsonEncode(payload),
          createdAt: now,
          syncStatus: const Value(SyncStatus.pending),
        ),
      );
    });
  }
}
