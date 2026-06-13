import 'package:flutter_riverpod/flutter_riverpod.dart';

// Courier Model
class Courier {
  final String id;
  final String name;
  final String phone;
  final String deliveryFeeConfig;

  const Courier({
    required this.id,
    required this.name,
    required this.phone,
    required this.deliveryFeeConfig,
  });
}

// DeliveryOrder Model
class DeliveryOrder {
  final String id;
  final String orderId;
  final String? courierId; // Nullable until assigned
  final String customerAddress;
  final String status; // 'preparando', 'a_caminho', 'entregue'
  final double deliveryFee;
  final List<Map<String, dynamic>> items;
  final double totalAmount;
  final bool isSettled; // Paid to courier at end-of-day

  const DeliveryOrder({
    required this.id,
    required this.orderId,
    this.courierId,
    required this.customerAddress,
    required this.status,
    required this.deliveryFee,
    required this.items,
    required this.totalAmount,
    this.isSettled = false,
  });

  DeliveryOrder copyWith({
    String? id,
    String? orderId,
    String? courierId,
    String? customerAddress,
    String? status,
    double? deliveryFee,
    List<Map<String, dynamic>>? items,
    double? totalAmount,
    bool? isSettled,
  }) {
    return DeliveryOrder(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      courierId: courierId, // allow setting to null or new value
      customerAddress: customerAddress ?? this.customerAddress,
      status: status ?? this.status,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      isSettled: isSettled ?? this.isSettled,
    );
  }
}

// Pre-populated Couriers Provider
final couriersProvider = Provider<List<Courier>>((ref) {
  return [
    const Courier(id: 'co1', name: 'Ramon Motoboy', phone: '(11) 91111-2222', deliveryFeeConfig: 'R\$ 7.00 fixo'),
    const Courier(id: 'co2', name: 'Carlos Veloz', phone: '(11) 93333-4444', deliveryFeeConfig: 'R\$ 9.00 fixo'),
    const Courier(id: 'co3', name: 'Ana Delivery', phone: '(11) 95555-6666', deliveryFeeConfig: 'R\$ 8.50 fixo'),
  ];
});

// Delivery Orders State Manager
class DeliveryOrdersNotifier extends Notifier<List<DeliveryOrder>> {
  @override
  List<DeliveryOrder> build() {
    // Standard mock data to make screen interactive instantly
    return [
      const DeliveryOrder(
        id: 'd1',
        orderId: 'do1',
        courierId: null,
        customerAddress: 'Rua das Flores, 123 - Apt 4',
        status: 'preparando',
        deliveryFee: 7.00,
        items: [
          {'name': 'Hambúrguer Clássico', 'quantity': 2},
          {'name': 'Heineken Long Neck', 'quantity': 2},
        ],
        totalAmount: 71.80,
      ),
      const DeliveryOrder(
        id: 'd2',
        orderId: 'do2',
        courierId: 'co1',
        customerAddress: 'Av. Paulista, 1000 - Cj 81',
        status: 'a_caminho',
        deliveryFee: 9.00,
        items: [
          {'name': 'Porção de Batatas Fritas', 'quantity': 1},
          {'name': 'Gin Tônica Tropical', 'quantity': 2},
        ],
        totalAmount: 77.80,
      ),
      const DeliveryOrder(
        id: 'd3',
        orderId: 'do3',
        courierId: 'co2',
        customerAddress: 'Alameda Lorena, 456',
        status: 'entregue',
        deliveryFee: 8.00,
        items: [
          {'name': 'Hambúrguer Clássico', 'quantity': 1},
          {'name': 'Caipirinha de Limão', 'quantity': 1},
        ],
        totalAmount: 44.90,
        isSettled: false,
      ),
      const DeliveryOrder(
        id: 'd4',
        orderId: 'do4',
        courierId: 'co1',
        customerAddress: 'Rua Bela Cintra, 789',
        status: 'entregue',
        deliveryFee: 7.00,
        items: [
          {'name': 'Hambúrguer Clássico', 'quantity': 1},
        ],
        totalAmount: 29.90,
        isSettled: false,
      ),
    ];
  }

  void assignCourier(String deliveryId, String? courierId) {
    state = state.map((d) {
      if (d.id == deliveryId) {
        return d.copyWith(courierId: courierId);
      }
      return d;
    }).toList();
  }

  void updateDeliveryStatus(String deliveryId, String status) {
    state = state.map((d) {
      if (d.id == deliveryId) {
        return d.copyWith(status: status);
      }
      return d;
    }).toList();
  }

  void settleCourier(String courierId) {
    state = state.map((d) {
      if (d.courierId == courierId && d.status == 'entregue' && !d.isSettled) {
        return d.copyWith(isSettled: true);
      }
      return d;
    }).toList();
  }

  void createDeliveryOrder({
    required String customerAddress,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    double deliveryFee = 7.00,
  }) {
    final newId = 'd${DateTime.now().millisecondsSinceEpoch}';
    final orderId = 'do${DateTime.now().millisecondsSinceEpoch}';
    
    final newOrder = DeliveryOrder(
      id: newId,
      orderId: orderId,
      customerAddress: customerAddress,
      status: 'preparando',
      deliveryFee: deliveryFee,
      items: items,
      totalAmount: totalAmount,
    );
    state = [...state, newOrder];
  }
}

final deliveryOrdersProvider = NotifierProvider<DeliveryOrdersNotifier, List<DeliveryOrder>>(() {
  return DeliveryOrdersNotifier();
});
