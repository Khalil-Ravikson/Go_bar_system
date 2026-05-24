import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Importações das suas telas e temas (ajuste os caminhos se necessário)
import 'presentation/dashboard_screen.dart';
import 'presentation/theme/app_colors.dart';
import 'features/pos/presentation/pos_screen.dart';
import 'features/catalog/presentation/catalog_management_screen.dart';

void main() {
  runApp(const ProviderScope(child: BarAutomationApp()));
}

class BarAutomationApp extends StatelessWidget {
  const BarAutomationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDV Bar & Restaurante',
      debugShowCheckedModeBanner: false,
      theme: _buildDarkTheme(),
      // Aponta agora para o nosso novo Orquestrador
      home: const MainOrchestratorScreen(), 
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.surface,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryNeon,
        secondary: AppColors.primaryOrange,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
    );
  }
}

// ==========================================
// ORQUESTRADOR DE NAVEGAÇÃO (Bottom Navigation)
// ==========================================
class MainOrchestratorScreen extends StatefulWidget {
  const MainOrchestratorScreen({super.key});

  @override
  State<MainOrchestratorScreen> createState() => _MainOrchestratorScreenState();
}

class _MainOrchestratorScreenState extends State<MainOrchestratorScreen> {
  // O aplicativo começa na tela do PDV (Índice 0)
  int _currentIndex = 0;

  // Lista com as 3 telas principais do nosso sistema
  final List<Widget> _screens = const [
    PosScreen(),               // Aba 0: Novo Pedido (Garçom)
    DashboardScreen(),         // Aba 1: Visão Geral / Mesas (Seu dashboard original)
    CatalogManagementScreen(), // Aba 2: Backoffice (Gestão de Cardápio)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // O IndexedStack mantém as telas vivas na memória, 
      // evitando recarregamento (flicker) ao alternar entre as abas.
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primaryNeon,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale),
            label: 'PDV (Salão)',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Mesas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Catálogo',
          ),
        ],
      ),
    );
  }
}