import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';
// Se tiveres um ficheiro de temas globais, importa aqui
// import 'presentation/theme/app_themes.dart'; 

void main() {
  runApp(
    // O ProviderScope inicializa o Riverpod na raiz da aplicação
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Trocamos o MaterialApp normal pelo MaterialApp.router
    return MaterialApp.router(
      title: 'Sistema PDV Enterprise',
      debugShowCheckedModeBanner: false,
      
      // Opcional: Adiciona o teu tema escuro/neon aqui
      // theme: AppThemes.darkNeonTheme, 
      
      // Entregamos o controlo absoluto das rotas ao GoRouter
      routerConfig: AppRouter.router,
    );
  }
}