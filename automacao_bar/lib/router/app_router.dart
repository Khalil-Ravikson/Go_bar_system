import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:google_fonts/google_fonts.dart';

// Screens imports
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/kitchen/presentation/screens/kitchen_screen.dart';
import '../presentation/dashboard_screen.dart';
import '../features/auth/application/auth_provider.dart';
import '../features/tables/presentation/screens/interactive_map_screen.dart';
import '../features/rh/presentation/screens/shift_management_screen.dart';
import '../features/inventory/presentation/screens/inventory_management_screen.dart';
import '../features/orders/presentation/screens/order_screen.dart';
import '../features/auth/presentation/screens/user_list_screen.dart';
import '../features/catalog/presentation/catalog_management_screen.dart';
import '../features/auth/presentation/screens/user_form_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../core/layout/main_layout.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ValueNotifier<UserSession?>(ref.read(authProvider));
  ref.listen<UserSession?>(authProvider, (_, next) {
    refreshListenable.value = next;
  });

  String getInitialRoute(UserSession? session) {
    if (session == null || session.role == UserRole.guest) return '/home/dashboard'; // User requested Dashboard or Pos. Let's do /home/dashboard or /home/pdv
    switch (session.role) {
      case UserRole.admin:
        return '/home/dashboard';
      case UserRole.waiter:
      case UserRole.caixa:
        return '/home/pdv';
      case UserRole.chef:
        return '/kds';
      case UserRole.guest:
        return '/home/dashboard';
    }
  }

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: refreshListenable,
    initialLocation: ref.read(authProvider) != null ? getInitialRoute(ref.read(authProvider)) : '/home/pdv',
    
    redirect: (context, state) {
      final session = ref.read(authProvider);
      final location = state.uri.toString();
      
      // If not logged in, guests can visit public paths (/login, /setup, /home/pdv, /table-details, /home/config, /home/dashboard)
      if (session == null || session.role == UserRole.guest) {
        if (location == '/login' ||
            location == '/setup' ||
            location.startsWith('/cadastro') ||
            location.startsWith('/home/pdv') ||
            location.startsWith('/home/dashboard') ||
            location.startsWith('/table-details') ||
            location.startsWith('/home/config')) {
          return null;
        }
        return '/home/dashboard';
      }
      
      // If logged in, prevent going to login page
      if (location == '/login') {
        return getInitialRoute(session);
      }
      
      // Redirect root to appropriate home screen based on role
      if (location == '/') {
        return getInitialRoute(session);
      }
      
      if (location == '/setup') return null; // Allow onboarding setup

      final role = session.role;

      // Guards for Admin/Dashboard/Management and restricted paths (/usuarios, /cadastro)
      if ((location.startsWith('/drawer') ||
           location.startsWith('/usuarios') ||
           location.startsWith('/cadastro')) && role != UserRole.admin) {
        return '/sem-permissao';
      }
      
      // Guards for POS/PDV (Waiters and Admin only)
      if (location.startsWith('/home/pdv') && role != UserRole.waiter && role != UserRole.admin) {
        return getInitialRoute(session);
      }
      
      // Guards for Kitchen (Chef and Admin only)
      if (location.startsWith('/kds') && role != UserRole.chef && role != UserRole.admin) {
        return getInitialRoute(session);
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
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/cadastro',
        builder: (context, state) {
          final id = state.uri.queryParameters['id'];
          return UserFormScreen(userId: id);
        },
      ),
      GoRoute(
        path: '/sem-permissao',
        builder: (context, state) => Scaffold(
          backgroundColor: const Color(0xFF0A0A0F),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.gpp_bad,
                    color: Color(0xFFFF007F), // Cyber Pink
                    size: 80,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'ACESSO RESTRITO',
                    style: GoogleFonts.shareTechMono(
                      color: const Color(0xFFFF007F),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      shadows: [
                        const Shadow(
                          color: Color(0xFFFF007F),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Você não possui privilégios de administrador para acessar este setor.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.shareTechMono(
                      color: const Color(0xFF8B91B5),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF12121A),
                      foregroundColor: const Color(0xFF00FFFF), // Electric Blue
                      side: const BorderSide(color: Color(0xFF00FFFF), width: 1),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Voltar para o Início'),
                    onPressed: () {
                      context.go('/');
                    },
                  ),
                ],
              ),
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
          GoRoute(
            path: '/table-details',
            pageBuilder: (context, state) {
              final table = state.uri.queryParameters['table'] ?? '1';
              return NoTransitionPage(child: OrderScreen(tableNumber: table));
            },
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
            path: '/drawer/cardapio',
            pageBuilder: (context, state) => const NoTransitionPage(child: CatalogManagementScreen()),
          ),
           GoRoute(
            path: '/usuarios',
            pageBuilder: (context, state) => const NoTransitionPage(child: UserListScreen()),
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