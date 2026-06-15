import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/features/dashboard/application/dashboard_provider.dart';
import 'package:automacao_bar/features/dashboard/presentation/widgets/kpi_card.dart';
import 'package:automacao_bar/features/dashboard/presentation/widgets/goal_progress_card.dart';
import 'package:automacao_bar/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:automacao_bar/features/dashboard/presentation/widgets/ai_insights_card.dart';
import 'package:automacao_bar/features/dashboard/presentation/widgets/kpi_section.dart';
import 'package:automacao_bar/features/dashboard/presentation/widgets/chart_section.dart';
import 'package:automacao_bar/features/dashboard/presentation/widgets/details_section.dart';
import 'package:automacao_bar/core/database/database_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);

    // Calculate variations
    final double revenueVariation = state.totalYesterday > 0 ? ((state.totalToday - state.totalYesterday) / state.totalYesterday) * 100 : 0;
    final double ticketVariation = state.ticketAverageYesterday > 0 ? ((state.ticketAverageToday - state.ticketAverageYesterday) / state.ticketAverageYesterday) * 100 : 0;
    final double tablesVariation = state.tablesServedYesterday > 0 ? ((state.tablesServedToday - state.tablesServedYesterday) / state.tablesServedYesterday) * 100 : 0;

    final lowStockProducts = ref.watch(lowStockProductsProvider).value ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 1000;
            final isTablet = constraints.maxWidth > 600 && constraints.maxWidth <= 1000;
            final padding = isDesktop ? 32.0 : 16.0;

            // Define KPI Cards
            final kpiRevenue = KpiCard(
              title: 'FATURAMENTO HOJE',
              value: 'R\$ ${state.totalToday.toStringAsFixed(2)}',
              variationPercent: revenueVariation,
              icon: Icons.monetization_on,
              isPrimary: true,
            );

            final kpiTicket = KpiCard(
              title: 'TICKET MÉDIO',
              value: 'R\$ ${state.ticketAverageToday.toStringAsFixed(2)}',
              variationPercent: ticketVariation,
              icon: Icons.analytics,
            );

            final kpiTables = KpiCard(
              title: 'MESAS ATENDIDAS',
              value: '${state.tablesServedToday}',
              variationPercent: tablesVariation,
              icon: Icons.table_restaurant,
            );

            final goalCard = GoalProgressCard(
              current: state.totalToday,
              target: state.dailyGoal,
            );

            return SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DashboardHeader(lowStockProducts: lowStockProducts),
                  const SizedBox(height: 24),
                  
                  const AiInsightsCard(),
                  const SizedBox(height: 24),

                  KpiSection(
                    isDesktop: isDesktop,
                    isTablet: isTablet,
                    kpiRevenue: kpiRevenue,
                    kpiTicket: kpiTicket,
                    kpiTables: kpiTables,
                    goalCard: goalCard,
                  ),
                  const SizedBox(height: 24),

                  ChartSection(state: state),
                  const SizedBox(height: 24),

                  DetailsSection(
                    isDesktop: isDesktop,
                    state: state,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}