import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';
import 'design_system/theme.dart';

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
      
      // Utiliza o novo PremiumThemeData configurado para Light e Dark
      theme: PremiumThemeData.lightTheme, 
      darkTheme: PremiumThemeData.darkTheme,
      themeMode: ThemeMode.system, // Adapts to user setting but we can force it later
      
      // Entregamos o controlo absoluto das rotas ao GoRouter
      routerConfig: router,
    );
  }
}