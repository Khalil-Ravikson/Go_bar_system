import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database_provider.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/table_repository.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/repositories/table_repository_impl.dart';

final orderRepositoryProvider = Provider<IOrderRepository>((ref) {
  final dao = ref.watch(ordersDaoProvider);
  return OrderRepositoryImpl(dao);
});

final productRepositoryProvider = Provider<IProductRepository>((ref) {
  final dao = ref.watch(productsDaoProvider);
  return ProductRepositoryImpl(dao);
});

final tableRepositoryProvider = Provider<ITableRepository>((ref) {
  final dao = ref.watch(tablesDaoProvider);
  return TableRepositoryImpl(dao);
});
