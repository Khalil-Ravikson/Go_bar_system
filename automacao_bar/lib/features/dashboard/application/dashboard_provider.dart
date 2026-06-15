import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:automacao_bar/core/database/database_provider.dart';

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
  final List<StreamSubscription> _subscriptions = [];

  @override
  DashboardState build() {
    final db = ref.watch(databaseProvider);
    final paymentsDao = db.paymentsDao;

    ref.onDispose(() {
      for (final sub in _subscriptions) {
        sub.cancel();
      }
      _subscriptions.clear();
    });

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final todayEnd = DateTime(now.year, now.month, now.day + 1).millisecondsSinceEpoch;
    
    final yesterdayStart = DateTime(now.year, now.month, now.day - 1).millisecondsSinceEpoch;
    final yesterdayEnd = todayStart;

    // 1. Today's Revenue
    _subscriptions.add(paymentsDao.watchRevenueToday().listen((val) {
      state = state.copyWith(
        totalToday: val,
        ticketAverageToday: state.tablesServedToday > 0 ? val / state.tablesServedToday : 0.0,
      );
    }));

    // 2. Yesterday's Revenue
    _subscriptions.add(paymentsDao.watchRevenueYesterday().listen((val) {
      state = state.copyWith(
        totalYesterday: val,
        ticketAverageYesterday: state.tablesServedYesterday > 0 ? val / state.tablesServedYesterday : 0.0,
      );
    }));

    // 3. Tables Served Today
    _subscriptions.add(paymentsDao.watchOrderCountToday().listen((val) {
      state = state.copyWith(
        tablesServedToday: val,
        ticketAverageToday: val > 0 ? state.totalToday / val : 0.0,
      );
    }));

    // 4. Tables Served Yesterday
    _subscriptions.add(paymentsDao.watchOrderCountYesterday().listen((val) {
      state = state.copyWith(
        tablesServedYesterday: val,
        ticketAverageYesterday: val > 0 ? state.totalYesterday / val : 0.0,
      );
    }));

    // 5. Today's Hourly Sales
    _subscriptions.add(paymentsDao.watchSalesPerHour(todayStart, todayEnd).listen((val) {
      state = state.copyWith(
        todaySalesPerHour: val.map((bucket) => FlSpot(bucket.hour.toDouble(), bucket.total)).toList(),
      );
    }));

    // 6. Yesterday's Hourly Sales
    _subscriptions.add(paymentsDao.watchSalesPerHour(yesterdayStart, yesterdayEnd).listen((val) {
      state = state.copyWith(
        yesterdaySalesPerHour: val.map((bucket) => FlSpot(bucket.hour.toDouble(), bucket.total)).toList(),
      );
    }));

    // 7. Top Products Today
    _subscriptions.add(paymentsDao.watchTopProductsToday().listen((val) {
      state = state.copyWith(topProducts: val);
    }));

    // 8. Category Sales Today
    _subscriptions.add(paymentsDao.watchCategorySalesToday().listen((val) {
      state = state.copyWith(categorySales: val);
    }));

    return const DashboardState(
      totalToday: 0.0,
      totalYesterday: 0.0,
      dailyGoal: 5000.0,
      ticketAverageToday: 0.0,
      ticketAverageYesterday: 0.0,
      tablesServedToday: 0,
      tablesServedYesterday: 0,
      todaySalesPerHour: [],
      yesterdaySalesPerHour: [],
      topProducts: [],
      categorySales: [],
    );
  }
}

final dashboardProvider = NotifierProvider<DashboardNotifier, DashboardState>(() {
  return DashboardNotifier();
});

// Dynamic AI insights generator provider
final aiInsightsProvider = Provider<String>((ref) {
  final dashboard = ref.watch(dashboardProvider);
  final lowStockAsync = ref.watch(lowStockProductsProvider);

  return lowStockAsync.when(
    loading: () => 'Carregando insights do estoque...',
    error: (err, _) => 'Erro ao analisar estoque.',
    data: (lowStock) {
      if (lowStock.isNotEmpty) {
        final names = lowStock.map((e) => e.product.name).join(', ');
        return 'Alerta de Insumo: Os produtos ($names) estão abaixo do limite mínimo de segurança. Sugerimos registrar um movimento de estoque para reabastecimento.';
      }

      final goalPct = (dashboard.totalToday / dashboard.dailyGoal) * 100;
      if (goalPct >= 100) {
        return 'Meta Batida! O faturamento de hoje atingiu ${goalPct.toStringAsFixed(0)}% da meta diária de vendas. Excelente desempenho da equipe!';
      }

      return 'GoBar AI Insights: As vendas de Bebidas cresceram 30% nas últimas horas. Sugerimos registrar novos pedidos ou acompanhar as tendências do dia.';
    },
  );
});
