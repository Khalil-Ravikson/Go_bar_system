import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';

class CatalogManagementScreen extends ConsumerStatefulWidget {
  const CatalogManagementScreen({super.key});

  @override
  ConsumerState<CatalogManagementScreen> createState() => _CatalogManagementScreenState();
}

class _CatalogManagementScreenState extends ConsumerState<CatalogManagementScreen> {
  // Controladores para Categoria
  final _categoryNameController = TextEditingController();

  // Controladores para Produto
  final _productNameController = TextEditingController();
  final _productPriceController = TextEditingController();
  String? _selectedCategoryId;

  // Tenant ID fixo por enquanto (será dinâmico no futuro SaaS)
  final String _currentTenantId = 'tenant_123';

  @override
  void dispose() {
    _categoryNameController.dispose();
    _productNameController.dispose();
    _productPriceController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    final name = _categoryNameController.text.trim();
    if (name.isEmpty) return;

    final dao = ref.read(catalogDaoProvider);
    await dao.insertCategory(name, _currentTenantId);

    _categoryNameController.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Categoria "$name" salva com sucesso!')),
      );
    }
  }

  Future<void> _saveProduct() async {
    final name = _productNameController.text.trim();
    final priceText = _productPriceController.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (name.isEmpty || priceText.isEmpty || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos do produto.')),
      );
      return;
    }

    final priceInCents = int.parse(priceText);
    final dao = ref.read(catalogDaoProvider);

    await dao.insertProduct(
      tenantId: _currentTenantId,
      categoryId: _selectedCategoryId!,
      name: name,
      currentPrice: priceInCents,
    );

    _productNameController.clear();
    _productPriceController.clear();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produto "$name" salvo com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escutamos as categorias em tempo real para popular o Dropdown
    final categoriesAsyncValue = ref.watch(watchCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Cardápio'),
        backgroundColor: Colors.orange.shade800,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==========================================
            // SEÇÃO 1: NOVA CATEGORIA
            // ==========================================
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('1. Nova Categoria', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _categoryNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome da Categoria (ex: Bebidas)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _saveCategory,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50), // Correção aqui
                      ),
                      child: const Text('Salvar Categoria'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ==========================================
            // SEÇÃO 2: NOVO PRODUTO
            // ==========================================
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('2. Novo Produto', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    
                    // Dropdown Reativo
                    categoriesAsyncValue.when(
                      data: (categories) {
                        if (categories.isEmpty) {
                          return const Text('Cadastre uma categoria primeiro.', style: TextStyle(color: Colors.red));
                        }
                        
                        // Garante que o ID selecionado ainda existe na lista
                        if (_selectedCategoryId != null && !categories.any((c) => c.id == _selectedCategoryId)) {
                           WidgetsBinding.instance.addPostFrameCallback((_) {
                             if (mounted) setState(() => _selectedCategoryId = null);
                           });
                        }

                        return DropdownButtonFormField<String>(
                          initialValue: _selectedCategoryId,
                          hint: const Text('Selecione a Categoria'),
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                          items: categories.map((category) {
                            return DropdownMenuItem(
                              value: category.id,
                              child: Text(category.name),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => _selectedCategoryId = value),
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (e, st) => Text('Erro: $e'),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _productNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do Produto (ex: Coca-Cola Lata)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _productPriceController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Preço (em centavos, ex: 500 = R\$ 5,00)',
                        border: OutlineInputBorder(),
                        prefixText: 'R\$ ',
                      ),
                    ),
                    const SizedBox(height: 16),

                    ElevatedButton(
                      onPressed: _saveProduct,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50), // Correção aqui
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Salvar Produto'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}