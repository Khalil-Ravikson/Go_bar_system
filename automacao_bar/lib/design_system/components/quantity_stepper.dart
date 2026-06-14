import 'package:flutter/material.dart';
import '../colors.dart';
import '../spacing.dart';

class QuantityStepper extends StatelessWidget {
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const QuantityStepper({
    super.key,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final colorBg = isDark ? AppColors.surfaceHighlightDark : AppColors.surfaceHighlightLight;
    final colorText = isDark ? AppColors.textMainDark : AppColors.textMainLight;

    return Container(
      decoration: BoxDecoration(
        color: colorBg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      padding: const EdgeInsets.all(AppSpacing.xxs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: Icons.remove,
            onTap: value > 1 ? onDecrement : null,
          ),
          SizedBox(
            width: 40,
            child: Text(
              value.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorText,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _StepperButton(
            icon: Icons.add,
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepperButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: onTap == null ? Colors.transparent : AppColors.primary.withOpacity(0.1),
          ),
          child: Icon(
            icon,
            size: 20,
            color: onTap == null ? Colors.grey : AppColors.primary,
          ),
        ),
      ),
    );
  }
}
