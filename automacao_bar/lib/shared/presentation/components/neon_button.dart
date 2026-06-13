import 'package:flutter/material.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';

class NeonButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String text;
  final bool isFullWidth;
  final bool isLoading;

  const NeonButton({
    super.key,
    required this.onTap,
    required this.text,
    this.isFullWidth = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onTap != null && !isLoading;

    final Widget content = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.black,
            ),
          )
        : Text(
            text.toUpperCase(),
            style: TextStyle(
              color: isEnabled ? Colors.black : AppColors.textMuted,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1.2,
            ),
          );

    final child = MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: isEnabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            color: isEnabled ? AppColors.neonGreen : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: AppColors.neonGreen.withValues(alpha: 0.12),
                      blurRadius: 16,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(child: content),
        ),
      ),
    );

    return isFullWidth ? SizedBox(width: double.infinity, child: child) : child;
  }
}
