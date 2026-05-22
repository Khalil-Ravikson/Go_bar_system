import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// 1. A nossa Máquina de Estados (Enum)
enum WebSocketStatus { online, offline, connecting }

// 2. Provider agora usa o Enum. O estado inicial é 'offline'
final connectionStatusProvider = StateProvider<WebSocketStatus>((ref) => WebSocketStatus.offline);

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  return WebSocketService(ref);
});

class WebSocketService {
  WebSocketChannel? channel;
  final Ref ref;
  bool _isDisposed = false;
  int _retryCount = 0; // Contador para o Exponential Backoff

  WebSocketService(this.ref);

  Future<void> connect() async {
    if (_isDisposed) return;

    // Muda a UI para Laranja (Sincronizando...)
    ref.read(connectionStatusProvider.notifier).state = WebSocketStatus.connecting;
    print('🌐 Tentando conectar ao WebSocket...');

    try {
      final uri = Uri.parse('ws://localhost:8080/ws');
      channel = WebSocketChannel.connect(uri);

      // O Pulo do Gato: Espera a conexão REALMENTE se estabelecer antes de ficar verde!
      await channel!.ready; 

      _retryCount = 0; // Reseta o contador após sucesso
      ref.read(connectionStatusProvider.notifier).state = WebSocketStatus.online;
      print('✅ Conectado ao WebSocket!');

      channel!.stream.listen(
        (message) {
          print('📩 Mensagem recebida: $message');
        },
        onError: (error) {
          print('❌ Erro no WebSocket: $error');
          _handleDisconnect();
        },
        onDone: () {
          print('⚠️ Conexão encerrada pelo servidor.');
          _handleDisconnect();
        },
      );
    } catch (e) {
      print('❌ Falha na conexão: $e');
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    ref.read(connectionStatusProvider.notifier).state = WebSocketStatus.offline;
    if (_isDisposed) return;

    // EXPONENTIAL BACKOFF: 2s, 4s, 8s, 16s, limitando ao máximo de 30 segundos.
    final delaySeconds = min(pow(2, _retryCount).toInt(), 30);
    _retryCount++;

    print('🔄 Tentando reconectar em $delaySeconds segundos...');
    Future.delayed(Duration(seconds: delaySeconds), () {
      connect();
    });
  }

  void dispose() {
    _isDisposed = true;
    channel?.sink.close();
  }
}