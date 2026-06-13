import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../design_system/components/table_card.dart';

// No futuro será um ConsumerWidget para ler as mesas da Base de Dados local.
// Por agora, para montar a UI rapidamente, usamos um StatelessWidget com dados mockados.
class TablesScreen extends StatelessWidget {
  const TablesScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add, color: AppColors.primaryNeon),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              SliverPadding(
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
                      final tableNum = (index + 1).toString();

                      TableStatus status = TableStatus.free;
                      String info = 'Livre';
                      String? value;

                      if (index == 0 || index == 3) {
                        status = TableStatus.occupied;
                        info = 'Ocupada • 42 min';
                        value = 'R\$ 184,50';
                      } else if (index == 5) {
                        status = TableStatus.closing;
                        info = 'Aguardando Pagamento';
                        value = 'R\$ 320,00';
                      }

                      return TableCard(
                        tableNumber: tableNum,
                        status: status,
                        infoText: info,
                        valueText: value,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('A abrir Mesa $tableNum...')),
                          );
                        },
                      );
                    },
                    childCount: 12,
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