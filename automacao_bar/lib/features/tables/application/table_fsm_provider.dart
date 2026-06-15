import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/repository_providers.dart';

enum TableState {
  livre,
  ocupada,
  conta_solicitada,
}

class TableFsmNotifier extends Notifier<void> {
  @override
  void build() {}

  /// Transição: Livre -> Ocupada (Abrir Mesa)
  Future<void> openTable(RestaurantTable table) async {
    if (table.status != 'livre') {
      throw Exception('A mesa ${table.number} já está ocupada ou em fechamento.');
    }
    final repo = ref.read(tableRepositoryProvider);
    await repo.updateTableStatus(table.id, 'ocupada');
  }

  /// Transição: Ocupada -> Conta Solicitada (Pedir Fechamento)
  Future<void> requestBill(RestaurantTable table) async {
    if (table.status != 'ocupada') {
      throw Exception('Apenas mesas ocupadas podem solicitar o fechamento da conta.');
    }
    final repo = ref.read(tableRepositoryProvider);
    await repo.updateTableStatus(table.id, 'fechamento');
  }

  /// Transição: Conta Solicitada -> Livre (Pagamento Concluído)
  Future<void> releaseTable(RestaurantTable table) async {
    if (table.status != 'fechamento') {
      throw Exception('A mesa ${table.number} precisa estar em fechamento para ser liberada.');
    }
    final repo = ref.read(tableRepositoryProvider);
    await repo.updateTableStatus(table.id, 'livre');
  }
}

final tableFsmProvider = NotifierProvider<TableFsmNotifier, void>(() {
  return TableFsmNotifier();
});

final tablesStreamProvider = StreamProvider<List<RestaurantTable>>((ref) {
  return ref.watch(tableRepositoryProvider).watchTables();
});
