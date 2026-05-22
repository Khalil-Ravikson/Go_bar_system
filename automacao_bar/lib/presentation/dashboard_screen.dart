import 'package:automacao_bar/core/network/websocket_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/ui_settings_provider.dart';
import '../../../features/orders/presentation/order_details_screen.dart';
import '../../../presentation/components/connection_status_indicator.dart';
import '../../../presentation/components/finance_header.dart';
import '../../../presentation/components/resto_card.dart';
import '../../../presentation/theme/app_colors.dart';
import '../../../core/database/database_provider.dart';
import '../features/settings/presentation/settings_general_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardContent(),
    const SettingsGeneralScreen(),
  ];
  
  @override
  void initState() {
    super.initState();
    // Inicia a conexão de tempo real assim que o Dashboard nasce
    // O Future.microtask garante que o Riverpod já está pronto
    Future.microtask(() => ref.read(webSocketServiceProvider).connect());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primaryNeon,
        unselectedItemColor: AppColors.textSecondary,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.table_restaurant), label: 'Mesas'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configurações'),
        ],
      ),
    );
  }
}
  
// Extraímos o conteúdo do Dashboard para este Widget separado
class DashboardContent extends ConsumerWidget {
  const DashboardContent({super.key});







  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsyncValue = ref.watch(openOrdersProvider);
    final currentGridSize = ref.watch(gridItemSizeProvider);


    // 1. Escuta o status de conexão em tempo real!
    
    final connectionStatus = ref.watch(connectionStatusProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Dashboard Operacional', style: TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            // 2. Passa o status real para o indicador
            child: ConnectionStatusIndicator(status: connectionStatus ),
          ),
        ],
      ),
      body: Column(
        children: [
          const FinanceHeader(),
          Expanded(
            child: ordersAsyncValue.when(
              data: (orders) {
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: currentGridSize,
                  ),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final isBusy = order.status == 'OPEN';
                    return RestoCard(
                      title: 'Mesa ${order.tableNumber}',
                      subtitle: isBusy ? 'Em atendimento' : 'Livre',
                      status: isBusy ? 'Ocupada' : 'Livre',
                      statusColor: isBusy ? AppColors.primaryOrange : AppColors.primaryNeon,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => OrderDetailsScreen(
                              orderId: order.id,
                              tableNumber: order.tableNumber,
                            ),
                          ),
                        );
                      }, syncStatus: 'SYNCED',
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNeon)),
              error: (err, _) => Center(child: Text('Erro: $err', style: const TextStyle(color: AppColors.error))),
            ),
          ),
        ],
      ),
    );
  }
}