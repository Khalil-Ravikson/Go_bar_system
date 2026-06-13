import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../inventory/application/inventory_provider.dart';

class DashboardState {
  final double totalToday;
  final double totalYesterday;
  final double dailyGoal;
  
  final double ticketAverageToday;
  final double ticketAverageYesterday;
  
  final int tablesServedToday;
  final int tablesServedYesterday;

  final List<FlSpot> todaySalesPerHour;
  final List<FlSpot> yesterdaySalesPerHour;

  final List<Map<String, dynamic>> topProducts;
  final List<Map<String, dynamic>> categorySales;

  const DashboardState({
    required this.totalToday,
    required this.totalYesterday,
    required this.dailyGoal,
    required this.ticketAverageToday,
    required this.ticketAverageYesterday,
    required this.tablesServedToday,
    required this.tablesServedYesterday,
    required this.todaySalesPerHour,
    required this.yesterdaySalesPerHour,
    required this.topProducts,
    required this.categorySales,
  });

  DashboardState copyWith({
    double? totalToday,
    double? totalYesterday,
    double? dailyGoal,
    double? ticketAverageToday,
    double? ticketAverageYesterday,
    int? tablesServedToday,
    int? tablesServedYesterday,
    List<FlSpot>? todaySalesPerHour,
    List<FlSpot>? yesterdaySalesPerHour,
    List<Map<String, dynamic>>? topProducts,
    List<Map<String, dynamic>>? categorySales,
  }) {
    return DashboardState(
      totalToday: totalToday ?? this.totalToday,
      totalYesterday: totalYesterday ?? this.totalYesterday,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      ticketAverageToday: ticketAverageToday ?? this.ticketAverageToday,
      ticketAverageYesterday: ticketAverageYesterday ?? this.ticketAverageYesterday,
      tablesServedToday: tablesServedToday ?? this.tablesServedToday,
      tablesServedYesterday: tablesServedYesterday ?? this.tablesServedYesterday,
      todaySalesPerHour: todaySalesPerHour ?? this.todaySalesPerHour,
      yesterdaySalesPerHour: yesterdaySalesPerHour ?? this.yesterdaySalesPerHour,
      topProducts: topProducts ?? this.topProducts,
      categorySales: categorySales ?? this.categorySales,
    );
  }
}

class DashboardNotifier extends Notifier<DashboardState> {
  @override
  DashboardState build() {
    return DashboardState(
      totalToday: 4200.00,
      totalYesterday: 3800.00,
      dailyGoal: 5000.00,
      ticketAverageToday: 68.50,
      ticketAverageYesterday: 61.20,
      tablesServedToday: 58,
      tablesServedYesterday: 62,
      todaySalesPerHour: const [
        FlSpot(18, 120),
        FlSpot(19, 350),
        FlSpot(20, 680),
        FlSpot(21, 950),
        FlSpot(22, 1200),
        FlSpot(23, 900),
      ],
      yesterdaySalesPerHour: const [
        FlSpot(18, 100),
        FlSpot(19, 280),
        FlSpot(20, 590),
        FlSpot(21, 850),
        FlSpot(22, 1100),
        FlSpot(23, 750),
        FlSpot(24, 420),
        FlSpot(25, 200),
        FlSpot(26, 110), // 26 represents 02:00 (24h + 2)
      ],
      topProducts: const [
        {'name': 'Hambúrguer Clássico', 'qty': 85, 'total': 2541.50},
        {'name': 'Chopp Brahma 300ml', 'qty': 154, 'total': 1524.60},
        {'name': 'Porção de Batatas Fritas', 'qty': 62, 'total': 1233.80},
        {'name': 'Gin Tônica Tropical', 'qty': 48, 'total': 1195.20},
        {'name': 'Heineken Long Neck', 'qty': 92, 'total': 1104.00},
      ],
      categorySales: const [
        {'name': 'Lanches', 'total': 2541.50, 'color': 0xFF00FF88}, // neonGreen
        {'name': 'Bebidas', 'total': 3823.80, 'color': 0xFF00E5FF}, // neonTeal
        {'name': 'Porções', 'total': 1233.80, 'color': 0xFFFFAA00}, // neonOrange/warning
      ],
    );
  }
}

final dashboardProvider = NotifierProvider<DashboardNotifier, DashboardState>(() {
  return DashboardNotifier();
});

// Dynamic AI insights generator provider
final aiInsightsProvider = Provider<String>((ref) {
  final dashboard = ref.watch(dashboardProvider);
  final lowStock = ref.watch(lowStockIngredientsProvider);

  if (lowStock.isNotEmpty) {
    final names = lowStock.map((e) => e.name).join(', ');
    return 'Alerta de Insumo: Os ingredientes ($names) estão abaixo do limite mínimo de segurança. Sugerimos registrar uma nota de compra de reposição.';
  }

  final goalPct = (dashboard.totalToday / dashboard.dailyGoal) * 100;
  if (goalPct >= 100) {
    return 'Meta Batida! O faturamento de hoje atingiu ${goalPct.toStringAsFixed(0)}% da meta diária de vendas. Excelente desempenho da equipe!';
  }

  return 'GoBar AI Insights: As vendas de Bebidas cresceram 30% nas últimas horas. Sugerimos reforçar o estoque de Heineken Long Neck para o fim de semana.';
});
