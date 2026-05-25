import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design_system/theme/app_colors.dart';
import '../../../design_system/components/table_card.dart';

// No futuro será um ConsumerWidget para ler as mesas da Base de Dados local.
// Por agora, para montar a UI rapidamente, usamos um StatelessWidget com dados mockados.
class TablesScreen extends StatelessWidget {
  const TablesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Gestão de Mesas',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primaryNeon),
            onPressed: () {
              // Futuro: Adicionar nova mesa avulsa
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsividade: Mais colunas em ecrãs largos (Desktop/Tablet)
          int crossAxisCount = 2;
          if (constraints.maxWidth > 600) crossAxisCount = 4;
          if (constraints.maxWidth > 900) crossAxisCount = 5;

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1, // Formato mais quadradinho
            ),
            itemCount: 12, // Simulando 12 mesas
            itemBuilder: (context, index) {
              final tableNum = (index + 1).toString();
              
              // Simulação de estados (Apenas para visualização do design)
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
                  // Futuro: Abrir a mesa (Navegar para o PDV passando o ID da mesa)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('A abrir Mesa $tableNum...')),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}