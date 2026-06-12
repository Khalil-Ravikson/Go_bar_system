import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Importa aqui as tuas páginas reais
import '../features/pos/presentation/screens/pos_screen.dart';
import '../features/settings/presentation/screens/profile_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/kitchen/presentation/screens/kitchen_screen.dart';
import '../features/orders/presentation/screens/table_details_screen.dart';
import '../features/management/presentation/screens/menu_management_screen.dart';

import '../core/layout/main_layout.dart';

// Chave global para o navegador principal
final _rootNavigatorKey = GlobalKey<NavigatorState>();
// Chave global para o navegador do Shell (a área onde as páginas trocam)
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/pos', // O sistema abre sempre no PDV por defeito
    routes: [
      // ShellRoute é a "Casca" que contém a barra de navegação
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          // O MainLayout vai receber a página atual (child) e desenhar o menu em volta
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
          // Rota 5: Detalhes da Mesa
          GoRoute(
            path: '/table-details',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TableDetailsScreen(),
            ),
          ),
          // Rota 6: Gestão de Cardápio
          GoRoute(
            path: '/management',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MenuManagementScreen(),
            ),
          ),
        ],
      ),
    ],
  );
}