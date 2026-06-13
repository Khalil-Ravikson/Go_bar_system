import 'package:automacao_bar/design_system/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:automacao_bar/features/auth/application/auth_provider.dart';

class NavigationItem {
  final String path;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final List<UserRole> allowedRoles;

  const NavigationItem({
    required this.path,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.allowedRoles,
  });
}

const List<NavigationItem> _allNavItems = [
  NavigationItem(
    path: '/pos',
    icon: Icons.point_of_sale_outlined,
    selectedIcon: Icons.point_of_sale,
    label: 'PDV',
    allowedRoles: [UserRole.admin, UserRole.waiter],
  ),
  NavigationItem(
    path: '/salon',
    icon: Icons.map_outlined,
    selectedIcon: Icons.map,
    label: 'Salão',
    allowedRoles: [UserRole.admin, UserRole.waiter],
  ),
  NavigationItem(
    path: '/customers',
    icon: Icons.people_alt_outlined,
    selectedIcon: Icons.people,
    label: 'CRM',
    allowedRoles: [UserRole.admin, UserRole.waiter],
  ),
  NavigationItem(
    path: '/shifts',
    icon: Icons.assignment_ind_outlined,
    selectedIcon: Icons.assignment_ind,
    label: 'RH / Turnos',
    allowedRoles: [UserRole.admin, UserRole.waiter],
  ),
  NavigationItem(
    path: '/cash-register',
    icon: Icons.monetization_on_outlined,
    selectedIcon: Icons.monetization_on,
    label: 'Caixa',
    allowedRoles: [UserRole.admin, UserRole.waiter],
  ),
  NavigationItem(
    path: '/kitchen',
    icon: Icons.restaurant_outlined,
    selectedIcon: Icons.restaurant,
    label: 'Cozinha',
    allowedRoles: [UserRole.admin, UserRole.chef],
  ),
  NavigationItem(
    path: '/profile',
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
    label: 'Perfil',
    allowedRoles: [UserRole.admin, UserRole.waiter, UserRole.chef],
  ),
  NavigationItem(
    path: '/settings',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    label: 'Configurações',
    allowedRoles: [UserRole.admin, UserRole.waiter, UserRole.chef],
  ),
  NavigationItem(
    path: '/management',
    icon: Icons.menu_book_outlined,
    selectedIcon: Icons.menu_book,
    label: 'Gestão',
    allowedRoles: [UserRole.admin],
  ),
  NavigationItem(
    path: '/dashboard',
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
    label: 'Dashboard',
    allowedRoles: [UserRole.admin],
  ),
  NavigationItem(
    path: '/inventory-management',
    icon: Icons.inventory_2_outlined,
    selectedIcon: Icons.inventory_2,
    label: 'Estoque',
    allowedRoles: [UserRole.admin],
  ),
  NavigationItem(
    path: '/delivery-kds',
    icon: Icons.delivery_dining_outlined,
    selectedIcon: Icons.delivery_dining,
    label: 'Delivery KDS',
    allowedRoles: [UserRole.admin, UserRole.chef],
  ),
  NavigationItem(
    path: '/courier-settlement',
    icon: Icons.handshake_outlined,
    selectedIcon: Icons.handshake,
    label: 'Estafetas',
    allowedRoles: [UserRole.admin],
  ),
  NavigationItem(
    path: '/financial-reports',
    icon: Icons.receipt_long_outlined,
    selectedIcon: Icons.receipt_long,
    label: 'Relatórios',
    allowedRoles: [UserRole.admin],
  ),
];

class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider);
    final userRole = session.role;

    // Filter navigation items by active user role
    final visibleItems = _allNavItems.where((item) => item.allowedRoles.contains(userRole)).toList();

    // Determine current index based on visible navigation items
    final String location = GoRouterState.of(context).uri.toString();
    int selectedIndex = 0;
    for (int i = 0; i < visibleItems.length; i++) {
      if (location.startsWith(visibleItems[i].path)) {
        selectedIndex = i;
        break;
      }
    }

    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // NavigationRail for Desktop
          if (isDesktop)
            NavigationRail(
              backgroundColor: AppColors.surface,
              selectedIndex: selectedIndex,
              onDestinationSelected: (idx) {
                context.go(visibleItems[idx].path);
              },
              selectedIconTheme: const IconThemeData(color: AppColors.primaryNeon),
              unselectedIconTheme: const IconThemeData(color: AppColors.textSecondary),
              selectedLabelTextStyle: const TextStyle(color: AppColors.primaryNeon, fontWeight: FontWeight.bold),
              unselectedLabelTextStyle: const TextStyle(color: AppColors.textSecondary),
              labelType: NavigationRailLabelType.all,
              destinations: visibleItems.map((item) {
                return NavigationRailDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.selectedIcon),
                  label: Text(item.label),
                );
              }).toList(),
            ),
          
          if (isDesktop) const VerticalDivider(thickness: 1, width: 1, color: AppColors.border),
          
          // Inject actual route page widget
          Expanded(child: child),
        ],
      ),
      // BottomNavigationBar for Mobile
      bottomNavigationBar: isDesktop ? null : BottomNavigationBar(
        backgroundColor: AppColors.surface,
        currentIndex: selectedIndex,
        onTap: (idx) {
          context.go(visibleItems[idx].path);
        },
        selectedItemColor: AppColors.primaryNeon,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        items: visibleItems.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item.icon),
            activeIcon: Icon(item.selectedIcon),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}