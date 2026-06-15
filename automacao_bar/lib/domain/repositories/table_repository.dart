import '../../core/database/app_database.dart';

abstract class ITableRepository {
  Stream<List<RestaurantTable>> watchTables();
  Future<void> insertTable(RestaurantTable table);
  Future<void> updateTableStatus(String tableId, String status);
  Future<void> updateTablePosition(String tableId, double x, double y);
  Future<void> updateTableNumber(String tableId, int number);
  Future<void> deleteTable(String tableId);
}
