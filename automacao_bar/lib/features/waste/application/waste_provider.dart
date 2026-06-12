import 'package:flutter_riverpod/flutter_riverpod.dart';

class WasteItem {
  final String id;
  final String productId;
  final String productName;
  final double quantity;
  final String reason; // "Erro do Cliente", "Erro do Garçom", "Quebra/Estoque", etc.
  final DateTime reportedAt;

  const WasteItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.reason,
    required this.reportedAt,
  });
}

class WasteNotifier extends Notifier<List<WasteItem>> {
  @override
  List<WasteItem> build() {
    // Some pre-populated dummy wastes for visualization
    return [
      WasteItem(
        id: 'w1',
        productId: 'p1',
        productName: 'Hambúrguer Clássico',
        quantity: 1,
        reason: 'Quebra de Preparo (Queimado)',
        reportedAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      WasteItem(
        id: 'w2',
        productId: 'p5',
        productName: 'Porção de Batatas Fritas',
        quantity: 1,
        reason: 'Erro do Cliente (Cancelou após preparo)',
        reportedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }

  void addWaste({
    required String productId,
    required String productName,
    required double quantity,
    required String reason,
  }) {
    final newItem = WasteItem(
      id: 'w_${DateTime.now().millisecondsSinceEpoch}',
      productId: productId,
      productName: productName,
      quantity: quantity,
      reason: reason,
      reportedAt: DateTime.now(),
    );
    state = [newItem, ...state];
  }
}

final wasteProvider = NotifierProvider<WasteNotifier, List<WasteItem>>(() {
  return WasteNotifier();
});
