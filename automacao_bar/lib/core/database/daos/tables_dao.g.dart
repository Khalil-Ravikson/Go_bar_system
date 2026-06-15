// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tables_dao.dart';

// ignore_for_file: type=lint
mixin _$TablesDaoMixin on DatabaseAccessor<AppDatabase> {
  $TablesTable get tables => attachedDatabase.tables;
  $SyncQueueTable get syncQueue => attachedDatabase.syncQueue;
  TablesDaoManager get managers => TablesDaoManager(this);
}

class TablesDaoManager {
  final _$TablesDaoMixin _db;
  TablesDaoManager(this._db);
  $$TablesTableTableManager get tables =>
      $$TablesTableTableManager(_db.attachedDatabase, _db.tables);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db.attachedDatabase, _db.syncQueue);
}
