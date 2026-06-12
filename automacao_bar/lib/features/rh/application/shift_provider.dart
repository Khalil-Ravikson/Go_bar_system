import 'package:flutter_riverpod/flutter_riverpod.dart';

class Shift {
  final String? id;
  final String? waiterName;
  final int? startTime; // epoch timestamp
  final int? endTime; // epoch timestamp
  final double totalSales;
  final double tipsEarned;
  final bool isActive;

  const Shift({
    this.id,
    this.waiterName,
    this.startTime,
    this.endTime,
    this.totalSales = 0.0,
    this.tipsEarned = 0.0,
    this.isActive = false,
  });

  Shift copyWith({
    String? id,
    String? waiterName,
    int? startTime,
    int? endTime,
    double? totalSales,
    double? tipsEarned,
    bool? isActive,
  }) {
    return Shift(
      id: id ?? this.id,
      waiterName: waiterName ?? this.waiterName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalSales: totalSales ?? this.totalSales,
      tipsEarned: tipsEarned ?? this.tipsEarned,
      isActive: isActive ?? this.isActive,
    );
  }
}

class ShiftNotifier extends Notifier<Shift> {
  @override
  Shift build() {
    return const Shift();
  }

  void clockIn(String waiterName) {
    state = Shift(
      id: 's_${DateTime.now().millisecondsSinceEpoch}',
      waiterName: waiterName,
      startTime: DateTime.now().millisecondsSinceEpoch,
      isActive: true,
      totalSales: 0.0,
      tipsEarned: 0.0,
    );
  }

  void addSale(double amount) {
    if (!state.isActive) return;
    final newTotalSales = state.totalSales + amount;
    state = state.copyWith(
      totalSales: newTotalSales,
      // 10% calculated dynamically
      tipsEarned: newTotalSales * 0.10,
    );
  }

  void clockOut() {
    if (!state.isActive) return;
    state = state.copyWith(
      endTime: DateTime.now().millisecondsSinceEpoch,
      isActive: false,
    );
  }

  void reset() {
    state = const Shift();
  }
}

final shiftProvider = NotifierProvider<ShiftNotifier, Shift>(() {
  return ShiftNotifier();
});
