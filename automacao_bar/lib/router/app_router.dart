import 'package:automacao_bar/features/tables/presentation/tables_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Importa aqui as tuas páginas reais
import '../features/pos/presentation/pos_screen.dart';
// import '../features/dashboard/presentation/dashboard_screen.dart'; 
// import '../features/tables/presentation/tables_screen.dart';

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
          // Rota 2: Dashboard (Preparada para o futuro)
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              // child: DashboardScreen(), // <-- Descomentar quando existir
              child: Scaffold(body: Center(child: Text('Dashboard em Breve'))), 
            ),
          ),
          // Rota 3: Mesas (Preparada para o futuro)
          GoRoute(
            path: '/tables',
            pageBuilder: (context, state) => const NoTransitionPage(
              // child: TablesScreen(), // <-- Descomentar quando existir
              child: TablesScreen(),
            ),
          ),
        ],
      ),
    ],
  );
}