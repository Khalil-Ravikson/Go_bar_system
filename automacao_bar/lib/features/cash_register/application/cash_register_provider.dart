import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

enum CashTransactionType {
  abertura,
  suprimento,
  sangria,
  venda,
  fechamento,
}

class CashTransaction {
  final String id;
  final CashTransactionType type;
  final double amount;
  final DateTime timestamp;
  final String reason;
  final String user;

  const CashTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.timestamp,
    required this.reason,
    required this.user,
  });
}

class CashRegisterState {
  final bool isOpen;
  final DateTime? openedAt;
  final String? openedBy;
  final double initialAmount;
  final double currentAmount;
  final List<CashTransaction> transactions;
  final DateTime? closedAt;
  final double? closedAmount;

  const CashRegisterState({
    required this.isOpen,
    this.openedAt,
    this.openedBy,
    required this.initialAmount,
    required this.currentAmount,
    required this.transactions,
    this.closedAt,
    this.closedAmount,
  });

  CashRegisterState copyWith({
    bool? isOpen,
    DateTime? openedAt,
    String? openedBy,
    double? initialAmount,
    double? currentAmount,
    List<CashTransaction>? transactions,
    DateTime? closedAt,
    double? closedAmount,
  }) {
    return CashRegisterState(
      isOpen: isOpen ?? this.isOpen,
      openedAt: openedAt ?? this.openedAt,
      openedBy: openedBy ?? this.openedBy,
      initialAmount: initialAmount ?? this.initialAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      transactions: transactions ?? this.transactions,
      closedAt: closedAt ?? this.closedAt,
      closedAmount: closedAmount ?? this.closedAmount,
    );
  }
}

class CashRegisterNotifier extends Notifier<CashRegisterState> {
  @override
  CashRegisterState build() {
    return const CashRegisterState(
      isOpen: false,
      initialAmount: 0.0,
      currentAmount: 0.0,
      transactions: [],
    );
  }

  void openRegister(double initialAmount, String notes, String user) {
    final now = DateTime.now();
    final openTx = CashTransaction(
      id: const Uuid().v7(),
      type: CashTransactionType.abertura,
      amount: initialAmount,
      timestamp: now,
      reason: notes.isEmpty ? 'Abertura de caixa' : notes,
      user: user,
    );

    state = CashRegisterState(
      isOpen: true,
      openedAt: now,
      openedBy: user,
      initialAmount: initialAmount,
      currentAmount: initialAmount,
      transactions: [openTx],
    );
  }

  void addTransaction({
    required double amount,
    required CashTransactionType type,
    required String reason,
    required String user,
  }) {
    if (!state.isOpen) return;

    final now = DateTime.now();
    final newTx = CashTransaction(
      id: const Uuid().v7(),
      type: type,
      amount: amount,
      timestamp: now,
      reason: reason,
      user: user,
    );

    double newCurrent = state.currentAmount;
    if (type == CashTransactionType.sangria) {
      newCurrent -= amount;
    } else {
      newCurrent += amount;
    }

    state = state.copyWith(
      currentAmount: newCurrent,
      transactions: [newTx, ...state.transactions],
    );
  }

  void closeRegister(double realAmount, String notes, String user) {
    if (!state.isOpen) return;

    final now = DateTime.now();
    final closeTx = CashTransaction(
      id: const Uuid().v7(),
      type: CashTransactionType.fechamento,
      amount: realAmount,
      timestamp: now,
      reason: notes.isEmpty ? 'Fechamento de caixa' : notes,
      user: user,
    );

    state = state.copyWith(
      isOpen: false,
      closedAt: now,
      closedAmount: realAmount,
      currentAmount: 0.0,
      transactions: [closeTx, ...state.transactions],
    );
  }
}

final cashRegisterProvider = NotifierProvider<CashRegisterNotifier, CashRegisterState>(() {
  return CashRegisterNotifier();
});
