import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../tables.dart';

part 'customers_dao.g.dart';

@DriftAccessor(tables: [Customers, LoyaltyTransactions, SyncQueue])
class CustomersDao extends DatabaseAccessor<AppDatabase> with _$CustomersDaoMixin {
  CustomersDao(super.db);

  // ── Queries ─────────────────────────────────────────────────────────────────

  Stream<List<Customer>> watchAllCustomers() {
    return (select(customers)..orderBy([(c) => OrderingTerm.asc(c.name)])).watch();
  }

  Future<Customer?> findByPhone(String phone) {
    return (select(customers)..where((c) => c.phone.equals(phone))).getSingleOrNull();
  }

  Stream<List<LoyaltyTransaction>> watchTransactionsForCustomer(String customerId) {
    return (select(loyaltyTransactions)
          ..where((t) => t.customerId.equals(customerId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  // ── Commands ─────────────────────────────────────────────────────────────────

  Future<String> insertCustomer({
    required String name,
    required String phone,
    String? email,
  }) async {
    final id = const Uuid().v7();
    final syncId = const Uuid().v7();
    final now = DateTime.now().millisecondsSinceEpoch;

    await transaction(() async {
      await into(customers).insert(
        CustomersCompanion.insert(
          id: id,
          name: name,
          phone: phone,
          email: Value(email),
          createdAt: now,
          updatedAt: now,
        ),
      );

      await into(syncQueue).insert(
        SyncQueueCompanion.insert(
          id: syncId,
          targetTable: 'customers',
          operation: 'INSERT',
          payloadJson: jsonEncode({'id': id, 'name': name, 'phone': phone, 'email': email}),
          createdAt: now,
          syncStatus: const Value(SyncStatus.pending),
        ),
      );
    });

    return id;
  }

  /// Award or redeem loyalty points and update customer totals
  Future<void> addLoyaltyPoints({
    required String customerId,
    required int pointsDelta,
    required String description,
    String? orderId,
    double spentAmount = 0.0,
  }) async {
    final txId = const Uuid().v7();
    final now = DateTime.now().millisecondsSinceEpoch;

    await transaction(() async {
      // Insert transaction record
      await into(loyaltyTransactions).insert(
        LoyaltyTransactionsCompanion.insert(
          id: txId,
          customerId: customerId,
          orderId: Value(orderId),
          pointsDelta: pointsDelta,
          description: description,
          createdAt: now,
        ),
      );

      // Update customer aggregate
      final customer = await (select(customers)
            ..where((c) => c.id.equals(customerId)))
          .getSingle();

      await (update(customers)..where((c) => c.id.equals(customerId))).write(
        CustomersCompanion(
          loyaltyPoints: Value(customer.loyaltyPoints + pointsDelta),
          totalSpent: Value(customer.totalSpent + spentAmount),
          visitCount: spentAmount > 0 ? Value(customer.visitCount + 1) : const Value.absent(),
          updatedAt: Value(now),
        ),
      );
    });
  }
}
