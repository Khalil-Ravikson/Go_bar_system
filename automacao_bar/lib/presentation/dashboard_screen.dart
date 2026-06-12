import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/features/dashboard/application/dashboard_provider.dart';
import 'package:automacao_bar/features/dashboard/presentation/widgets/kpi_card.dart';
import 'package:automacao_bar/features/dashboard/presentation/widgets/goal_progress_card.dart';
import 'package:automacao_bar/features/dashboard/presentation/widgets/comparison_line_chart.dart';
import 'package:automacao_bar/features/inventory/application/inventory_provider.dart';
import 'package:automacao_bar/features/management/application/ingredients_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);

    // Calculate variations
    final double revenueVariation = ((state.totalToday - state.totalYesterday) / state.totalYesterday) * 100;
    final double ticketVariation = ((state.ticketAverageToday - state.ticketAverageYesterday) / state.ticketAverageYesterday) * 100;
    final double tablesVariation = ((state.tablesServedToday - state.tablesServedYesterday) / state.tablesServedYesterday) * 100;

    final lowStockIngredients = ref.watch(lowStockIngredientsProvider);

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
                  // 1. HEADER
                  _buildHeader(context, lowStockIngredients),
                  const SizedBox(height: 24),

                  // 2. KPI / METRIC ROW (Responsive Layout)
                  _buildKpiSection(isDesktop, isTablet, kpiRevenue, kpiTicket, kpiTables, goalCard),
                  const SizedBox(height: 24),

                  // 3. MAIN COMPARISON CHART
                  _buildChartSection(state),
                  const SizedBox(height: 24),

                  // 4. TOP PRODUCTS & CATEGORY BREAKDOWN
                  _buildDetailsSection(isDesktop, state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ==========================================
  // HEADER WIDGET
  // ==========================================
  Widget _buildHeader(BuildContext context, List<Ingredient> lowStockIngredients) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Visão Executiva',
              style: TextStyle(
                color: AppColors.textMain,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Painel de Business Intelligence • Tempo Real',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            if (lowStockIngredients.isNotEmpty) {
              _showLowStockBottomSheet(context, lowStockIngredients);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Estoque saudável! Nenhuma quebra crítica reportada.', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  backgroundColor: AppColors.neonGreen,
                ),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceLight),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none, color: AppColors.neonGreen, size: 24),
                if (lowStockIngredients.isNotEmpty)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        '${lowStockIngredients.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showLowStockBottomSheet(BuildContext context, List<Ingredient> items) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: AppColors.danger),
                      SizedBox(width: 10),
                      Text(
                        'Alertas de Estoque Baixo',
                        style: TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Os seguintes ingredientes atingiram níveis críticos de stock e necessitam reabastecimento imediato:',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (context, _) => const Divider(color: AppColors.surfaceLight),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.inventory_2_outlined, color: AppColors.danger),
                      title: Text(item.name, style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        'Mínimo de segurança: ${item.minStock.toStringAsFixed(1)} ${item.unitMeasure}',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                      trailing: Text(
                        '${item.inStock.toStringAsFixed(1)} ${item.unitMeasure}',
                        style: const TextStyle(color: AppColors.danger, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // RESPONSIVE KPI CARD GRID BUILDER
  // ==========================================
  Widget _buildKpiSection(
    bool isDesktop,
    bool isTablet,
    Widget kpiRevenue,
    Widget kpiTicket,
    Widget kpiTables,
    Widget goalCard,
  ) {
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

  // ==========================================
  // CHART CONTAINER
  // ==========================================
  Widget _buildChartSection(DashboardState state) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Desempenho de Vendas',
                    style: TextStyle(
                      color: AppColors.textMain,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Comparativo de faturamento de hoje com o dia anterior',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
              // Legend Indicators
              Row(
                children: [
                  _buildLegendDot(AppColors.textMuted.withValues(alpha: 0.5), 'Ontem'),
                  const SizedBox(width: 16),
                  _buildLegendDot(AppColors.neonGreen, 'Hoje'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          ComparisonLineChart(
            todaySpots: state.todaySalesPerHour,
            yesterdaySpots: state.yesterdaySalesPerHour,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // BOTTOM LISTS SECTION (Responsive)
  // ==========================================
  Widget _buildDetailsSection(bool isDesktop, DashboardState state) {
    final topProductsPanel = _buildTopProductsCard(state.topProducts);
    final categorySalesPanel = _buildCategorySalesCard(state.categorySales);

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: topProductsPanel),
          const SizedBox(width: 24),
          Expanded(child: categorySalesPanel),
        ],
      );
    } else {
      return Column(
        children: [
          topProductsPanel,
          const SizedBox(height: 24),
          categorySalesPanel,
        ],
      );
    }
  }

  Widget _buildTopProductsCard(List<Map<String, dynamic>> products) {
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
          const Text(
            'Top 5 Produtos mais Vendidos',
            style: TextStyle(
              color: AppColors.textMain,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            separatorBuilder: (context, index) => const Divider(color: AppColors.surfaceLight, height: 24),
            itemBuilder: (context, index) {
              final prod = products[index];
              return Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.surfaceLight,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: AppColors.neonGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prod['name'] as String,
                          style: const TextStyle(
                            color: AppColors.textMain,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${prod['qty']} unidades',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'R\$ ${(prod['total'] as double).toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.textMain,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySalesCard(List<Map<String, dynamic>> categories) {
    // Calculate category grand total
    final double grandTotal = categories.fold(0.0, (sum, cat) => sum + (cat['total'] as double));

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
          const Text(
            'Vendas por Categoria',
            style: TextStyle(
              color: AppColors.textMain,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Column(
            children: categories.map((cat) {
              final name = cat['name'] as String;
              final total = cat['total'] as double;
              final color = Color(cat['color'] as int);
              final double pct = grandTotal > 0 ? total / grandTotal : 0.0;

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            name,
                            style: const TextStyle(
                              color: AppColors.textMain,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'R\$ ${total.toStringAsFixed(2)} (${(pct * 100).toStringAsFixed(1)}%)',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 6,
                      backgroundColor: AppColors.surfaceLight,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}