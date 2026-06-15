abstract class IRemoteDatabaseClient {
  Future<void> upsert(String tableName, Map<String, dynamic> payload);
  Future<void> delete(String tableName, String id);
}
