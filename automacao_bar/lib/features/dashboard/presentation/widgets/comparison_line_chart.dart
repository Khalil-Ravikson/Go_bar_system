import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';

class ComparisonLineChart extends StatelessWidget {
  final List<FlSpot> todaySpots;
  final List<FlSpot> yesterdaySpots;

  const ComparisonLineChart({
    super.key,
    required this.todaySpots,
    required this.yesterdaySpots,
  });

  @override
  Widget build(BuildContext context) {
    // Yesterday curve (thin dashed grey)
    final LineChartBarData yesterdayLineData = LineChartBarData(
      spots: yesterdaySpots,
      isCurved: true,
      color: AppColors.textMuted.withValues(alpha: 0.3),
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      dashArray: [6, 4],
    );

    // Today curve (thick neon green with glow and gradient below)
    final LineChartBarData todayLineData = LineChartBarData(
      spots: todaySpots,
      isCurved: true,
      color: AppColors.neonGreen,
      barWidth: 4,
      isStrokeCapRound: true,
      shadow: Shadow(
        color: AppColors.neonGreen.withValues(alpha: 0.4),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          final isLast = index == barData.spots.length - 1;
          if (isLast) {
            return FlDotCirclePainter(
              radius: 6,
              color: AppColors.neonGreen,
              strokeWidth: 3,
              strokeColor: Colors.white,
            );
          }
          return FlDotCirclePainter(
            radius: 0,
            color: Colors.transparent,
            strokeColor: Colors.transparent,
            strokeWidth: 0,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            AppColors.neonGreen.withValues(alpha: 0.15),
            AppColors.neonGreen.withValues(alpha: 0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );

    return AspectRatio(
      aspectRatio: 2.0, // perfect proportion for dashboard
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            drawHorizontalLine: true,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.surfaceLight.withValues(alpha: 0.5),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final int hour = value.toInt();
                  if (hour % 2 != 0) return const SizedBox.shrink();
                  String label = '';
                  if (hour >= 24) {
                    label = '0${hour - 24}:00';
                  } else {
                    label = '$hour:00';
                  }
                  return SideTitleWidget(
                    meta: meta,
                    space: 8,
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                interval: 300,
                getTitlesWidget: (value, meta) {
                  if (value == meta.min) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(
                    meta: meta,
                    space: 8,
                    child: Text(
                      'R\$ ${value.toInt()}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 18,
          maxX: 26,
          minY: 0,
          maxY: 1400,
          lineBarsData: [yesterdayLineData, todayLineData],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedBarSpot) => AppColors.surface,
              tooltipBorder: const BorderSide(color: AppColors.surfaceLight, width: 1),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((barSpot) {
                  final isToday = barSpot.barIndex == 1;
                  return LineTooltipItem(
                    '${isToday ? "Hoje" : "Ontem"}: R\$ ${barSpot.y.toStringAsFixed(2)}',
                    TextStyle(
                      color: isToday ? AppColors.neonGreen : AppColors.textMain,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}
