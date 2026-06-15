import 'package:supabase_flutter/supabase_flutter.dart';
import 'remote_database_client.dart';

class SupabaseClientImpl implements IRemoteDatabaseClient {
  final SupabaseClient _supabaseClient;

  SupabaseClientImpl(this._supabaseClient);

  @override
  Future<void> upsert(String tableName, Map<String, dynamic> payload) async {
    await _supabaseClient.from(tableName).upsert(payload);
  }

  @override
  Future<void> delete(String tableName, String id) async {
    await _supabaseClient.from(tableName).delete().eq('id', id);
  }
}
