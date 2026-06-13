import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/features/inventory/application/inventory_provider.dart';
import 'package:automacao_bar/features/management/application/ingredients_provider.dart';

class InventoryManagementScreen extends ConsumerStatefulWidget {
  const InventoryManagementScreen({super.key});

  @override
  ConsumerState<InventoryManagementScreen> createState() => _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends ConsumerState<InventoryManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Invoice registry form states
  String? _selectedSupplierId;
  final List<InventoryLog> _draftItems = [];

  // Temporary controllers for single item additions
  String? _selectedIngredientId;
  final _qtyController = TextEditingController();
  final _costController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _qtyController.dispose();
    _costController.dispose();
    super.dispose();
  }

  void _addItem() {
    if (_selectedIngredientId == null || _qtyController.text.isEmpty || _costController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha os dados do ingrediente, quantidade e custo!'), backgroundColor: AppColors.danger),
      );
      return;
    }

    final qty = double.tryParse(_qtyController.text.replaceAll(',', '.')) ?? 0.0;
    final cost = double.tryParse(_costController.text.replaceAll(',', '.')) ?? 0.0;

    if (qty <= 0 || cost <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantidade e Custo devem ser maiores que zero!'), backgroundColor: AppColors.danger),
      );
      return;
    }

    // Prevent duplicate draft items
    if (_draftItems.any((item) => item.ingredientId == _selectedIngredientId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este ingrediente já está na lista!'), backgroundColor: AppColors.danger),
      );
      return;
    }

    setState(() {
      _draftItems.add(InventoryLog(
        id: 'draft_${DateTime.now().millisecondsSinceEpoch}',
        ingredientId: _selectedIngredientId!,
        quantityAdded: qty,
        costPerUnit: cost,
      ));
      _selectedIngredientId = null;
      _qtyController.clear();
      _costController.clear();
    });
  }

  void _submitPurchase() {
    if (_selectedSupplierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o Fornecedor!'), backgroundColor: AppColors.danger),
      );
      return;
    }

    if (_draftItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos um item à nota fiscal!'), backgroundColor: AppColors.danger),
      );
      return;
    }

    ref.read(inventoryProvider.notifier).addPurchase(_selectedSupplierId!, _draftItems);

    setState(() {
      _draftItems.clear();
      _selectedSupplierId = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compra registrada e estoque incrementado!'), backgroundColor: AppColors.neonGreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ingredients = ref.watch(inventoryProvider);
    final suppliers = ref.watch(suppliersProvider);
    final purchases = ref.watch(purchasesProvider);
    final burgerCmv = ref.watch(cmvProvider('p1'));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gestão de Estoques & Compras', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.neonGreen,
          labelColor: AppColors.neonGreen,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Níveis de Estoque'),
            Tab(icon: Icon(Icons.post_add), text: 'Nova Entrada (Fatura)'),
            Tab(icon: Icon(Icons.history_edu), text: 'Histórico de Compras'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildStockLevelsTab(ingredients, burgerCmv),
            _buildNewPurchaseTab(ingredients, suppliers),
            _buildPurchaseHistoryTab(purchases, suppliers, ingredients),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: STOCK LEVELS & CMV
  // ==========================================
  Widget _buildStockLevelsTab(List<Ingredient> ingredients, double burgerCmv) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BI card for CMV
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.15)),
              boxShadow: [
                BoxShadow(color: AppColors.neonGreen.withValues(alpha: 0.03), blurRadius: 10, spreadRadius: 2),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CUSTO DINÂMICO (CMV)',
                      style: TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Hambúrguer Clássico',
                      style: TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Baseado na última compra de insumos',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'R\$ ${burgerCmv.toStringAsFixed(2)}',
                      style: const TextStyle(color: AppColors.neonGreen, fontSize: 24, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Preço Venda: R\$ 29.90',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Insumos e Custos Unitários',
            style: TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Controle de custos médios e margens operacionais dos ingredientes brutos.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 16),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ingredients.length,
            separatorBuilder: (context, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final ing = ingredients[index];
              final isLow = ing.inStock <= ing.minStock;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isLow ? AppColors.danger.withValues(alpha: 0.2) : AppColors.surfaceLight),
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
                              Text(ing.name, style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 15)),
                              if (isLow) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                                  child: const Text('BAIXO', style: TextStyle(color: AppColors.danger, fontSize: 9, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text('Custo Médio: R\$ ${ing.averageCost.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                              const SizedBox(width: 12),
                              Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppColors.textMuted, shape: BoxShape.circle)),
                              const SizedBox(width: 12),
                              Text('Última Compra: R\$ ${ing.lastPurchaseCost.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${ing.inStock.toStringAsFixed(1)} ${ing.unitMeasure}',
                          style: TextStyle(color: isLow ? AppColors.danger : AppColors.neonGreen, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mínimo: ${ing.minStock.toStringAsFixed(0)} ${ing.unitMeasure}',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: REGISTER NEW STOCK PURCHASE
  // ==========================================
  Widget _buildNewPurchaseTab(List<Ingredient> ingredients, List<Supplier> suppliers) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lançamento de Compra (Fatura/Nota)',
            style: TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Atualize o estoque do salão e recalcule custos unitários registrando a nota de compras.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Fornecedor Selection
          DropdownButtonFormField<String>(
            value: _selectedSupplierId,
            dropdownColor: AppColors.surface,
            style: const TextStyle(color: AppColors.textMain),
            decoration: const InputDecoration(
              labelText: 'Fornecedor Parceiro',
              labelStyle: TextStyle(color: AppColors.textMuted),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceLight)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neonGreen)),
            ),
            items: suppliers.map((s) {
              return DropdownMenuItem(value: s.id, child: Text(s.name));
            }).toList(),
            onChanged: (val) => setState(() => _selectedSupplierId = val),
          ),
          const SizedBox(height: 24),

          // Inner section: Add items to draft list
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Adicionar Item da Nota', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: _selectedIngredientId,
                        dropdownColor: AppColors.surface,
                        style: const TextStyle(color: AppColors.textMain, fontSize: 13),
                        decoration: const InputDecoration(
                          labelText: 'Ingrediente',
                          labelStyle: TextStyle(color: AppColors.textMuted, fontSize: 12),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceLight)),
                        ),
                        items: ingredients.map((ing) {
                          return DropdownMenuItem(value: ing.id, child: Text(ing.name));
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedIngredientId = val),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _qtyController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.textMain, fontSize: 13),
                        decoration: const InputDecoration(
                          labelText: 'Qtd.',
                          labelStyle: TextStyle(color: AppColors.textMuted, fontSize: 12),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceLight)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _costController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.textMain, fontSize: 13),
                        decoration: const InputDecoration(
                          labelText: 'Custo Un. (R\$)',
                          labelStyle: TextStyle(color: AppColors.textMuted, fontSize: 12),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceLight)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.surfaceLight, foregroundColor: AppColors.neonGreen),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Inserir Item', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: _addItem,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Draft items list table
          if (_draftItems.isNotEmpty) ...[
            const Text('Itens Selecionados na Nota', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _draftItems.length,
              separatorBuilder: (context, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = _draftItems[index];
                final ing = ingredients.firstWhere((i) => i.id == item.ingredientId);
                final totalCost = item.quantityAdded * item.costPerUnit;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ing.name, style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(
                            '${item.quantityAdded.toStringAsFixed(1)} ${ing.unitMeasure} x R\$ ${item.costPerUnit.toStringAsFixed(2)}',
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text('R\$ ${totalCost.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete, color: AppColors.danger, size: 18),
                            onPressed: () => setState(() => _draftItems.removeAt(index)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonGreen, foregroundColor: Colors.black),
                onPressed: _submitPurchase,
                child: const Text('CONFIRMAR ENTRADA DE NOTA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ] else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: Text('Nenhum insumo adicionado na lista.', style: TextStyle(color: AppColors.textMuted))),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: PURCHASE HISTORY LOG
  // ==========================================
  Widget _buildPurchaseHistoryTab(List<PurchaseOrder> purchases, List<Supplier> suppliers, List<Ingredient> ingredients) {
    if (purchases.isEmpty) {
      return const Center(child: Text('Nenhuma nota fiscal registrada no sistema.', style: TextStyle(color: AppColors.textMuted)));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: purchases.length,
      separatorBuilder: (context, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final order = purchases[index];
        final supplier = suppliers.firstWhere((s) => s.id == order.supplierId, orElse: () => const Supplier(id: '', name: 'Fornecedor Desconhecido', contact: ''));

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.surfaceLight),
          ),
          child: ExpansionTile(
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            title: Text(supplier.name, style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Text(
              'Nota ID: ${order.id} • ${order.date.day.toString().padLeft(2, '0')}/${order.date.month.toString().padLeft(2, '0')}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
            trailing: Text(
              'R\$ ${order.totalCost.toStringAsFixed(2)}',
              style: const TextStyle(color: AppColors.neonGreen, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            children: order.items.map((item) {
              final ing = ingredients.firstWhere((i) => i.id == item.ingredientId, orElse: () => const Ingredient(id: '', name: 'Desconhecido', unitMeasure: '', inStock: 0));
              final total = item.quantityAdded * item.costPerUnit;

              return ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                title: Text(ing.name, style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
                subtitle: Text('${item.quantityAdded.toStringAsFixed(1)} ${ing.unitMeasure} x R\$ ${item.costPerUnit.toStringAsFixed(2)}'),
                trailing: Text('R\$ ${total.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.textMain)),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
