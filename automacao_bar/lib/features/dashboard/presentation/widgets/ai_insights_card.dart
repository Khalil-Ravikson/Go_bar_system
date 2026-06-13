import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/features/dashboard/application/dashboard_provider.dart';

class AiInsightsCard extends ConsumerWidget {
  const AiInsightsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insight = ref.watch(aiInsightsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonGreen.withValues(alpha: 0.15), // Adjusted from 0.02 to 0.15 for subtle glow
            blurRadius: 16, // Changed from 10 to 16
            spreadRadius: 0, // Removed spread for a cleaner glow
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8), // Changed from 10 to 8
            decoration: BoxDecoration(
              color: AppColors.neonGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology, color: AppColors.neonGreen, size: 24), // Changed from 28 to 24
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GOBAR AI INSIGHTS',
                  style: TextStyle(
                    color: AppColors.neonGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 12, // Adjusted from 11
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8), // Adjusted from 4 to 8
                AnimatedSwitcher( // Added micro-interaction
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    insight,
                    key: ValueKey<String>(insight),
                    style: const TextStyle(
                      color: AppColors.textMain,
                      fontSize: 14, // Adjusted from 13
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
