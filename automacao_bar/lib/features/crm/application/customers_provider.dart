import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class Customer {
  final String id;
  final String name;
  final String phone;
  final double currentBalance; // debt/fiado balance

  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.currentBalance = 0.0,
  });

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    double? currentBalance,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      currentBalance: currentBalance ?? this.currentBalance,
    );
  }
}

class CustomersNotifier extends Notifier<List<Customer>> {
  @override
  List<Customer> build() {
    // Initial mock customer list with active debt balances (Fiado)
    return [
      const Customer(id: 'c1', name: 'João Silva', phone: '(11) 98765-4321', currentBalance: 150.00),
      const Customer(id: 'c2', name: 'Maria Oliveira', phone: '(11) 99876-5432', currentBalance: 0.00),
      const Customer(id: 'c3', name: 'José Santos', phone: '(11) 97654-3210', currentBalance: 380.50),
      const Customer(id: 'c4', name: 'Ana Costa', phone: '(11) 96543-2109', currentBalance: 45.90),
    ];
  }

  void addCustomer(String name, String phone) {
    final id = 'c${DateTime.now().millisecondsSinceEpoch}';
    state = [...state, Customer(id: id, name: name, phone: phone)];
  }

  void chargeDebt(String id, double amount) {
    state = state.map((c) {
      if (c.id == id) {
        return c.copyWith(currentBalance: c.currentBalance + amount);
      }
      return c;
    }).toList();
  }

  void payDebt(String id, double amount) {
    state = state.map((c) {
      if (c.id == id) {
        return c.copyWith(currentBalance: (c.currentBalance - amount).clamp(0.0, double.infinity));
      }
      return c;
    }).toList();
  }
}

final customersProvider = NotifierProvider<CustomersNotifier, List<Customer>>(() {
  return CustomersNotifier();
});

// Holds the currently active customer linked to the POS cart/comanda
final selectedCustomerProvider = StateProvider<Customer?>((ref) => null);
