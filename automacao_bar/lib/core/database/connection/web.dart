import 'package:drift/drift.dart';

class MockQueryExecutor extends QueryExecutor {
  final Map<String, List<Map<String, Object?>>> _tables = {};

  MockQueryExecutor() {
    // Seed default users for testing
    _tables['users'] = [
      {
        'id': 'admin-uuid-1',
        'name': 'João Oliveira (Admin)',
        'pin_hash': '1234',
        'role': 'admin',
        'is_active': 1,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'id': 'waiter-uuid-2',
        'name': 'Pedro Silva (Garçom)',
        'pin_hash': '4321',
        'role': 'waiter',
        'is_active': 1,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'id': 'chef-uuid-3',
        'name': 'Chef André (Cozinha)',
        'pin_hash': '8888',
        'role': 'chef',
        'is_active': 1,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'id': 'caixa-uuid-4',
        'name': 'Caixa Principal',
        'pin_hash': '9999',
        'role': 'caixa',
        'is_active': 1,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
    ];
  }

  @override
  SqlDialect get dialect => SqlDialect.sqlite;

  @override
  QueryExecutor beginExclusive() => this;

  @override
  TransactionExecutor beginTransaction() => MockTransactionExecutor(this);

  @override
  Future<void> runBatched(BatchedStatements statements) async {
    for (var i = 0; i < statements.statements.length; i++) {
      final stmt = statements.statements[i];
      // We don't have arguments easily mapped here, but we can bypass or print
    }
  }

  @override
  Future<void> runCustom(String statement, [List<Object?>? args]) async {
    if (statement.toLowerCase().startsWith('insert')) {
      await runInsert(statement, args ?? []);
    } else if (statement.toLowerCase().startsWith('update')) {
      await runUpdate(statement, args ?? []);
    } else if (statement.toLowerCase().startsWith('delete')) {
      await runDelete(statement, args ?? []);
    }
  }

  @override
  Future<int> runDelete(String statement, List<Object?> args) async {
    print('MockDB Delete: $statement, Args: $args');
    final match = RegExp(r'''DELETE\s+FROM\s+["'`]?(\w+)["'`]?''', caseSensitive: false).firstMatch(statement);
    if (match != null) {
      final tableName = match.group(1)!.toLowerCase();
      if (statement.contains('WHERE')) {
        final wherePartMatch = RegExp(r'''WHERE\s+(.*)''', caseSensitive: false).firstMatch(statement);
        if (wherePartMatch != null) {
          final List<String> whereColumns = RegExp(r'''["'`]?(\w+)["'`]?\s*=\s*\?''')
              .allMatches(wherePartMatch.group(1)!)
              .map((m) => m.group(1)!)
              .toList();

          _tables[tableName]?.removeWhere((row) {
            for (var i = 0; i < whereColumns.length; i++) {
              final col = whereColumns[i];
              if (i < args.length && row[col] != args[i]) {
                return false;
              }
            }
            return true;
          });
        }
      } else {
        _tables[tableName]?.clear();
      }
    }
    return 1;
  }

  @override
  Future<int> runInsert(String statement, List<Object?> args) async {
    print('MockDB Insert: $statement, Args: $args');
    // Pattern to match INSERT INTO "table_name" ("col1", "col2") VALUES (?, ?)
    final match = RegExp(r'''INSERT(?:\s+OR\s+\w+)?\s+INTO\s+["'`]?(\w+)["'`]?\s*\((.*?)\)''', caseSensitive: false).firstMatch(statement);
    if (match != null) {
      final tableName = match.group(1)!.toLowerCase();
      final columnsStr = match.group(2)!;
      final columns = columnsStr.split(',').map((c) => c.trim().replaceAll('`', '').replaceAll('"', '').replaceAll("'", '')).toList();

      final row = <String, Object?>{};
      for (var i = 0; i < columns.length; i++) {
        if (i < args.length) {
          var val = args[i];
          if (val is bool) {
            val = val ? 1 : 0;
          }
          row[columns[i]] = val;
        }
      }

      _tables.putIfAbsent(tableName, () => []).add(row);
      return 1;
    }
    return 0;
  }

  @override
  Future<List<Map<String, Object?>>> runSelect(String statement, List<Object?> args) async {
    print('MockDB Select: $statement, Args: $args');
    final match = RegExp(r'''FROM\s+["'`]?(\w+)["'`]?''', caseSensitive: false).firstMatch(statement);
    if (match != null) {
      final tableName = match.group(1)!.toLowerCase();
      final rows = _tables[tableName] ?? [];

      // Emulate SELECT filters for common queries
      if (statement.contains('pin_hash = ?') || statement.contains('pin_hash = :var')) {
        final pin = args[0] as String;
        return rows.where((r) => r['pin_hash'] == pin).toList();
      }
      
      if (statement.contains('order_id = ?')) {
        final orderId = args[0] as String;
        return rows.where((r) => r['order_id'] == orderId).toList();
      }

      if (statement.contains('product_id = ?')) {
        final productId = args[0] as String;
        return rows.where((r) => r['product_id'] == productId).toList();
      }

      if (statement.contains('category_id = ?')) {
        final categoryId = args[0] as String;
        return rows.where((r) => r['category_id'] == categoryId).toList();
      }

      return rows;
    }
    return [];
  }

  @override
  Future<int> runUpdate(String statement, List<Object?> args) async {
    print('MockDB Update: $statement, Args: $args');
    final match = RegExp(r'''UPDATE\s+["'`]?(\w+)["'`]?''', caseSensitive: false).firstMatch(statement);
    if (match != null) {
      final tableName = match.group(1)!.toLowerCase();
      final rows = _tables[tableName] ?? [];

      final setPartMatch = RegExp(r'''SET\s+(.*?)\s+WHERE''', caseSensitive: false).firstMatch(statement);
      if (setPartMatch != null) {
        final setColumns = RegExp(r'''["'`]?(\w+)["'`]?\s*=\s*\?''')
            .allMatches(setPartMatch.group(1)!)
            .map((m) => m.group(1)!)
            .toList();

        final wherePartMatch = RegExp(r'''WHERE\s+(.*)''', caseSensitive: false).firstMatch(statement);
        final List<String> whereColumns = [];
        if (wherePartMatch != null) {
          whereColumns.addAll(RegExp(r'''["'`]?(\w+)["'`]?\s*=\s*\?''')
              .allMatches(wherePartMatch.group(1)!)
              .map((m) => m.group(1)!));
        }

        for (final row in rows) {
          bool matches = true;
          for (var i = 0; i < whereColumns.length; i++) {
            final col = whereColumns[i];
            final argIdx = setColumns.length + i;
            if (argIdx < args.length) {
              final val = args[argIdx];
              if (row[col] != val) {
                matches = false;
                break;
              }
            }
          }
          if (matches) {
            for (var i = 0; i < setColumns.length; i++) {
              final col = setColumns[i];
              if (i < args.length) {
                row[col] = args[i];
              }
            }
          }
        }
      }
      return 1;
    }
    return 0;
  }

  @override
  Future<bool> ensureOpen(QueryExecutorUser user) async => true;
}

class MockTransactionExecutor extends TransactionExecutor {
  final MockQueryExecutor _parent;

  MockTransactionExecutor(this._parent);

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
  Future<void> runBatched(BatchedStatements statements) async {
    await _parent.runBatched(statements);
  }

  @override
  Future<void> runCustom(String statement, [List<Object?>? args]) async {
    await _parent.runCustom(statement, args);
  }

  @override
  Future<int> runDelete(String statement, List<Object?> args) async {
    return await _parent.runDelete(statement, args);
  }

  @override
  Future<int> runInsert(String statement, List<Object?> args) async {
    return await _parent.runInsert(statement, args);
  }

  @override
  Future<List<Map<String, Object?>>> runSelect(String statement, List<Object?> args) async {
    return await _parent.runSelect(statement, args);
  }

  @override
  Future<int> runUpdate(String statement, List<Object?> args) async {
    return await _parent.runUpdate(statement, args);
  }

  @override
  Future<bool> ensureOpen(QueryExecutorUser user) async => true;
}

QueryExecutor openConnection() {
  return MockQueryExecutor();
}

