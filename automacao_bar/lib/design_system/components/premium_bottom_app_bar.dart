import 'package:flutter/material.dart';
import '../colors.dart';

class PremiumBottomAppBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<PremiumNavItem> items;
  final List<PremiumSpeedDialAction> speedDialActions;

  const PremiumBottomAppBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    required this.speedDialActions,
  });

  void _showSpeedDialMenu(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.only(top: 12, left: 24, right: 24, bottom: 32),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0A0A0F) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: Border.all(
            color: isDark ? const Color(0xFF1A1A24) : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A24) : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'AÇÕES RÁPIDAS',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            ...speedDialActions.map((action) {
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: Icon(action.icon, color: AppColors.primary),
                ),
                title: Text(
                  action.label,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  action.onPressed();
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    
    final int halfLength = (items.length / 2).ceil();
    final leftItems = items.sublist(0, halfLength);
    final rightItems = items.sublist(halfLength);

    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        BottomAppBar(
          padding: EdgeInsets.zero,
          notchMargin: 8.0,
          color: backgroundColor,
          clipBehavior: Clip.antiAlias,
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left Items
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(leftItems.length, (index) {
                      final actualIdx = index;
                      final item = leftItems[index];
                      final isSelected = currentIndex == actualIdx;
                      return _buildNavItem(context, item, isSelected, actualIdx);
                    }),
                  ),
                ),
                
                // Gap for the central FAB
                const SizedBox(width: 72),
                
                // Right Items
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(rightItems.length, (index) {
                      final actualIdx = halfLength + index;
                      final item = rightItems[index];
                      final isSelected = currentIndex == actualIdx;
                      return _buildNavItem(context, item, isSelected, actualIdx);
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Central FAB
        Positioned(
          bottom: 24,
          child: FloatingActionButton(
            heroTag: 'central_fab',
            backgroundColor: AppColors.primary,
            elevation: 4,
            shape: const CircleBorder(),
            onPressed: () => _showSpeedDialMenu(context),
            child: const Icon(
              Icons.add,
              color: Colors.black,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(BuildContext context, PremiumNavItem item, bool isSelected, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = AppColors.primary;
    final inactiveColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? item.selectedIcon : item.icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                color: isSelected ? activeColor : inactiveColor,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PremiumNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const PremiumNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class PremiumSpeedDialAction {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const PremiumSpeedDialAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });
}
