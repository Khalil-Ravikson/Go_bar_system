import 'package:flutter/material.dart';
import '../../../presentation/theme/app_colors.dart';

// Importando os nossos "Legos" modulares
import 'widgets/pos_menu_area.dart';
import 'widgets/pos_order_panel.dart';

class PosScreen extends StatelessWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Define o ponto de quebra para telas grandes (Desktop/Tablet deitado)
            final isDesktop = constraints.maxWidth > 800;

            if (isDesktop) {
              return const Row(
                children: [
                  // Lado Esquerdo: Menu e Produtos (70% da tela)
                  Expanded(
                    flex: 7, 
                    child: PosMenuArea(isDesktop: true),
                  ),
                  
                  VerticalDivider(width: 1, color: AppColors.border),
                  
                  // Lado Direito: Comanda e Pagamento (30% da tela)
                  Expanded(
                    flex: 3, 
                    child: PosOrderPanel(isDesktop: true),
                  ),
                ],
              );
            } else {
              // Layout Mobile: Produtos em cima, Comanda fixada embaixo
              return const Column(
                children: [
                  Expanded(
                    child: PosMenuArea(isDesktop: false),
                  ),
                  PosOrderPanel(isDesktop: false),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}