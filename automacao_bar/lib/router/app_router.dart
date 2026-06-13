import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/pos/presentation/screens/pos_screen.dart';
import '../features/settings/presentation/screens/profile_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/kitchen/presentation/screens/kitchen_screen.dart';
import '../features/orders/presentation/screens/order_screen.dart';
import '../features/management/presentation/screens/menu_management_screen.dart';
import '../features/cash_register/presentation/screens/cash_register_screen.dart';
import '../presentation/dashboard_screen.dart';
import '../features/auth/application/auth_provider.dart';
import '../features/crm/presentation/screens/customers_screen.dart';
import '../features/tables/presentation/screens/interactive_map_screen.dart';
import '../features/rh/presentation/screens/shift_management_screen.dart';
import '../features/inventory/presentation/screens/inventory_management_screen.dart';
import '../features/delivery/presentation/screens/delivery_kds_screen.dart';
import '../features/delivery/presentation/screens/courier_settlement_screen.dart';
import '../features/dashboard/presentation/screens/financial_reports_screen.dart';

import '../core/layout/main_layout.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(authProvider);
  final role = session.role;

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: role == UserRole.chef ? '/kitchen' : '/pos',
    
    // Redirection guards for Role-Based Access Control (RBAC)
    redirect: (context, state) {
      final location = state.uri.toString();

      // Block non-admin roles from accessing dashboard or management panels
      if (location.startsWith('/dashboard') && role != UserRole.admin) {
        return role == UserRole.chef ? '/kitchen' : '/pos';
      }
      if (location.startsWith('/management') && role != UserRole.admin) {
        return role == UserRole.chef ? '/kitchen' : '/pos';
      }
      
      // Block chefs from POS front-of-house screens
      if (location.startsWith('/pos') && role == UserRole.chef) {
        return '/kitchen';
      }

      // Block chefs from Cash Register panel
      if (location.startsWith('/cash-register') && role == UserRole.chef) {
        return '/kitchen';
      }
      
      // Block waiters from kitchen display panels
      if (location.startsWith('/kitchen') && role == UserRole.waiter) {
        return '/pos';
      }

      return null; // Authorize navigation
    },
    
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          // Rota 1: Ponto de Venda (PDV)
          GoRoute(
            path: '/pos',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PosScreen(),
            ),
          ),
          // Rota 2: Cozinha (KDS)
          GoRoute(
            path: '/kitchen',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: KitchenScreen(),
            ),
          ),
          // Rota 3: Perfil
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
          // Rota 4: Configurações
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
          // Rota 5: Comanda da Mesa (tela consolidada)
          GoRoute(
            path: '/table-details',
            pageBuilder: (context, state) {
              final table = state.uri.queryParameters['table'] ?? '04';
              return NoTransitionPage(
                child: OrderScreen(tableNumber: table),
              );
            },
          ),
          // Rota 6: Gestão de Cardápio
          GoRoute(
            path: '/management',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MenuManagementScreen(),
            ),
          ),
          // Rota 7: Dashboard Executivo de BI
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          // Rota 8: Caixa de Turno
          GoRoute(
            path: '/cash-register',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CashRegisterScreen(),
            ),
          ),
          // Rota 9: CRM Clientes
          GoRoute(
            path: '/customers',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CustomersScreen(),
            ),
          ),
          // Rota 10: Mapa Interativo do Salão
          GoRoute(
            path: '/salon',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: InteractiveMapScreen(),
            ),
          ),
          // Rota 11: RH & Turnos/Gorjetas
          GoRoute(
            path: '/shifts',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ShiftManagementScreen(),
            ),
          ),
          // Rota 12: Gestão de Estoque
          GoRoute(
            path: '/inventory-management',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: InventoryManagementScreen(),
            ),
          ),
          // Rota 13: Delivery KDS
          GoRoute(
            path: '/delivery-kds',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DeliveryKdsScreen(),
            ),
          ),
          // Rota 14: Acerto de Estafetas
          GoRoute(
            path: '/courier-settlement',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CourierSettlementScreen(),
            ),
          ),
          // Rota 15: Auditoria & Relatórios
          GoRoute(
            path: '/financial-reports',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FinancialReportsScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});