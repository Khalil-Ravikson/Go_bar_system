import 'package:dio/dio.dart';
import '../database/daos/orders_dao.dart';
import '../database/app_database.dart';

class SyncService {
  final OrdersDao _dao;
  final Dio _dio;

  SyncService(this._dao) : _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8080', // O endereço do nosso servidor Go
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));

  /// Método que orquestra o envio dos dados offline para o Go
  Future<void> syncOutboxToServer() async {
    try {
      // 1. Busca os eventos pendentes no banco local (SQLite)
      final pendingEvents = await _dao.getPendingSyncEvents();
      
      if (pendingEvents.isEmpty) {
        print('✅ Nada para sincronizar.');
        return;
      }

      print('🚀 Iniciando sincronização de ${pendingEvents.length} eventos...');

      // 2. Mapeia os dados do banco para o formato JSON (DTO) que o Go espera
      final List<Map<String, dynamic>> eventsJson = pendingEvents.map((e) => {
        'id': e.id,
        'table_name': e.targetTable,
        'operation': e.operation,
        'payload': e.payloadJson,
        'created_at': e.createdAt,
      }).toList();

      // 3. Faz o POST para a nossa API em Go
      final response = await _dio.post(
        '/api/v1/sync/orders',
        data: {'events': eventsJson},
      );

      // 4. Se o Go responder 200 OK, apagamos os eventos locais
      if (response.statusCode == 200) {
        // O Go nos devolve a lista de IDs salvos com sucesso
        final List<dynamic> syncedIdsDynamic = response.data['synced_ids'] ?? [];
        final List<String> syncedIds = syncedIdsDynamic.map((e) => e.toString()).toList();

        if (syncedIds.isNotEmpty) {
          await _dao.removeSyncedEvents(syncedIds);
          print('✅ Sincronização concluída com sucesso! ${syncedIds.length} eventos salvos.');
        }
      }
    } on DioException catch (e) {
      print('❌ Erro de rede ao sincronizar: ${e.message}');
      // A beleza do offline-first: se der erro, não fazemos nada. 
      // Os dados continuam seguros no SQLite para a próxima tentativa.
    } catch (e) {
      print('❌ Erro desconhecido: $e');
    }
  }
}