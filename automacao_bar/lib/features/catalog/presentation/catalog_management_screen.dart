import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;

import '../../../core/theme/app_colors.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/database/app_database.dart';

class CatalogManagementScreen extends ConsumerStatefulWidget {
  const CatalogManagementScreen({super.key});

  @override
  ConsumerState<CatalogManagementScreen> createState() => _CatalogManagementScreenState();
}

class _CatalogManagementScreenState extends ConsumerState<CatalogManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Category controllers
  final _categoryNameController = TextEditingController();

  // Product controllers
  final _productNameController = TextEditingController();
  final _productPriceController = TextEditingController();
  final _productDescriptionController = TextEditingController();
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    _productNameController.dispose();
    _productPriceController.dispose();
    _productDescriptionController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    final name = _categoryNameController.text.trim();
    if (name.isEmpty) return;

    final dao = ref.read(catalogDaoProvider);
    await dao.insertCategory(name);

    _categoryNameController.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Categoria "$name" salva com sucesso!'),
          backgroundColor: AppColors.neonGreen,
        ),
      );
    }
  }

  Future<void> _saveProduct() async {
    final name = _productNameController.text.trim();
    final price = double.tryParse(_productPriceController.text.replaceAll(',', '.')) ?? 0.0;

    if (name.isEmpty || price <= 0 || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos do produto com valores válidos.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final dao = ref.read(catalogDaoProvider);
    await dao.insertProduct(
      categoryId: _selectedCategoryId!,
      name: name,
      price: price,
    );

    _productNameController.clear();
    _productPriceController.clear();
    _productDescriptionController.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Produto "$name" salvo com sucesso!'),
          backgroundColor: AppColors.neonGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(watchCategoriesProvider);
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
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(start: 24, bottom: 52),
              title: Text(
                'Gestão do Cardápio',
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
                Tab(icon: Icon(Icons.category_outlined), text: 'Categorias'),
                Tab(icon: Icon(Icons.restaurant_menu_outlined), text: 'Produtos & Receitas'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildCategoriesTab(categoriesAsync),
            _buildProductsTab(productsAsync, categoriesAsync),
          ],
        ),
      ),
    );
  }

  // === TAB 1: CATEGORIES ===
  Widget _buildCategoriesTab(AsyncValue<List<Category>> categoriesAsync) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NOVA CATEGORIA',
            style: GoogleFonts.shareTechMono(
              color: AppColors.textMain,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _categoryNameController,
            style: const TextStyle(color: AppColors.textMain),
            decoration: const InputDecoration(
              labelText: 'Nome da Categoria (ex: Hambúrgueres)',
              labelStyle: TextStyle(color: AppColors.textMuted),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceLight)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neonGreen)),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonGreen,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _saveCategory,
              child: Text(
                'SALVAR CATEGORIA',
                style: GoogleFonts.shareTechMono(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'CATEGORIAS EXISTENTES',
            style: GoogleFonts.shareTechMono(
              color: AppColors.textMain,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          categoriesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.neonGreen)),
            error: (err, _) => Text('Erro: $err', style: const TextStyle(color: AppColors.danger)),
            data: (categories) {
              if (categories.isEmpty) {
                return const Text('Nenhuma categoria cadastrada.', style: TextStyle(color: AppColors.textMuted));
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                separatorBuilder: (context, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.surfaceLight),
                    ),
                    child: Text(
                      cat.name,
                      style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // === TAB 2: PRODUCTS & RECIPES ===
  Widget _buildProductsTab(
    AsyncValue<List<Product>> productsAsync,
    AsyncValue<List<Category>> categoriesAsync,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 16),
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
              label: Text('CADASTRAR NOVO PRODUTO', style: GoogleFonts.shareTechMono(fontWeight: FontWeight.bold)),
              onPressed: () => _showAddProductDialog(categoriesAsync),
            ),
          ),
        ),
        Expanded(
          child: productsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.neonGreen)),
            error: (err, _) => Center(child: Text('Erro: $err', style: const TextStyle(color: AppColors.danger))),
            data: (products) {
              if (products.isEmpty) {
                return const Center(
                  child: Text('Nenhum produto cadastrado.', style: TextStyle(color: AppColors.textMuted)),
                );
              }

              return categoriesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Container(),
                data: (categories) {
                  return ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: products.length,
                    separatorBuilder: (context, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final cat = categories.firstWhere(
                        (c) => c.id == product.categoryId,
                        orElse: () => Category(id: '', name: 'Sem Categoria', sortOrder: 0, updatedAt: 0),
                      );

                      return InkWell(
                        onTap: () => _showEditProductAndRecipeSheet(product, categories),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.surfaceLight),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      color: AppColors.textMain,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    cat.name,
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'R\$ ${product.price.toStringAsFixed(2)}',
                                    style: GoogleFonts.robotoMono(
                                      color: AppColors.neonGreen,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.chevron_right, color: AppColors.textMuted),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // === DIALOG: ADD NEW PRODUCT ===
  void _showAddProductDialog(AsyncValue<List<Category>> categoriesAsync) {
    _productNameController.clear();
    _productPriceController.clear();
    _productDescriptionController.clear();
    _selectedCategoryId = null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: Text(
                'NOVO PRODUTO',
                style: GoogleFonts.shareTechMono(color: AppColors.textMain, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    categoriesAsync.when(
                      data: (categories) {
                        return DropdownButtonFormField<String>(
                          value: _selectedCategoryId,
                          dropdownColor: AppColors.surface,
                          style: const TextStyle(color: AppColors.textMain),
                          decoration: const InputDecoration(
                            labelText: 'Categoria',
                            labelStyle: TextStyle(color: AppColors.textMuted),
                          ),
                          hint: const Text('Selecione a Categoria', style: TextStyle(color: AppColors.textMuted)),
                          items: categories.map((c) {
                            return DropdownMenuItem(value: c.id, child: Text(c.name));
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedCategoryId = val),
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (err, _) => Text('Erro: $err'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _productNameController,
                      style: const TextStyle(color: AppColors.textMain),
                      decoration: const InputDecoration(
                        labelText: 'Nome do Produto (ex: Hambúrguer Duplo)',
                        labelStyle: TextStyle(color: AppColors.textMuted),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceLight)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neonGreen)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _productPriceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: AppColors.textMain),
                      decoration: const InputDecoration(
                        labelText: 'Preço de Venda (R\$)',
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
                    await _saveProduct();
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

  // === EDIT PRODUCT & RECIPE SHEET ===
  void _showEditProductAndRecipeSheet(Product product, List<Category> categories) {
    final nameController = TextEditingController(text: product.name);
    final priceController = TextEditingController(text: product.price.toStringAsFixed(2));
    String catId = product.categoryId;

    // Recipe editing state
    final List<ProductRecipe> currentRecipeItems = [];
    final List<ProductRecipesCompanion> newRecipeCompanions = [];

    // Temporary lists to manage ingredients before clicking save
    StockItem? selectedStockItem;
    final qtyController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceAlt,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final stockItems = ref.watch(allStockItemsProvider).value ?? [];
            final recipeAsync = ref.watch(productRecipesProvider(product.id));

            // Load initial recipes on first build
            recipeAsync.whenData((recipes) {
              if (currentRecipeItems.isEmpty && recipes.isNotEmpty) {
                currentRecipeItems.addAll(recipes);
              }
            });

            // Calculate recipe cost
            double totalCost = 0.0;
            for (final recipe in currentRecipeItems) {
              final stock = stockItems.firstWhere((s) => s.id == recipe.stockItemId, orElse: () => null as dynamic);
              if (stock != null) {
                totalCost += recipe.quantity * stock.costPrice;
              }
            }

            final suggestedPrice = totalCost * 2.5; // 2.5x markup (150% margem)

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
                      Text(
                        'EDITAR PRODUTO & FICHA TÉCNICA',
                        style: GoogleFonts.shareTechMono(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      // Product Fields
                      DropdownButtonFormField<String>(
                        value: catId,
                        dropdownColor: AppColors.surface,
                        style: const TextStyle(color: AppColors.textMain),
                        decoration: const InputDecoration(labelText: 'Categoria'),
                        items: categories.map((c) {
                          return DropdownMenuItem(value: c.id, child: Text(c.name));
                        }).toList(),
                        onChanged: (val) => setSheetState(() => catId = val ?? catId),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: nameController,
                        style: const TextStyle(color: AppColors.textMain),
                        decoration: const InputDecoration(labelText: 'Nome do Produto'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: priceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: AppColors.textMain),
                        decoration: const InputDecoration(labelText: 'Preço de Venda (R\$)'),
                      ),
                      
                      const SizedBox(height: 24),
                      const Divider(color: AppColors.surfaceLight),
                      const SizedBox(height: 16),

                      // Recipe Section Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'FICHA TÉCNICA (RECEITA)',
                            style: GoogleFonts.shareTechMono(color: AppColors.magentaCyber, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(4)),
                            child: Text(
                              'Custo Total: R\$ ${totalCost.toStringAsFixed(2)}',
                              style: GoogleFonts.robotoMono(color: AppColors.neonRed, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Suggested pricing info box
                      Container(
                        padding: const EdgeInsets.all(12),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.surfaceLight),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Preço Sugerido (Margem 150%):', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                            Text(
                              'R\$ ${suggestedPrice.toStringAsFixed(2)}',
                              style: GoogleFonts.robotoMono(color: AppColors.neonGreen, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Recipe Ingredients List
                      if (currentRecipeItems.isEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('Nenhum ingrediente na receita deste produto.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        ),
                      ] else ...[
                        Column(
                          children: currentRecipeItems.map((recipe) {
                            final stock = stockItems.firstWhere((s) => s.id == recipe.stockItemId, orElse: () => null as dynamic);
                            if (stock == null) return Container();
                            final itemCost = recipe.quantity * stock.costPrice;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${recipe.quantity} ${stock.unit} de ${stock.name} (R\$ ${itemCost.toStringAsFixed(2)})',
                                      style: const TextStyle(color: AppColors.textMain, fontSize: 13),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: AppColors.neonRed, size: 20),
                                    onPressed: () {
                                      setSheetState(() {
                                        currentRecipeItems.remove(recipe);
                                      });
                                    },
                                  )
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Add Ingredient to Recipe Tool
                      Text(
                        'ADICIONAR INGREDIENTE',
                        style: GoogleFonts.shareTechMono(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField<StockItem>(
                              dropdownColor: AppColors.surface,
                              style: const TextStyle(color: AppColors.textMain),
                              decoration: const InputDecoration(labelText: 'Ingrediente'),
                              hint: const Text('Selecionar', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                              items: stockItems.map((item) {
                                return DropdownMenuItem(value: item, child: Text(item.name));
                              }).toList(),
                              onChanged: (val) => setSheetState(() => selectedStockItem = val),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: qtyController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(color: AppColors.textMain),
                              decoration: InputDecoration(
                                labelText: selectedStockItem != null ? 'Qtd (${selectedStockItem!.unit})' : 'Qtd',
                                labelStyle: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.magentaCyber,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              if (selectedStockItem == null || qtyController.text.isEmpty) return;
                              final qty = double.tryParse(qtyController.text.replaceAll(',', '.')) ?? 0.0;
                              if (qty <= 0) return;

                              // Check if ingredient is already present
                              if (currentRecipeItems.any((r) => r.stockItemId == selectedStockItem!.id)) {
                                return;
                              }

                              setSheetState(() {
                                currentRecipeItems.add(
                                  ProductRecipe(
                                    id: const Uuid().v7(),
                                    productId: product.id,
                                    stockItemId: selectedStockItem!.id,
                                    quantity: qty,
                                    updatedAt: DateTime.now().millisecondsSinceEpoch,
                                  ),
                                );
                                qtyController.clear();
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
                      
                      // Save All Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.neonGreen,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            final name = nameController.text.trim();
                            final price = double.tryParse(priceController.text.replaceAll(',', '.')) ?? product.price;

                            if (name.isEmpty) return;

                            // 1. Update Product details
                            final db = ref.read(databaseProvider);
                            await (db.update(db.products)..where((p) => p.id.equals(product.id))).write(
                              ProductsCompanion(
                                categoryId: drift.Value(catId),
                                name: drift.Value(name),
                                price: drift.Value(price),
                                updatedAt: drift.Value(DateTime.now().millisecondsSinceEpoch),
                              ),
                            );

                            // 2. Save Technical Recipe (Ficha Técnica)
                            final recipeCompanions = currentRecipeItems.map((item) {
                              return ProductRecipesCompanion.insert(
                                id: item.id,
                                productId: product.id,
                                stockItemId: item.stockItemId,
                                quantity: item.quantity,
                                updatedAt: DateTime.now().millisecondsSinceEpoch,
                              );
                            }).toList();

                            final inventoryDao = ref.read(inventoryDaoProvider);
                            await inventoryDao.saveRecipe(product.id, recipeCompanions);

                            if (context.mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Produto e Ficha Técnica atualizados com sucesso!'),
                                  backgroundColor: AppColors.neonGreen,
                                ),
                              );
                            }
                          },
                          child: Text(
                            'SALVAR ALTERAÇÕES',
                            style: GoogleFonts.shareTechMono(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
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