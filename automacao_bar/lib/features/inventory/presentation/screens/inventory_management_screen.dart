import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/core/database/database_provider.dart';
import 'package:automacao_bar/core/database/app_database.dart';
import 'package:automacao_bar/core/database/daos/inventory_dao.dart';
import 'package:automacao_bar/core/utils/pdf_helper.dart';
import 'package:automacao_bar/core/utils/pdf_reports.dart';

class InventoryManagementScreen extends ConsumerStatefulWidget {
  const InventoryManagementScreen({super.key});

  @override
  ConsumerState<InventoryManagementScreen> createState() => _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends ConsumerState<InventoryManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _exportPdfReport() async {
    try {
      final pb = ref.read(allProductBalancesProvider).value ?? [];
      final stockItems = ref.read(allStockItemsProvider).value ?? [];

      final bytes = await PdfReports.generateInventoryReport(
        productBalances: pb,
        stockItems: stockItems,
      );

      await exportAndDownloadPdf(bytes, 'relatorio_estoque_${DateTime.now().millisecondsSinceEpoch}.pdf');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Relatório PDF exportado com sucesso!'),
            backgroundColor: AppColors.neonGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao exportar PDF: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final balancesAsync = ref.watch(allProductBalancesProvider);
    final stockItemsAsync = ref.watch(allStockItemsProvider);
    final movementsAsync = ref.watch(recentMovementsProvider);
    final productsAsync = ref.watch(watchAllProductsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: AppColors.surface,
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: IconButton(
                  icon: const Icon(Icons.picture_as_pdf, color: AppColors.electricBlue),
                  tooltip: 'Exportar PDF',
                  onPressed: _exportPdfReport,
                ),
              )
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(start: 24, bottom: 52),
              title: Text(
                'Estoques & Insumos',
                style: GoogleFonts.shareTechMono(
                  color: AppColors.textMain,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.neonGreen,
              labelColor: AppColors.neonGreen,
              unselectedLabelColor: AppColors.textMuted,
              tabs: const [
                Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Produtos'),
                Tab(icon: Icon(Icons.shopping_bag_outlined), text: 'Insumos / Receitas'),
                Tab(icon: Icon(Icons.history), text: 'Histórico & Perdas'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildProductsTab(balancesAsync),
            _buildStockItemsTab(stockItemsAsync),
            _buildHistoryTab(movementsAsync, productsAsync),
          ],
        ),
      ),
    );
  }

  // === TAB 1: PRODUCT STOCK ===
  Widget _buildProductsTab(AsyncValue<List<ProductBalance>> balancesAsync) {
    return balancesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.neonGreen)),
      error: (err, _) => Center(child: Text('Erro: $err', style: const TextStyle(color: AppColors.danger))),
      data: (balances) {
        if (balances.isEmpty) {
          return const Center(
            child: Text('Nenhum produto cadastrado no estoque.', style: TextStyle(color: AppColors.textMuted)),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: balances.length,
          separatorBuilder: (context, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final pb = balances[index];
            final isLow = pb.isLowStock;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isLow
                      ? AppColors.danger.withValues(alpha: 0.3)
                      : AppColors.surfaceLight,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              pb.product.name,
                              style: const TextStyle(
                                color: AppColors.textMain,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            if (isLow) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.danger.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'CRÍTICO',
                                  style: TextStyle(
                                    color: AppColors.danger,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (pb.categoryName != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            pb.categoryName!,
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        pb.balance.toStringAsFixed(1),
                        style: GoogleFonts.robotoMono(
                          color: isLow ? AppColors.danger : AppColors.neonGreen,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mínimo: ${pb.product.minStock.toStringAsFixed(0)}',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // === TAB 2: STOCK ITEMS (RAW INGREDIENTS) ===
  Widget _buildStockItemsTab(AsyncValue<List<StockItem>> stockItemsAsync) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 16.0),
          child: SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.neonGreen,
                side: const BorderSide(color: AppColors.neonGreen, width: 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: Text('CADASTRAR NOVO INSUMO', style: GoogleFonts.shareTechMono(fontWeight: FontWeight.bold)),
              onPressed: _showAddStockItemDialog,
            ),
          ),
        ),
        Expanded(
          child: stockItemsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.neonGreen)),
            error: (err, _) => Center(child: Text('Erro: $err', style: const TextStyle(color: AppColors.danger))),
            data: (items) {
              if (items.isEmpty) {
                return const Center(
                  child: Text('Nenhum insumo / matéria-prima cadastrada.', style: TextStyle(color: AppColors.textMuted)),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: items.length,
                separatorBuilder: (context, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final qty = item.quantity;
                  final min = item.alertMinQty;
                  
                  // Alert logic
                  Color statusColor;
                  String statusText;
                  if (qty < min) {
                    statusColor = AppColors.neonRed;
                    statusText = 'CRÍTICO';
                  } else if (qty < min * 1.5) {
                    statusColor = AppColors.orange;
                    statusText = 'ATENÇÃO';
                  } else {
                    statusColor = AppColors.neonGreen;
                    statusText = 'ESTÁVEL';
                  }

                  return InkWell(
                    onTap: () => _showStockItemDetailsSheet(item),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        color: AppColors.textMain,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        statusText,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Custo: R\$ ${item.costPrice.toStringAsFixed(2)} / ${item.unit}${item.unitWeight != null ? " (${item.unitWeight!.toStringAsFixed(0)}g/un)" : ""}',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${qty.toStringAsFixed(1)} ${item.unit}',
                                style: GoogleFonts.robotoMono(
                                  color: statusColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Mínimo: ${min.toStringAsFixed(1)}',
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // === TAB 3: HISTORY & WASTES ===
  Widget _buildHistoryTab(
    AsyncValue<List<InventoryMovement>> movementsAsync,
    AsyncValue<List<Product>> productsAsync,
  ) {
    final wastesAsync = ref.watch(allWasteRecordsProvider);
    final stockItemsAsync = ref.watch(allStockItemsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PERDAS & DESPERDÍCIOS DE INSUMOS',
            style: GoogleFonts.shareTechMono(
              color: AppColors.textMain,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          wastesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.neonGreen)),
            error: (err, _) => Text('Erro: $err', style: const TextStyle(color: AppColors.danger)),
            data: (wastes) {
              if (wastes.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
                  child: const Center(child: Text('Nenhum desperdício registrado.', style: TextStyle(color: AppColors.textMuted))),
                );
              }

              return stockItemsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.neonGreen)),
                error: (err, _) => Container(),
                data: (items) {
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: wastes.length,
                    separatorBuilder: (context, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final w = wastes[index];
                      final item = items.firstWhere(
                        (i) => i.id == w.stockItemId,
                        orElse: () => StockItem(id: '', name: 'Insumo Excluído', unit: '', quantity: 0, costPrice: 0, alertMinQty: 0, updatedAt: 0),
                      );
                      final date = DateTime.fromMillisecondsSinceEpoch(w.recordedAt);
                      final formattedDate = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.neonRed.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${w.quantity} ${item.unit} de ${item.name}',
                                  style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Motivo: ${w.reason} • $formattedDate',
                                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                                ),
                              ],
                            ),
                            Text(
                              '- R\$ ${w.costLost.toStringAsFixed(2)}',
                              style: GoogleFonts.robotoMono(color: AppColors.neonRed, fontWeight: FontWeight.bold, fontSize: 13),
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
          const SizedBox(height: 32),
          Text(
            'HISTÓRICO DE PRODUTOS VENDIDOS',
            style: GoogleFonts.shareTechMono(
              color: AppColors.textMain,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          movementsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.neonGreen)),
            error: (err, _) => Text('Erro: $err', style: const TextStyle(color: AppColors.danger)),
            data: (movements) {
              if (movements.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
                  child: const Center(child: Text('Nenhuma movimentação no histórico.', style: TextStyle(color: AppColors.textMuted))),
                );
              }

              return productsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Container(),
                data: (products) {
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: movements.length,
                    separatorBuilder: (context, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final mv = movements[index];
                      final product = products.firstWhere(
                        (p) => p.id == mv.productId,
                        orElse: () => Product(id: '', categoryId: '', name: 'Produto Desconhecido', price: 0, minStock: 0, isActive: false, updatedAt: 0),
                      );
                      final isAddition = mv.delta > 0;
                      final date = DateTime.fromMillisecondsSinceEpoch(mv.createdAt);
                      final formattedDate = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product.name, style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 4),
                                Text('Motivo: ${mv.reason} • $formattedDate', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                              ],
                            ),
                            Text(
                              '${isAddition ? '+' : ''}${mv.delta.toStringAsFixed(1)}',
                              style: GoogleFonts.robotoMono(color: isAddition ? AppColors.neonGreen : AppColors.danger, fontWeight: FontWeight.bold),
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
        ],
      ),
    );
  }

  // === DIALOG: REGISTER NEW STOCK ITEM ===
  void _showAddStockItemDialog() {
    final nameController = TextEditingController();
    final qtyController = TextEditingController();
    final costController = TextEditingController();
    final minController = TextEditingController(text: '5.0');
    final weightController = TextEditingController();
    String selectedUnit = 'un';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: Text(
                'NOVO INSUMO',
                style: GoogleFonts.shareTechMono(color: AppColors.textMain, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: AppColors.textMain),
                      decoration: const InputDecoration(
                        labelText: 'Nome do Insumo (ex: Tomate, Queijo)',
                        labelStyle: TextStyle(color: AppColors.textMuted),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceLight)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neonGreen)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedUnit,
                      dropdownColor: AppColors.surface,
                      style: const TextStyle(color: AppColors.textMain),
                      decoration: const InputDecoration(
                        labelText: 'Unidade de Medida',
                        labelStyle: TextStyle(color: AppColors.textMuted),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'un', child: Text('Unidade (un)')),
                        DropdownMenuItem(value: 'kg', child: Text('Kilograma (kg)')),
                        DropdownMenuItem(value: 'g', child: Text('Grama (g)')),
                        DropdownMenuItem(value: 'l', child: Text('Litro (l)')),
                        DropdownMenuItem(value: 'ml', child: Text('Mililitro (ml)')),
                      ],
                      onChanged: (val) => setState(() => selectedUnit = val ?? 'un'),
                    ),
                    const SizedBox(height: 12),
                    if (selectedUnit == 'un') ...[
                      TextField(
                        controller: weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: AppColors.textMain),
                        decoration: const InputDecoration(
                          labelText: 'Peso Unitário em Gramas (Opcional)',
                          labelStyle: TextStyle(color: AppColors.textMuted),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceLight)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neonGreen)),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextField(
                      controller: qtyController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: AppColors.textMain),
                      decoration: const InputDecoration(
                        labelText: 'Quantidade Inicial em Estoque',
                        labelStyle: TextStyle(color: AppColors.textMuted),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceLight)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neonGreen)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: costController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: AppColors.textMain),
                      decoration: const InputDecoration(
                        labelText: 'Preço de Custo (R\$ por un/kg/l)',
                        labelStyle: TextStyle(color: AppColors.textMuted),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceLight)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neonGreen)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: minController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: AppColors.textMain),
                      decoration: const InputDecoration(
                        labelText: 'Quantidade Mínima de Alerta',
                        labelStyle: TextStyle(color: AppColors.textMuted),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceLight)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neonGreen)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('CANCELAR', style: TextStyle(color: AppColors.textMuted)),
                ),
                TextButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty || qtyController.text.isEmpty || costController.text.isEmpty) {
                      return;
                    }
                    
                    final name = nameController.text.trim();
                    final qty = double.tryParse(qtyController.text.replaceAll(',', '.')) ?? 0.0;
                    final cost = double.tryParse(costController.text.replaceAll(',', '.')) ?? 0.0;
                    final min = double.tryParse(minController.text.replaceAll(',', '.')) ?? 5.0;
                    final weight = weightController.text.isNotEmpty 
                        ? double.tryParse(weightController.text.replaceAll(',', '.'))
                        : null;

                    final item = StockItem(
                      id: const Uuid().v7(),
                      name: name,
                      unit: selectedUnit,
                      quantity: qty,
                      unitWeight: weight,
                      costPrice: cost,
                      alertMinQty: min,
                      updatedAt: DateTime.now().millisecondsSinceEpoch,
                    );

                    final dao = ref.read(inventoryDaoProvider);
                    await dao.insertStockItem(item);
                    
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('SALVAR', style: TextStyle(color: AppColors.neonGreen)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // === DETAILS BOTTOM SHEET ===
  void _showStockItemDetailsSheet(StockItem item) {
    final entryController = TextEditingController();
    final wasteController = TextEditingController();
    final reasonController = TextEditingController(text: 'vencido');
    final costController = TextEditingController(text: item.costPrice.toStringAsFixed(2));
    bool updateCostPrice = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceAlt,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final historyAsync = ref.watch(stockPriceHistoryProvider(item.id));
            final wastesAsync = ref.watch(allWasteRecordsProvider);

            return AnimatedPadding(
              duration: const Duration(milliseconds: 100),
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.name.toUpperCase(),
                            style: GoogleFonts.shareTechMono(color: AppColors.textMain, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${item.quantity.toStringAsFixed(1)} ${item.unit}',
                            style: GoogleFonts.robotoMono(color: AppColors.neonGreen, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Preço de Custo atual: R\$ ${item.costPrice.toStringAsFixed(2)} / ${item.unit}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 24),
                      
                      // Section: Adicionar Entrada
                      Text(
                        'LANÇAR ENTRADA DE COMPRA',
                        style: GoogleFonts.shareTechMono(color: AppColors.electricBlue, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: entryController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(color: AppColors.textMain),
                              decoration: InputDecoration(
                                labelText: 'Quantidade (${item.unit})',
                                labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceLight)),
                                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neonGreen)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.electricBlue,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () async {
                              final qty = double.tryParse(entryController.text.replaceAll(',', '.')) ?? 0.0;
                              if (qty <= 0) return;

                              final dao = ref.read(inventoryDaoProvider);
                              await dao.addStockQuantity(item.id, qty);
                              if (updateCostPrice) {
                                final nCost = double.tryParse(costController.text.replaceAll(',', '.')) ?? item.costPrice;
                                await dao.updateStockItemCost(item.id, nCost);
                              }
                              
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                            child: Text('SALVAR', style: GoogleFonts.shareTechMono(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Checkbox(
                            value: updateCostPrice,
                            activeColor: AppColors.neonGreen,
                            onChanged: (val) => setSheetState(() => updateCostPrice = val ?? false),
                          ),
                          const Text('Atualizar preço de custo nesta compra?', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                      if (updateCostPrice) ...[
                        TextField(
                          controller: costController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(color: AppColors.textMain),
                          decoration: const InputDecoration(
                            labelText: 'Novo Preço de Custo (R\$)',
                            labelStyle: TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      const Divider(color: AppColors.surfaceLight),
                      const SizedBox(height: 16),

                      // Section: Registrar Perda / Desperdício
                      Text(
                        'REGISTRAR PERDA / DESPERDÍCIO',
                        style: GoogleFonts.shareTechMono(color: AppColors.neonRed, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: wasteController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(color: AppColors.textMain),
                              decoration: InputDecoration(
                                labelText: 'Quantidade Perdida (${item.unit})',
                                labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: reasonController.text,
                              dropdownColor: AppColors.surface,
                              style: const TextStyle(color: AppColors.textMain),
                              decoration: const InputDecoration(labelText: 'Motivo'),
                              items: const [
                                DropdownMenuItem(value: 'vencido', child: Text('Vencido')),
                                DropdownMenuItem(value: 'estragado', child: Text('Estragado')),
                                DropdownMenuItem(value: 'dano', child: Text('Quebra / Dano')),
                                DropdownMenuItem(value: 'outro', child: Text('Outro')),
                              ],
                              onChanged: (val) => reasonController.text = val ?? 'vencido',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.neonRed,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () async {
                            final qty = double.tryParse(wasteController.text.replaceAll(',', '.')) ?? 0.0;
                            if (qty <= 0) return;

                            final dao = ref.read(inventoryDaoProvider);
                            await dao.registerWaste(
                              stockItemId: item.id,
                              quantity: qty,
                              reason: reasonController.text,
                            );

                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                          child: Text('DEDUZIR E REGISTRAR PERDA', style: GoogleFonts.shareTechMono(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      const Divider(color: AppColors.surfaceLight),
                      const SizedBox(height: 16),

                      // Section: Histórico de Preços
                      Text(
                        'EVOLUÇÃO DO PREÇO DE CUSTO',
                        style: GoogleFonts.shareTechMono(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      historyAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, _) => Text('Erro ao carregar preços: $err'),
                        data: (prices) {
                          if (prices.isEmpty) {
                            return const Text('Nenhum histórico disponível.', style: TextStyle(color: AppColors.textMuted, fontSize: 12));
                          }
                          return Column(
                            children: prices.map((p) {
                              final date = DateTime.fromMillisecondsSinceEpoch(p.recordedAt);
                              final formattedDate = '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(formattedDate, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                    Text('R\$ ${p.costPrice.toStringAsFixed(2)}', style: GoogleFonts.robotoMono(color: AppColors.neonGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Section: Perdas Históricas deste item
                      Text(
                        'PERDAS REGISTRADAS DESTE INSUMO',
                        style: GoogleFonts.shareTechMono(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      wastesAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, _) => Text('Erro: $err'),
                        data: (wastes) {
                          final itemWastes = wastes.where((w) => w.stockItemId == item.id).toList();
                          if (itemWastes.isEmpty) {
                            return const Text('Nenhum desperdício registrado para este insumo.', style: TextStyle(color: AppColors.textMuted, fontSize: 12));
                          }
                          return Column(
                            children: itemWastes.map((w) {
                              final date = DateTime.fromMillisecondsSinceEpoch(w.recordedAt);
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${w.quantity} ${item.unit} (${w.reason}) • ${date.day}/${date.month}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                    Text('- R\$ ${w.costLost.toStringAsFixed(2)}', style: GoogleFonts.robotoMono(color: AppColors.neonRed, fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
