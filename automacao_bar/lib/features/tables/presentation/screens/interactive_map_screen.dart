import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/design_system/components/table_card.dart';

class TablePosition {
  final String id;
  final String number;
  final double x;
  final double y;
  final TableStatus status;
  final int elapsedMinutes;
  final String? value;

  TablePosition({
    required this.id,
    required this.number,
    required this.x,
    required this.y,
    required this.status,
    required this.elapsedMinutes,
    this.value,
  });

  TablePosition copyWith({
    String? id,
    String? number,
    double? x,
    double? y,
    TableStatus? status,
    int? elapsedMinutes,
    String? value,
  }) {
    return TablePosition(
      id: id ?? this.id,
      number: number ?? this.number,
      x: x ?? this.x,
      y: y ?? this.y,
      status: status ?? this.status,
      elapsedMinutes: elapsedMinutes ?? this.elapsedMinutes,
      value: value ?? this.value,
    );
  }
}

class TablePositionsNotifier extends Notifier<List<TablePosition>> {
  @override
  List<TablePosition> build() {
    return [
      TablePosition(id: 't1', number: '01', x: 40, y: 80, status: TableStatus.occupied, elapsedMinutes: 12, value: 'R\$ 78,90'),
      TablePosition(id: 't2', number: '02', x: 200, y: 80, status: TableStatus.free, elapsedMinutes: 0),
      TablePosition(id: 't3', number: '03', x: 360, y: 80, status: TableStatus.occupied, elapsedMinutes: 32, value: 'R\$ 192,50'), // Critical! Pulse.
      TablePosition(id: 't4', number: '04', x: 520, y: 80, status: TableStatus.occupied, elapsedMinutes: 5, value: 'R\$ 34,90'),
      
      TablePosition(id: 't5', number: '05', x: 40, y: 260, status: TableStatus.occupied, elapsedMinutes: 28, value: 'R\$ 120,00'), // Critical! Pulse.
      TablePosition(id: 't6', number: '06', x: 200, y: 260, status: TableStatus.closing, elapsedMinutes: 18, value: 'R\$ 320,00'),
      TablePosition(id: 't7', number: '07', x: 360, y: 260, status: TableStatus.free, elapsedMinutes: 0),
      TablePosition(id: 't8', number: '08', x: 520, y: 260, status: TableStatus.occupied, elapsedMinutes: 14, value: 'R\$ 55,00'),
    ];
  }

  void updatePosition(String id, double x, double y) {
    state = state.map((t) {
      if (t.id == id) {
        return t.copyWith(x: x, y: y);
      }
      return t;
    }).toList();
  }
}

final tablePositionsProvider = NotifierProvider<TablePositionsNotifier, List<TablePosition>>(() {
  return TablePositionsNotifier();
});

class InteractiveMapScreen extends ConsumerWidget {
  const InteractiveMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tables = ref.watch(tablePositionsProvider);
    final Size size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;

    // Floor plan boundaries
    final double mapWidth = isDesktop ? size.width - 280 : size.width - 32;
    final double mapHeight = 500.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mapa Interativo do Salão', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Banner
              Container(
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
                            '💡 Dica: Pressione e arraste qualquer mesa para reorganizar a planta do bar em tempo real. Mesas piscando em laranja/vermelho indicam atraso no atendimento (> 25 min).',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Salon Floor Layout Canvas
              Container(
                width: mapWidth,
                height: mapHeight,
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceLight, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      // Floor details mockup backgrounds
                      Positioned(
                        left: 16,
                        top: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.surfaceLight),
                          ),
                          child: const Text('BALCÃO / BAR', style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      Positioned(
                        right: 16,
                        top: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.surfaceLight),
                          ),
                          child: const Text('SAÍDA DA COZINHA', style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        bottom: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.surfaceLight),
                          ),
                          child: const Text('ENTRADA / DECK', style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),

                      // Positioned draggable tables
                      ...tables.map((table) {
                        return Positioned(
                          left: table.x.clamp(0.0, mapWidth - 145),
                          top: table.y.clamp(0.0, mapHeight - 145),
                          child: GestureDetector(
                            onPanUpdate: (details) {
                              final newX = (table.x + details.delta.dx).clamp(0.0, mapWidth - 145);
                              final newY = (table.y + details.delta.dy).clamp(0.0, mapHeight - 145);
                              ref.read(tablePositionsProvider.notifier).updatePosition(table.id, newX, newY);
                            },
                            child: SizedBox(
                              width: 135,
                              height: 135,
                              child: TableCard(
                                tableNumber: table.number,
                                status: table.status,
                                elapsedMinutes: table.elapsedMinutes,
                                infoText: table.status == TableStatus.free
                                    ? 'Livre'
                                    : table.elapsedMinutes > 0
                                        ? 'Ocupada • ${table.elapsedMinutes} min'
                                        : 'Aguardando Conta',
                                valueText: table.value,
                                onTap: () {
                                  // Navigate to Table Details screen with selected table number query parameter
                                  context.push('/table-details?table=${table.number}');
                                },
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Heatmap legend explanation
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem(Colors.grey, 'Livre'),
                  const SizedBox(width: 24),
                  _buildLegendItem(AppColors.neonGreen, 'Atendimento Normal'),
                  const SizedBox(width: 24),
                  _buildLegendItem(AppColors.orange, 'Conta Fechamento'),
                  const SizedBox(width: 24),
                  _buildLegendItem(AppColors.danger, 'Atraso Crítico (> 25 min)'),
                ],
              ),
            ],
          ),
        ),
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
}
