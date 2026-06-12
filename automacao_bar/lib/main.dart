import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(
    // O ProviderScope inicializa o Riverpod na raiz da aplicação
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Sistema PDV Enterprise',
      debugShowCheckedModeBanner: false,
      
      // Adiciona o teu tema escuro/neon aqui
      theme: AppTheme.darkNeonTheme, 
      
      // Entregamos o controlo absoluto das rotas ao GoRouter
      routerConfig: router,
    );
  }
}