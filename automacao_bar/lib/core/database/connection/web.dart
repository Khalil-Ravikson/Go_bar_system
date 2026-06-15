import 'package:drift/drift.dart';

class MockQueryExecutor extends QueryExecutor {
  @override
  SqlDialect get dialect => SqlDialect.sqlite;

  @override
  QueryExecutor beginExclusive() => this;

  @override
  TransactionExecutor beginTransaction() => MockTransactionExecutor();

  @override
  Future<void> runBatched(BatchedStatements statements) async {}

  @override
  Future<void> runCustom(String statement, [List<Object?>? args]) async {}

  @override
  Future<int> runDelete(String statement, List<Object?> args) async => 0;

  @override
  Future<int> runInsert(String statement, List<Object?> args) async => 0;

  @override
  Future<List<Map<String, Object?>>> runSelect(String statement, List<Object?> args) async => [];

  @override
  Future<int> runUpdate(String statement, List<Object?> args) async => 0;

  @override
  Future<bool> ensureOpen(QueryExecutorUser user) async => true;
}

class MockTransactionExecutor extends TransactionExecutor {
  @override
  SqlDialect get dialect => SqlDialect.sqlite;

  @override
  QueryExecutor beginExclusive() => this;

  @override
  TransactionExecutor beginTransaction() => this;

  @override
  bool get supportsNestedTransactions => false;

  @override
  Future<void> rollback() async {}

  @override
  Future<void> send() async {}

  @override
  Future<void> runBatched(BatchedStatements statements) async {}

  @override
  Future<void> runCustom(String statement, [List<Object?>? args]) async {}

  @override
  Future<int> runDelete(String statement, List<Object?> args) async => 0;

  @override
  Future<int> runInsert(String statement, List<Object?> args) async => 0;

  @override
  Future<List<Map<String, Object?>>> runSelect(String statement, List<Object?> args) async => [];

  @override
  Future<int> runUpdate(String statement, List<Object?> args) async => 0;

  @override
  Future<bool> ensureOpen(QueryExecutorUser user) async => true;
}

QueryExecutor openConnection() {
  return MockQueryExecutor();
}
