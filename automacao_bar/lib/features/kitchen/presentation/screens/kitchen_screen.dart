import 'package:flutter/material.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/shared/presentation/components/neon_button.dart';

class KitchenScreen extends StatefulWidget {
  const KitchenScreen({super.key});

  @override
  State<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends State<KitchenScreen> {
  // Mock active kitchen tickets
  final List<Map<String, dynamic>> _tickets = [
    {
      'id': 't1',
      'tableNumber': '04',
      'waitMinutes': 12,
      'items': [
        {'name': 'Chopp Brahma 300ml', 'quantity': 3},
        {'name': 'Gin Tônica Tropical', 'quantity': 1},
      ]
    },
    {
      'id': 't2',
      'tableNumber': '07',
      'waitMinutes': 5,
      'items': [
        {'name': 'Heineken Long Neck', 'quantity': 2},
        {'name': 'Caipirinha de Limão', 'quantity': 1},
      ]
    },
    {
      'id': 't3',
      'tableNumber': '12',
      'waitMinutes': 22,
      'items': [
        {'name': 'Gin Tônica Tropical', 'quantity': 1},
        {'name': 'Porção de Batatas Fritas', 'quantity': 1},
      ]
    },
    {
      'id': 't4',
      'tableNumber': '02',
      'waitMinutes': 8,
      'items': [
        {'name': 'Chopp Brahma 300ml', 'quantity': 2},
      ]
    },
  ];

  void _markAsReady(String ticketId, String tableNumber) {
    setState(() {
      _tickets.removeWhere((ticket) => ticket['id'] == ticketId);
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Mesa $tableNumber marcada como pronta para entrega!',
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: AppColors.neonGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Color _getWaitColor(int minutes) {
    if (minutes > 20) {
      return AppColors.danger;
    } else if (minutes > 10) {
      return AppColors.warning;
    }
    return AppColors.neonGreen;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Painel da Cozinha (KDS)'),
        backgroundColor: AppColors.surface,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.neonGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Online',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _tickets.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: AppColors.neonGreen,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tudo Pronto!',
                    style: TextStyle(
                      color: AppColors.textMain,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Nenhum pedido pendente na cozinha.',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = 2;
                if (constraints.maxWidth > 1000) {
                  crossAxisCount = 4;
                } else if (constraints.maxWidth > 700) {
                  crossAxisCount = 3;
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(24),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.76,
                  ),
                  itemCount: _tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = _tickets[index];
                    final waitTime = ticket['waitMinutes'] as int;
                    final tableNum = ticket['tableNumber'] as String;
                    final items = ticket['items'] as List<Map<String, dynamic>>;

                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.surfaceLight,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Ticket Header
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Mesa $tableNum',
                                  style: const TextStyle(
                                    color: AppColors.textMain,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getWaitColor(waitTime).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _getWaitColor(waitTime),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '$waitTime min',
                                    style: TextStyle(
                                      color: _getWaitColor(waitTime),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(),
                          
                          // Items List
                          Expanded(
                            child: ListView.separated(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: items.length,
                              separatorBuilder: (context, idx) => const SizedBox(height: 12),
                              itemBuilder: (context, idx) {
                                final item = items[idx];
                                final name = item['name'] as String;
                                final qty = item['quantity'] as int;

                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceLight,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${qty}x',
                                        style: const TextStyle(
                                          color: AppColors.neonGreen,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        name,
                                        style: const TextStyle(
                                          color: AppColors.textMain,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          
                          const Divider(),
                          
                          // Ready Button
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: NeonButton(
                              text: 'MARCAR COMO PRONTO',
                              onTap: () => _markAsReady(ticket['id'] as String, tableNum),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
