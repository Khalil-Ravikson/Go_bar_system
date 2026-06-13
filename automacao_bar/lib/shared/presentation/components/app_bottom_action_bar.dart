import 'package:flutter/material.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';

/// Rodapé de ações padronizado para todas as telas mobile.
///
/// Envolve automaticamente com [SafeArea] (bottom), aplica
/// o fundo [AppColors.surface] e a borda superior de 1px.
/// Os [children] são dispostos na vertical com espaçamento de 12px.
class AppBottomActionBar extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  const AppBottomActionBar({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(24, 20, 24, 20),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.surfaceLight, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _withSpacing(children),
          ),
        ),
      ),
    );
  }

  List<Widget> _withSpacing(List<Widget> widgets) {
    final result = <Widget>[];
    for (int i = 0; i < widgets.length; i++) {
      result.add(widgets[i]);
      if (i < widgets.length - 1) result.add(const SizedBox(height: 12));
    }
    return result;
  }
}
