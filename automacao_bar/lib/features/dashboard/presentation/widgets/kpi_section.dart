import 'package:flutter/material.dart';

class KpiSection extends StatelessWidget {
  final bool isDesktop;
  final bool isTablet;
  final Widget kpiRevenue;
  final Widget kpiTicket;
  final Widget kpiTables;
  final Widget goalCard;

  const KpiSection({
    super.key,
    required this.isDesktop,
    required this.isTablet,
    required this.kpiRevenue,
    required this.kpiTicket,
    required this.kpiTables,
    required this.goalCard,
  });

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return Row(
        children: [
          Expanded(child: kpiRevenue),
          const SizedBox(width: 16),
          Expanded(child: kpiTicket),
          const SizedBox(width: 16),
          Expanded(child: kpiTables),
          const SizedBox(width: 16),
          Expanded(child: goalCard),
        ],
      );
    } else if (isTablet) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: kpiRevenue),
              const SizedBox(width: 16),
              Expanded(child: kpiTicket),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: kpiTables),
              const SizedBox(width: 16),
              Expanded(child: goalCard),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: [
          kpiRevenue,
          const SizedBox(height: 16),
          kpiTicket,
          const SizedBox(height: 16),
          kpiTables,
          const SizedBox(height: 16),
          goalCard,
        ],
      );
    }
  }
}
