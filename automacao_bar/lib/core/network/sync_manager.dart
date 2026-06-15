import 'dart:convert';
import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/tables.dart';
import 'remote_database_client.dart';

class SyncManager {
  final AppDatabase _db;
  final IRemoteDatabaseClient _remoteClient;

  SyncManager(this._db, this._remoteClient);

  Future<void> syncPendingQueue() async {
    // 1. Fetch pending records from SyncQueue
    final pendingItems = await (_db.select(_db.syncQueue)
          ..where((tbl) => tbl.syncStatus.equals(SyncStatus.pending.name)))
        .get();

    for (final item in pendingItems) {
      try {
        final Map<String, dynamic> payload = jsonDecode(item.payloadJson);

        if (item.operation == 'INSERT' || item.operation == 'UPDATE') {
          await _remoteClient.upsert(item.targetTable, payload);
        } else if (item.operation == 'DELETE') {
          await _remoteClient.delete(item.targetTable, payload['id'] ?? item.id);
        }

        // 2. Mark as synced locally on success
        await (_db.update(_db.syncQueue)..where((tbl) => tbl.id.equals(item.id))).write(
          SyncQueueCompanion(
            syncStatus: const Value(SyncStatus.synced),
          ),
        );
      } catch (e) {
        // Network fail or other error, halt queue sync to preserve ordering of outbox events
        break;
      }
    }
  }
}
