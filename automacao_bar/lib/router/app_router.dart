import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Screens imports
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/kitchen/presentation/screens/kitchen_screen.dart';
import '../presentation/dashboard_screen.dart';
import '../features/auth/application/auth_provider.dart';
import '../features/tables/presentation/screens/interactive_map_screen.dart';
import '../features/rh/presentation/screens/shift_management_screen.dart';
import '../features/inventory/presentation/screens/inventory_management_screen.dart';

import '../core/layout/main_layout.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(authProvider);
  final role = session.role;

  String getInitialRoute(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return '/home/dashboard';
      case UserRole.waiter:
      case UserRole.caixa:
        return '/home/pdv';
      case UserRole.chef:
        return '/kds';
    }
  }

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: getInitialRoute(role),
    
    redirect: (context, state) {
      final location = state.uri.toString();
      
      // Redirect root to appropriate home screen based on role
      if (location == '/') {
        return getInitialRoute(role);
      }
      
      if (location == '/login' || location == '/setup') return null; // Allow login and onboarding setup

      // Guards for Admin/Dashboard/Management
      if ((location.startsWith('/home/dashboard') || location.startsWith('/drawer')) && role != UserRole.admin) {
        return '/sem-permissao';
      }
      
      // Guards for POS/PDV (Waiters and Admin only)
      if (location.startsWith('/home/pdv') && role != UserRole.waiter && role != UserRole.admin) {
        return getInitialRoute(role);
      }
      
      // Guards for Kitchen (Chef and Admin only)
      if (location.startsWith('/kds') && role != UserRole.chef && role != UserRole.admin) {
        return getInitialRoute(role);
      }

      return null;
    },
    
    routes: [
      GoRoute(
        path: '/setup',
        builder: (context, state) => const Scaffold(body: Center(child: Text('Supabase Setup Wizard Screen'))),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const Scaffold(body: Center(child: Text('PIN Login Screen'))),
      ),
      GoRoute(
        path: '/sem-permissao',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text(
              'Acesso Restrito',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      
      // Kitchen is completely separate, fullscreen KDS without shell
      GoRoute(
        path: '/kds',
        builder: (context, state) => const KitchenScreen(),
      ),

      // We wrap the main routes in ShellRoute to provide layout (BottomAppBar, central FAB, Drawer)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          // === COMMON / ADAPTIVE HOME SHELL ROUTES ===
          GoRoute(
            path: '/home/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(child: DashboardScreen()),
          ),
          GoRoute(
            path: '/home/pdv',
            pageBuilder: (context, state) => const NoTransitionPage(child: InteractiveMapScreen()),
          ),
          GoRoute(
            path: '/home/historico',
            builder: (context, state) => const Scaffold(body: Center(child: Text('Histórico Financeiro'))),
          ),
          GoRoute(
            path: '/home/config',
            pageBuilder: (context, state) => const NoTransitionPage(child: SettingsScreen()),
          ),

          // === DRAWER / SECONDARY MANAGEMENT ROUTES ===
          GoRoute(
            path: '/drawer/estoque',
            pageBuilder: (context, state) => const NoTransitionPage(child: InventoryManagementScreen()),
          ),
          GoRoute(
            path: '/drawer/usuarios',
            pageBuilder: (context, state) => const NoTransitionPage(child: ShiftManagementScreen()),
          ),
          GoRoute(
            path: '/drawer/relatorio',
            builder: (context, state) => const Scaffold(body: Center(child: Text('Relatórios Gerenciais'))),
          ),
        ],
      ),
    ],
  );
});