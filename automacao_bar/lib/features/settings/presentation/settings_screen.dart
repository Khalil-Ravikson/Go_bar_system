import 'package:automacao_bar/design_system/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/ui_settings_provider.dart';
import '../../../presentation/theme/app_colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSize = ref.watch(gridItemSizeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Configurações Operacionais"),
        backgroundColor: AppColors.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Densidade do Dashboard", 
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18)),
            const SizedBox(height: 20),
            Slider(
              value: currentSize,
              min: 1.0,
              max: 2.5,
              divisions: 15,
              activeColor: AppColors.primaryNeon,
              label: currentSize.toStringAsFixed(1),
              onChanged: (val) {
                ref.read(gridItemSizeProvider.notifier).state = val;
              },
            ),
            const SizedBox(height: 10),
            Text("Tamanho atual: ${currentSize.toStringAsFixed(1)}", 
              style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}