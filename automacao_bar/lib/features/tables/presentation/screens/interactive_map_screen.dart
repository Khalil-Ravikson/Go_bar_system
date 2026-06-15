import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/design_system/components/table_card.dart';
import 'package:automacao_bar/core/database/app_database.dart';
import 'package:automacao_bar/core/providers/repository_providers.dart';

import 'package:automacao_bar/features/tables/application/table_fsm_provider.dart';
import 'package:automacao_bar/features/orders/application/order_fsm_provider.dart';

class InteractiveMapScreen extends ConsumerStatefulWidget {
  const InteractiveMapScreen({super.key});

  @override
  ConsumerState<InteractiveMapScreen> createState() => _InteractiveMapScreenState();
}

class _InteractiveMapScreenState extends ConsumerState<InteractiveMapScreen> {
  // Temporary coordinates during dragging to prevent high frequency database writes
  final Map<String, Offset> _tempPositions = {};

  // Canvas size
  static const double canvasWidth = 800.0;
  static const double canvasHeight = 600.0;
  static const double cardSize = 135.0;

  @override
  Widget build(BuildContext context) {
    final tablesAsync = ref.watch(tablesStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Mapa Interativo do Salão',
          style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.neonGreen),
            tooltip: 'Adicionar Mesa',
            onPressed: () => _showAddTableDialog(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.15)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.neonGreen, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gestão de Salão & Heatmap de Atendimento',
                            style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '💡 Arraste as mesas para reposicionar a planta do salão. Use pinça para zoom. Toque longo em uma mesa para editar ou excluir.',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Canvas containing Interactive Map
            Expanded(
              child: tablesAsync.when(
                data: (tablesList) {
                  if (tablesList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.table_bar_outlined, size: 64, color: AppColors.textMuted),
                          const SizedBox(height: 16),
                          const Text(
                            'Nenhuma mesa cadastrada.',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => _showAddTableDialog(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Adicionar Primeira Mesa'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.neonGreen,
                              foregroundColor: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.surfaceLight, width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InteractiveViewer(
                          constrained: false,
                          boundaryMargin: const EdgeInsets.all(120.0),
                          minScale: 0.4,
                          maxScale: 2.0,
                          child: Container(
                            width: canvasWidth,
                            height: canvasHeight,
                            color: AppColors.surface.withValues(alpha: 0.1),
                            child: Stack(
                              children: [
                                // Background mock sections
                                Positioned(
                                  left: 24,
                                  top: 24,
                                  child: _buildSectionLabel('BALCÃO / BAR'),
                                ),
                                Positioned(
                                  right: 24,
                                  top: 24,
                                  child: _buildSectionLabel('SAÍDA DA COZINHA'),
                                ),
                                Positioned(
                                  left: 24,
                                  bottom: 24,
                                  child: _buildSectionLabel('ENTRADA / DECK'),
                                ),

                                // Draggable tables
                                ...tablesList.map((table) {
                                  final tempPos = _tempPositions[table.id];
                                  final x = tempPos?.dx ?? table.x;
                                  final y = tempPos?.dy ?? table.y;

                                  return _TablePositionedCard(
                                    table: table,
                                    x: x,
                                    y: y,
                                    cardSize: cardSize,
                                    canvasWidth: canvasWidth,
                                    canvasHeight: canvasHeight,
                                    onPanUpdate: (details) {
                                      final double newX = (x + details.delta.dx).clamp(0.0, canvasWidth - cardSize);
                                      final double newY = (y + details.delta.dy).clamp(0.0, canvasHeight - cardSize);
                                      setState(() {
                                        _tempPositions[table.id] = Offset(newX, newY);
                                      });
                                    },
                                    onPanEnd: () {
                                      final finalOffset = _tempPositions[table.id];
                                      if (finalOffset != null) {
                                        ref.read(tableRepositoryProvider).updateTablePosition(
                                              table.id,
                                              finalOffset.dx,
                                              finalOffset.dy,
                                            );
                                      }
                                    },
                                    onLongPress: () => _showEditTableMenu(context, table),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Erro ao carregar salão: $err', style: const TextStyle(color: Colors.red))),
              ),
            ),

            // Heatmap Legends
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                spacing: 16,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _buildLegendItem(Colors.grey, 'Livre'),
                  _buildLegendItem(AppColors.neonGreen, 'Atendimento Normal'),
                  _buildLegendItem(AppColors.orange, 'Conta Fechamento'),
                  _buildLegendItem(AppColors.danger, 'Atraso Crítico (> 25 min)'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            border: Border.all(color: color, width: 1.5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  // === TABLE CRUD DIALOGS ===

  void _showAddTableDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Adicionar Mesa', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppColors.textMain),
          decoration: const InputDecoration(
            labelText: 'Número da Mesa',
            labelStyle: TextStyle(color: AppColors.textMuted),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceLight)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neonGreen)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              final number = int.tryParse(controller.text);
              if (number == null || number <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Insira um número de mesa válido.')),
                );
                return;
              }

              final newTable = RestaurantTable(
                id: const Uuid().v7(),
                number: number,
                status: 'livre',
                x: 100.0 + (number * 10) % 300,
                y: 100.0 + (number * 10) % 200,
                capacity: 4,
                updatedAt: DateTime.now().millisecondsSinceEpoch,
              );

              await ref.read(tableRepositoryProvider).insertTable(newTable);
              Navigator.pop(context);
            },
            child: const Text('Cadastrar', style: TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showEditTableMenu(BuildContext context, RestaurantTable table) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Mesa ${table.number.toString().padLeft(2, '0')}',
                style: const TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.neonGreen),
              title: const Text('Alterar Número da Mesa', style: TextStyle(color: AppColors.textMain)),
              onTap: () {
                Navigator.pop(context);
                _showEditNumberDialog(context, table);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.danger),
              title: const Text('Remover Mesa', style: TextStyle(color: AppColors.danger)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteTable(context, table);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showEditNumberDialog(BuildContext context, RestaurantTable table) {
    final controller = TextEditingController(text: table.number.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Editar Número', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppColors.textMain),
          decoration: const InputDecoration(
            labelText: 'Novo Número',
            labelStyle: TextStyle(color: AppColors.textMuted),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceLight)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neonGreen)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              final number = int.tryParse(controller.text);
              if (number == null || number <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Insira um número válido.')),
                );
                return;
              }
              await ref.read(tableRepositoryProvider).updateTableNumber(table.id, number);
              Navigator.pop(context);
            },
            child: const Text('Salvar', style: TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteTable(BuildContext context, RestaurantTable table) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Excluir Mesa', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        content: Text(
          'Deseja realmente remover a Mesa ${table.number.toString().padLeft(2, '0')}?',
          style: const TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(tableRepositoryProvider).deleteTable(table.id);
              Navigator.pop(context);
            },
            child: const Text('Excluir', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _TablePositionedCard extends ConsumerWidget {
  final RestaurantTable table;
  final double x;
  final double y;
  final double cardSize;
  final double canvasWidth;
  final double canvasHeight;
  final Function(DragUpdateDetails) onPanUpdate;
  final VoidCallback onPanEnd;
  final VoidCallback onLongPress;

  const _TablePositionedCard({
    required this.table,
    required this.x,
    required this.y,
    required this.cardSize,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeOrderAsync = ref.watch(activeOrderForTableProvider(table.id));

    return Positioned(
      left: x,
      top: y,
      child: GestureDetector(
        onPanUpdate: onPanUpdate,
        onPanEnd: (_) => onPanEnd(),
        onLongPress: onLongPress,
        child: SizedBox(
          width: cardSize,
          height: cardSize,
          child: activeOrderAsync.when(
            data: (order) {
              TableStatus status;
              int elapsedMinutes = 0;
              String? valueText;

              if (table.status == 'ocupada') {
                status = TableStatus.occupied;
                if (order != null) {
                  final diff = DateTime.now().millisecondsSinceEpoch - order.openedAt;
                  elapsedMinutes = (diff / 60000).round();
                  valueText = 'R\$ ${order.totalAmount.toStringAsFixed(2)}';
                }
              } else if (table.status == 'fechamento') {
                status = TableStatus.closing;
                if (order != null) {
                  final diff = DateTime.now().millisecondsSinceEpoch - order.openedAt;
                  elapsedMinutes = (diff / 60000).round();
                  valueText = 'R\$ ${order.totalAmount.toStringAsFixed(2)}';
                }
              } else {
                status = TableStatus.free;
              }

              return TableCard(
                tableNumber: table.number.toString().padLeft(2, '0'),
                status: status,
                elapsedMinutes: elapsedMinutes,
                infoText: status == TableStatus.free
                    ? 'Livre'
                    : elapsedMinutes > 0
                        ? 'Ocupada • $elapsedMinutes min'
                        : 'Aguardando Conta',
                valueText: valueText,
                onTap: () {
                  context.push('/table-details?table=${table.number}');
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNeon)),
            error: (err, _) => TableCard(
              tableNumber: table.number.toString().padLeft(2, '0'),
              status: TableStatus.free,
              elapsedMinutes: 0,
              infoText: 'Erro',
              onTap: () {},
            ),
          ),
        ),
      ),
    );
  }
}
