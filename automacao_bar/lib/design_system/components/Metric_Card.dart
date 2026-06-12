import 'package:automacao_bar/design_system/theme/app_colors.dart';
import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtext;
  final double progressPercent; // 0.0 to 1.0
  final bool isTrendUp;
  final Color accentColor;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.subtext,
    required this.progressPercent,
    this.isTrendUp = true,
    this.accentColor = AppColors.neonGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: accentColor == AppColors.neonGreen ? accentColor : AppColors.textPrimary,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                isTrendUp ? '▲' : '▼',
                style: TextStyle(
                  fontSize: 10,
                  color: isTrendUp ? AppColors.neonGreen : AppColors.red,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  subtext,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildProgressBar(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 3,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceHighlight,
        borderRadius: BorderRadius.circular(2),
      ),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: progressPercent.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: LinearGradient(
              colors: [
                accentColor.withOpacity(0.6),
                accentColor,
              ],
            ),
          ),
        ),
      ),
    );
  }
}