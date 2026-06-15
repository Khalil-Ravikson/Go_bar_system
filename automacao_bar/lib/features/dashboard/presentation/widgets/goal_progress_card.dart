import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';

/// Paints a circular arc progress gauge — premium SaaS style.
/// The arc sweeps from 7 o'clock position (225°) covering 270° total.
class _ArcProgressPainter extends CustomPainter {
  final double progress; // 0.0 – 1.0
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  const _ArcProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    this.strokeWidth = 10.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    const startAngle = math.pi * 0.75; // 135° → 7 o'clock
    const sweepTotal = math.pi * 1.5;  // 270° arc

    // Track (background)
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepTotal,
      false,
      trackPaint,
    );

    // Progress arc
    final progressPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: startAngle,
        endAngle: startAngle + sweepTotal,
        colors: [
          progressColor.withValues(alpha: 0.7),
          progressColor,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepTotal * progress.clamp(0.0, 1.0),
      false,
      progressPaint,
    );

    // Neon glow halo (optional, behind progress arc)
    if (progress > 0) {
      final glowPaint = Paint()
        ..color = progressColor.withValues(alpha: 0.12)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth + 8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
        ..style = PaintingStyle.stroke;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepTotal * progress.clamp(0.0, 1.0),
        false,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcProgressPainter old) =>
      old.progress != progress ||
      old.trackColor != trackColor ||
      old.progressColor != progressColor;
}

class GoalProgressCard extends StatelessWidget {
  final double current;
  final double target;
  final String title;

  const GoalProgressCard({
    super.key,
    required this.current,
    required this.target,
    this.title = 'Meta Diária de Vendas',
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = (current / target).clamp(0.0, 1.0);
    final int percentInt = (percentage * 100).toInt();
    final bool achieved = percentage >= 1.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),

          // Arc gauge
          Center(
            child: SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(140, 140),
                    painter: _ArcProgressPainter(
                      progress: percentage,
                      trackColor: AppColors.surfaceLight,
                      progressColor: achieved
                          ? AppColors.neonGreen
                          : AppColors.neonGreen,
                    ),
                  ),
                  // Center label
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          '$percentInt%',
                          key: ValueKey<int>(percentInt),
                          style: TextStyle(
                            color: achieved
                                ? AppColors.neonGreen
                                : AppColors.textMain,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'da meta',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Values row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  'R\$ ${current.toStringAsFixed(0)}',
                  key: ValueKey<double>(current),
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                'de R\$ ${target.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Status message
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              achieved
                  ? '🎉 Parabéns! Meta diária atingida!'
                  : 'Faltam R\$ ${(target - current).toStringAsFixed(0)} para atingir a meta.',
              key: ValueKey<String>('$percentage'),
              style: TextStyle(
                color: achieved ? AppColors.neonGreen : AppColors.textMuted,
                fontSize: 12,
                fontStyle:
                    achieved ? FontStyle.normal : FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
