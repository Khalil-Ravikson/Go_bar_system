import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../colors.dart';

class PremiumBottomAppBar extends StatefulWidget {
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

  @override
  State<PremiumBottomAppBar> createState() => _PremiumBottomAppBarState();
}

class _PremiumBottomAppBarState extends State<PremiumBottomAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _degOneTranslationAnimation;
  late Animation<double> _rotationAnimation;

  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _degOneTranslationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 45.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    
    // We expect 2 items if we have a central FAB, or we align them nicely.
    // The spec says: "Bottom navigation com no máximo 4 tabs visíveis. BottomAppBar minimalista + FAB Central Animado."
    // Let's divide items: first half on the left, second half on the right.
    final int halfLength = (widget.items.length / 2).ceil();
    final leftItems = widget.items.sublist(0, halfLength);
    final rightItems = widget.items.sublist(halfLength);

    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        // Speed dial menu overlays
        if (_isMenuOpen)
          Positioned(
            bottom: 80,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.speedDialActions.length, (index) {
                final action = widget.speedDialActions[index];
                return ScaleTransition(
                  scale: _degOneTranslationAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: FloatingActionButton.extended(
                      heroTag: 'speed_dial_$index',
                      onPressed: () {
                        _toggleMenu();
                        action.onPressed();
                      },
                      label: Text(action.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      icon: Icon(action.icon, size: 20),
                      backgroundColor: AppColors.primary,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                    ),
                  ),
                );
              }),
            ),
          ),
          
        // The bottom app bar itself
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
                      final isSelected = widget.currentIndex == actualIdx;
                      return _buildNavItem(item, isSelected, actualIdx);
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
                      final isSelected = widget.currentIndex == actualIdx;
                      return _buildNavItem(item, isSelected, actualIdx);
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
          child: AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value * math.pi / 180,
                child: FloatingActionButton(
                  heroTag: 'central_fab',
                  backgroundColor: AppColors.primary,
                  elevation: 4,
                  shape: const CircleBorder(),
                  onPressed: _toggleMenu,
                  child: const Icon(
                    Icons.add,
                    color: Colors.black,
                    size: 28,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(PremiumNavItem item, bool isSelected, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = AppColors.primary;
    final inactiveColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return InkWell(
      onTap: () => widget.onTap(index),
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
