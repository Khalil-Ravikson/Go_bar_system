import 'dart:ui';
import 'package:flutter/material.dart';
import '../colors.dart';
import '../spacing.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool isDark;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = AppRadius.md,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: isDark ? AppColors.glassOverlayDark : AppColors.glassOverlayLight,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
