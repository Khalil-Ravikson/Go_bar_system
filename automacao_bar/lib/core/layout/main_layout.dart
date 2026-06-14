import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/application/auth_provider.dart';

import '../../design_system/colors.dart';
import '../../design_system/components/premium_bottom_app_bar.dart';

class NavigationItem {
  final String path;
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const NavigationItem({
    required this.path,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

// Maximum 3 visible tabs on bottom nav as per spec:
// Admin: Início (Dashboard), Mesas (PDV), Perfil (Config)
// Waiter: Mesas (PDV), Perfil (Config)
// Caixa: Mesas (PDV), Perfil (Config)
const List<NavigationItem> _adminNavItems = [
  NavigationItem(
    path: '/home/dashboard',
    icon: Icons.analytics_outlined,
    selectedIcon: Icons.analytics,
    label: 'Início',
  ),
  NavigationItem(
    path: '/home/pdv',
    icon: Icons.table_restaurant_outlined,
    selectedIcon: Icons.table_restaurant,
    label: 'Mesas',
  ),
  NavigationItem(
    path: '/home/config',
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
    label: 'Perfil',
  ),
];

const List<NavigationItem> _waiterNavItems = [
  NavigationItem(
    path: '/home/pdv',
    icon: Icons.table_restaurant_outlined,
    selectedIcon: Icons.table_restaurant,
    label: 'Mesas',
  ),
  NavigationItem(
    path: '/home/config',
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
    label: 'Perfil',
  ),
];

class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider);
    final userRole = session.role;

    final isAdmin = userRole == UserRole.admin;
    final isCaixa = userRole == UserRole.caixa;
    final isWaiter = userRole == UserRole.waiter;
    
    final visibleItems = isAdmin ? _adminNavItems : _waiterNavItems;

    // Determine current index
    final String location = GoRouterState.of(context).uri.toString();
    int selectedIndex = 0;
    for (int i = 0; i < visibleItems.length; i++) {
      if (location.startsWith(visibleItems[i].path)) {
        selectedIndex = i;
        break;
      }
    }

    final isDesktop = MediaQuery.of(context).size.width > 800;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Actions for the Central FAB based on Role
    List<PremiumSpeedDialAction> getSpeedDialActions() {
      if (isAdmin) {
        return [
          PremiumSpeedDialAction(
            icon: Icons.receipt,
            label: 'Nova Comanda',
            onPressed: () {
              // Action or navigation to new comanda
            },
          ),
          PremiumSpeedDialAction(
            icon: Icons.person_add,
            label: 'Novo Usuário',
            onPressed: () => context.push('/drawer/usuarios'),
          ),
          PremiumSpeedDialAction(
            icon: Icons.trending_down,
            label: 'Registrar Despesa',
            onPressed: () {
              // Action or navigation to register expense
            },
          ),
        ];
      } else if (isWaiter) {
        return [
          PremiumSpeedDialAction(
            icon: Icons.receipt,
            label: 'Nova Comanda',
            onPressed: () {
              // Waiter action
            },
          ),
        ];
      } else if (isCaixa) {
        return [
          PremiumSpeedDialAction(
            icon: Icons.monetization_on,
            label: 'Receber Pagamento',
            onPressed: () {
              // Caixa action
            },
          ),
        ];
      }
      return [];
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('BarSystem SaaS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_done, color: Colors.green),
            onPressed: () {},
          ),
        ],
      ),
      drawer: isAdmin
          ? Drawer(
              backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primary,
                          radius: 28,
                          child: const Icon(Icons.admin_panel_settings, color: Colors.black, size: 28),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Painel de Gestão',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Administrador',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.inventory_2_outlined),
                    title: const Text('Controle de Estoque'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/drawer/estoque');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.people_outline),
                    title: const Text('Gestão de Usuários'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/drawer/usuarios');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.analytics_outlined),
                    title: const Text('Relatórios de Fechamento'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/drawer/relatorio');
                    },
                  ),
                ],
              ),
            )
          : null,
      body: Row(
        children: [
          if (isDesktop)
            NavigationRail(
              backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              selectedIndex: selectedIndex,
              onDestinationSelected: (idx) {
                context.go(visibleItems[idx].path);
              },
              selectedIconTheme: const IconThemeData(color: AppColors.primary),
              unselectedIconTheme: IconThemeData(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              selectedLabelTextStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              unselectedLabelTextStyle: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              labelType: NavigationRailLabelType.all,
              destinations: visibleItems.map((item) {
                return NavigationRailDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.selectedIcon),
                  label: Text(item.label),
                );
              }).toList(),
            ),
          
          if (isDesktop) VerticalDivider(thickness: 1, width: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
          
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: isDesktop 
        ? null 
        : PremiumBottomAppBar(
            currentIndex: selectedIndex,
            onTap: (idx) => context.go(visibleItems[idx].path),
            items: visibleItems.map((item) {
              return PremiumNavItem(
                icon: item.icon,
                selectedIcon: item.selectedIcon,
                label: item.label,
              );
            }).toList(),
            speedDialActions: getSpeedDialActions(),
          ),
    );
  }
}