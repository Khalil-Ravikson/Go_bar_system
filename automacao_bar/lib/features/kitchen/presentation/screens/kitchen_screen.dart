import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:drift/drift.dart' as drift;

import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/core/database/database_provider.dart';
import 'package:automacao_bar/core/database/app_database.dart';
import 'package:automacao_bar/shared/presentation/components/neon_button.dart';
import 'package:automacao_bar/features/auth/application/auth_provider.dart';

class KitchenScreen extends ConsumerStatefulWidget {
  const KitchenScreen({super.key});

  @override
  ConsumerState<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends ConsumerState<KitchenScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Rebuild every 10 seconds to update wait timers
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _markTicketAsReady(String orderId, List<String> itemIds, String tableNumber) async {
    final db = ref.read(databaseProvider);
    final now = DateTime.now().millisecondsSinceEpoch;

    try {
      await db.transaction(() async {
        for (final itemId in itemIds) {
          await (db.update(db.orderItems)..where((oi) => oi.id.equals(itemId))).write(
            OrderItemsCompanion(
              status: const drift.Value('pronto'),
              updatedAt: drift.Value(now),
            ),
          );
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Mesa $tableNumber marcada como pronta!',
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppColors.neonGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar KDS: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
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
    final ticketsAsync = ref.watch(kdsTicketsProvider);
    final recipesAsync = ref.watch(allRecipesProvider);
    final stockItemsAsync = ref.watch(allStockItemsProvider);
    final session = ref.watch(authProvider);

    // Guard (Double protection)
    if (session == null || (session.role != UserRole.chef && session.role != UserRole.admin)) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, color: AppColors.danger, size: 64),
              const SizedBox(height: 16),
              Text(
                'ACESSO NEGADO',
                style: GoogleFonts.shareTechMono(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Área restrita aos funcionários da Cozinha / Administradores.', style: TextStyle(color: AppColors.textMuted)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'PAINEL DE PRODUÇÃO (KDS)',
          style: GoogleFonts.shareTechMono(color: AppColors.textMain, fontWeight: FontWeight.bold),
        ),
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
                  Text(
                    'Chef: ${session.name}',
                    style: const TextStyle(
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
      body: ticketsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.neonGreen)),
        error: (err, _) => Center(child: Text('Erro: $err', style: const TextStyle(color: AppColors.danger))),
        data: (tickets) {
          if (tickets.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: AppColors.neonGreen,
                    size: 64,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Tudo Pronto!',
                    style: TextStyle(
                      color: AppColors.textMain,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Nenhum pedido pendente de preparação.',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          final recipes = recipesAsync.value ?? [];
          final stockItems = stockItemsAsync.value ?? [];

          return LayoutBuilder(
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
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  final ticket = tickets[index];
                  final orderId = ticket['id'] as String;
                  final tableNum = ticket['tableNumber'] as String;
                  final openedAt = ticket['openedAt'] as int;
                  final items = ticket['items'] as List<Map<String, dynamic>>;

                  final elapsedMs = DateTime.now().millisecondsSinceEpoch - openedAt;
                  final waitTime = (elapsedMs / 60000).floor();

                  // Check for low stock ingredient warnings in this ticket's items
                  final List<String> lowStockAlerts = [];
                  for (final s in stockItems) {
                    if (s.quantity < s.alertMinQty) {
                      // Check if this stock item is used in any product recipes
                      final isUsed = recipes.any((r) => r.stockItemId == s.id);
                      if (isUsed && !lowStockAlerts.contains(s.name)) {
                        lowStockAlerts.add(s.name);
                      }
                    }
                  }

                  final itemIds = items.map((i) => i['itemId'] as String).toList();

                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: lowStockAlerts.isNotEmpty
                            ? AppColors.neonRed.withValues(alpha: 0.4)
                            : AppColors.surfaceLight,
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
                        
                        // Low Stock Warnings Box
                        if (lowStockAlerts.isNotEmpty)
                          Container(
                            color: AppColors.neonRed.withValues(alpha: 0.1),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.warning, color: AppColors.neonRed, size: 14),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'BAIXO ESTOQUE: ${lowStockAlerts.join(", ")}',
                                    style: const TextStyle(color: AppColors.neonRed, fontSize: 10, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

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
                              final notes = item['notes'] as String?;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
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
                                  ),
                                  if (notes != null && notes.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 36.0),
                                      child: Text(
                                        'Obs: $notes',
                                        style: const TextStyle(
                                          color: AppColors.magentaCyber,
                                          fontSize: 11,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ],
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
                            onTap: () => _markTicketAsReady(orderId, itemIds, tableNum),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
