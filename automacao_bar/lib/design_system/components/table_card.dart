import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// O Enum que define os estados possíveis de uma mesa
enum TableStatus { free, occupied, closing }

class TableCard extends StatefulWidget {
  final String tableNumber;
  final TableStatus status;
  final String infoText;
  final String? valueText; // Ex: Total gasto até agora
  final VoidCallback onTap;
  final int elapsedMinutes; // New

  const TableCard({
    super.key,
    required this.tableNumber,
    required this.status,
    required this.infoText,
    this.valueText,
    required this.onTap,
    this.elapsedMinutes = 0,
  });

  @override
  State<TableCard> createState() => _TableCardState();
}

class _TableCardState extends State<TableCard> with SingleTickerProviderStateMixin {
  AnimationController? _pulseController;
  Animation<Color?>? _borderColorAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  @override
  void didUpdateWidget(covariant TableCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initAnimation();
  }

  void _initAnimation() {
    final isCritical = widget.elapsedMinutes > 25 && widget.status != TableStatus.free;
    if (isCritical) {
      if (_pulseController == null) {
        _pulseController = AnimationController(
          vsync: this,
          duration: const Duration(seconds: 1),
        )..repeat(reverse: true);
        
        _borderColorAnimation = ColorTween(
          begin: AppColors.orange,
          end: AppColors.danger,
        ).animate(_pulseController!);
      }
    } else {
      _pulseController?.dispose();
      _pulseController = null;
      _borderColorAnimation = null;
    }
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  Color _getStatusColor() {
    switch (widget.status) {
      case TableStatus.free:
        return AppColors.textMuted; // Cinzento
      case TableStatus.occupied:
        return AppColors.primaryNeon; // Verde Neon
      case TableStatus.closing:
        return AppColors.orange; // Laranja Alerta
    }
  }

  Color _getBgColor() {
    switch (widget.status) {
      case TableStatus.free:
        return AppColors.surface;
      case TableStatus.occupied:
        return AppColors.primaryNeon.withOpacity(0.05);
      case TableStatus.closing:
        return AppColors.orange.withOpacity(0.05);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final isFree = widget.status == TableStatus.free;
    final isCritical = widget.elapsedMinutes > 25 && widget.status != TableStatus.free;

    Widget cardContent(Color currentBorderColor) {
      return InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getBgColor(),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: currentBorderColor,
              width: isFree ? 1 : 1.8,
            ),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'MESA ${widget.tableNumber}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isFree ? AppColors.textSecondary : statusColor,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.infoText,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.valueText != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.valueText!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ]
                    ],
                  ),
                ],
              ),
              
              // Status point on top-right corner
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    boxShadow: isFree ? null : [
                      BoxShadow(
                        color: statusColor.withOpacity(0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isCritical && _borderColorAnimation != null) {
      return AnimatedBuilder(
        animation: _borderColorAnimation!,
        builder: (context, child) {
          final color = _borderColorAnimation!.value ?? AppColors.orange;
          return cardContent(color);
        },
      );
    }

    return cardContent(isFree ? AppColors.border : statusColor.withOpacity(0.4));
  }
}