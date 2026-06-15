import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../design_system/components/table_card.dart';
import '../../../core/database/app_database.dart';
import '../../tables/application/table_fsm_provider.dart';
import '../../orders/application/order_fsm_provider.dart';

class TablesScreen extends ConsumerWidget {
  const TablesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tablesAsync = ref.watch(tablesStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = 2;
          if (constraints.maxWidth > 600) crossAxisCount = 4;
          if (constraints.maxWidth > 900) crossAxisCount = 5;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 120,
                backgroundColor: AppColors.surface,
                elevation: 0,
                flexibleSpace: const FlexibleSpaceBar(
                  titlePadding: EdgeInsetsDirectional.only(start: 24, bottom: 16),
                  title: Text(
                    'Gestão de Mesas',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              tablesAsync.when(
                data: (tables) {
                  if (tables.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'Nenhuma mesa cadastrada.',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 16),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.1,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final table = tables[index];
                          return _TableGridCard(table: table);
                        },
                        childCount: tables.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppColors.primaryNeon)),
                ),
                error: (err, _) => SliverFillRemaining(
                  child: Center(
                    child: Text('Erro: $err', style: const TextStyle(color: AppColors.error)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TableGridCard extends ConsumerWidget {
  final RestaurantTable table;

  const _TableGridCard({required this.table});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeOrderAsync = ref.watch(activeOrderForTableProvider(table.id));

    return activeOrderAsync.when(
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
    );
  }
}