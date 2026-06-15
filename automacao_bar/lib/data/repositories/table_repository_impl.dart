import '../../core/database/app_database.dart';
import '../../core/database/daos/tables_dao.dart';
import '../../domain/repositories/table_repository.dart';

class TableRepositoryImpl implements ITableRepository {
  final TablesDao _tablesDao;

  TableRepositoryImpl(this._tablesDao);

  @override
  Stream<List<RestaurantTable>> watchTables() => _tablesDao.watchTables();

  @override
  Future<void> insertTable(RestaurantTable table) => _tablesDao.insertTable(table);

  @override
  Future<void> updateTableStatus(String tableId, String status) =>
      _tablesDao.updateTableStatus(tableId, status);

  @override
  Future<void> updateTablePosition(String tableId, double x, double y) =>
      _tablesDao.updateTablePosition(tableId, x, y);

  @override
  Future<void> updateTableNumber(String tableId, int number) =>
      _tablesDao.updateTableNumber(tableId, number);

  @override
  Future<void> deleteTable(String tableId) =>
      _tablesDao.deleteTable(tableId);
}
