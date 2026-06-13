import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/database/app_database.dart'; // Para acessar os tipos gerados

class OrderDetailsScreen extends ConsumerWidget {
  final String orderId;
  final int tableNumber;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
    required this.tableNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. O Riverpod "assiste" o banco de dados magicamente
    final itemsAsyncValue = ref.watch(orderItemsProvider(orderId));

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Fundo Dark Premium
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Mesa $tableNumber',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          // 🚀 BOTÃO DE SINCRONIZAÇÃO MANUAL
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.greenAccent),
            tooltip: 'Sincronizar Pedidos',
            onPressed: () async {
              // Quando clicado, lê o provider de rede e dispara a função
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sincronizando...'), duration: Duration(seconds: 1)),
              );
              
              await ref.read(syncServiceProvider).syncOutboxToServer();
              
              // No futuro, não precisaremos deste snackbar, a interface atualizará sozinha
            },
          ),

          // Status da Mesa (Em Preparo)
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange),
            ),
            child: const Center(
              child: Text(
                'Em Preparo',
                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
      body: itemsAsyncValue.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'Comanda vazia.\nAdicione o primeiro item.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 18),
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildItemCard(context, item);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.greenAccent)),
        error: (err, stack) => Center(child: Text('Erro: $err', style: const TextStyle(color: Colors.red))),
      ),
      // Botão Flutuante Gigante para adicionar itens rapidamente
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        color: const Color(0xFF1E1E1E),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.greenAccent, // Verde Neon Suave
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            // Ação de simular a adição de um Chopp
            final dao = ref.read(ordersDaoProvider);
            dao.addItemToOrder(orderId, 'prod_chopp_lager', 1, 'Bem gelado');
          },
          child: const Text(
            'Adicionar Item',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // O Design System do Card de Item
  Widget _buildItemCard(BuildContext context, OrderItem item) {
    // Avalia o status de sincronização para mostrar o ícone correto
    final isSynced = item.syncStatus == 'SYNCED';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Cinza Escuro
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Produto ID: ${item.productId.substring(0, 8)}', // Temporário, depois cruzaremos com catálogo
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (item.notes != null && item.notes!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      item.notes!,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                const SizedBox(height: 8),
                // Ícone de Offline/Online Crucial
                Row(
                  children: [
                    Icon(
                      isSynced ? Icons.cloud_done : Icons.cloud_upload,
                      color: isSynced ? Colors.green : Colors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isSynced ? 'Sincronizado' : 'Aguardando rede...',
                      style: TextStyle(color: isSynced ? Colors.green : Colors.grey, fontSize: 12),
                    ),
                  ],
                )
              ],
            ),
          ),
          // Botoes grandes de UX (Touch Targets)
          Row(
            children: [
              IconButton(
                onPressed: () {}, // Lógica futura de diminuir
                icon: const Icon(Icons.remove_circle_outline, color: Colors.white, size: 32),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  '${item.quantity}',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: () {}, // Lógica futura de aumentar
                icon: const Icon(Icons.add_circle, color: Colors.greenAccent, size: 32),
              ),
            ],
          )
        ],
      ),
    );
  }
}