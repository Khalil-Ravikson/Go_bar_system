import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../network/remote_database_client.dart';
import '../network/supabase_client_impl.dart';
import '../network/sync_manager.dart';
import '../database/database_provider.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final remoteDatabaseClientProvider = Provider<IRemoteDatabaseClient>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseClientImpl(client);
});

final syncManagerProvider = Provider<SyncManager>((ref) {
  final db = ref.watch(databaseProvider);
  final remoteClient = ref.watch(remoteDatabaseClientProvider);
  final isGuest = ref.watch(authProvider) == null;
  return SyncManager(db, remoteClient, isGuest);
});
