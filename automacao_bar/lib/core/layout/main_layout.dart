import 'package:automacao_bar/design_system/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatelessWidget {
  final Widget child; // Esta é a página injetada pelo GoRouter (PDV, Dashboard, etc.)

  const MainLayout({super.key, required this.child});

  // Função para calcular qual o item do menu está ativo com base no URL atual
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/pos')) return 0;
    if (location.startsWith('/kitchen')) return 1;
    if (location.startsWith('/profile')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0; // Default para POS
  }

  // Função para navegar quando clicamos num item do menu
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/pos');
        break;
      case 1:
        context.go('/kitchen');
        break;
      case 2:
        context.go('/profile');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final currentIndex = _calculateSelectedIndex(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Se for Desktop/Tablet deitado, desenhamos uma NavigationRail lateral (muito profissional)
          if (isDesktop)
            NavigationRail(
              backgroundColor: AppColors.surface,
              selectedIndex: currentIndex,
              onDestinationSelected: (idx) => _onItemTapped(idx, context),
              selectedIconTheme: const IconThemeData(color: AppColors.primaryNeon),
              unselectedIconTheme: const IconThemeData(color: AppColors.textSecondary),
              selectedLabelTextStyle: const TextStyle(color: AppColors.primaryNeon, fontWeight: FontWeight.bold),
              unselectedLabelTextStyle: const TextStyle(color: AppColors.textSecondary),
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.point_of_sale_outlined), selectedIcon: Icon(Icons.point_of_sale), label: Text('PDV')),
                NavigationRailDestination(icon: Icon(Icons.restaurant_outlined), selectedIcon: Icon(Icons.restaurant), label: Text('Cozinha')),
                NavigationRailDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: Text('Perfil')),
                NavigationRailDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: Text('Configurações')),
              ],
            ),
          
          // Se for Desktop, adicionamos uma linha divisória
          if (isDesktop) const VerticalDivider(thickness: 1, width: 1, color: AppColors.border),
          
          // Onde a verdadeira página é desenhada
          Expanded(child: child),
        ],
      ),
      // Se for Mobile, desenhamos uma BottomNavigationBar
      bottomNavigationBar: isDesktop ? null : BottomNavigationBar(
        backgroundColor: AppColors.surface,
        currentIndex: currentIndex,
        onTap: (idx) => _onItemTapped(idx, context),
        selectedItemColor: AppColors.primaryNeon,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.point_of_sale), label: 'PDV'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Cozinha'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configurações'),
        ],
      ),
    );
  }
}