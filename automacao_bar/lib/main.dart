import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Nossas telas
import 'presentation/dashboard_screen.dart';
import 'features/pos/presentation/pos_screen.dart';
import 'features/catalog/presentation/catalog_management_screen.dart';
import 'presentation/theme/app_colors.dart';

void main() {
  // A LINHA MÁGICA: Garante que o motor nativo (Linux/SQLite) 
  // esteja 100% acordado antes de desenhar a interface.
  WidgetsFlutterBinding.ensureInitialized(); 

  runApp(const ProviderScope(child: BarAutomationApp()));
}

// ==========================================
// A CLASSE PRINCIPAL DO APP (O Tema Base)
// ==========================================
class BarAutomationApp extends StatelessWidget {
  const BarAutomationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDV Bar & Restaurante',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        cardColor: AppColors.surface,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryNeon,
          secondary: AppColors.secondaryMint,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
      ),
      home: const MainOrchestratorScreen(), 
    );
  }
}

// ==========================================
// ORQUESTRADOR RESPONSIVO (Navegação Premium)
// ==========================================
class MainOrchestratorScreen extends StatefulWidget {
  const MainOrchestratorScreen({super.key});

  @override
  State<MainOrchestratorScreen> createState() => _MainOrchestratorScreenState();
}

class _MainOrchestratorScreenState extends State<MainOrchestratorScreen> {
  int _currentIndex = 0;

  // As telas da nossa arquitetura modular
  final List<Widget> _screens = const [
    DashboardScreen(),         // 0: Dashboard (Visão Geral)
    PosScreen(),               // 1: PDV (Salão/Garçom)
    CatalogManagementScreen(), // 2: Catálogo (Backoffice)
  ];

  // Configuração dos itens do menu para reaproveitamento
  final List<NavigationDestination> _destinations = const [
    NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
    NavigationDestination(icon: Icon(Icons.point_of_sale_outlined), selectedIcon: Icon(Icons.point_of_sale), label: 'PDV'),
    NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Catálogo'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // SE FOR CELULAR (TELA ESTREITA) -> Menu embaixo
          if (constraints.maxWidth < 600) {
            return Column(
              children: [
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: _screens,
                  ),
                ),
                NavigationBar(
                  backgroundColor: AppColors.surface,
                  indicatorColor: AppColors.primaryNeon.withOpacity(0.2),
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) => setState(() => _currentIndex = index),
                  destinations: _destinations,
                ),
              ],
            );
          } 
          // SE FOR PC / TABLET (TELA LARGA) -> Menu na lateral
          else {
            return Row(
              children: [
                NavigationRail(
                  backgroundColor: AppColors.surface,
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) => setState(() => _currentIndex = index),
                  indicatorColor: AppColors.primaryNeon.withOpacity(0.2),
                  selectedIconTheme: const IconThemeData(color: AppColors.primaryNeon),
                  unselectedIconTheme: const IconThemeData(color: AppColors.textSecondary),
                  selectedLabelTextStyle: const TextStyle(color: AppColors.primaryNeon, fontWeight: FontWeight.bold),
                  unselectedLabelTextStyle: const TextStyle(color: AppColors.textSecondary),
                  labelType: NavigationRailLabelType.all,
                  destinations: _destinations.map((dest) => NavigationRailDestination(
                    icon: dest.icon,
                    selectedIcon: dest.selectedIcon,
                    label: Text(dest.label),
                  )).toList(),
                ),
                const VerticalDivider(thickness: 1, width: 1, color: AppColors.border),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: _screens,
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}