import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/shared/presentation/components/neon_button.dart';
import 'package:automacao_bar/features/management/application/ingredients_provider.dart';
import 'package:automacao_bar/features/management/application/products_provider.dart';
import 'package:automacao_bar/features/management/application/recipe_provider.dart';

class MenuManagementScreen extends ConsumerStatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  ConsumerState<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends ConsumerState<MenuManagementScreen> {
  // Selected product ID for recipe tab
  String? _selectedProductIdForRecipe;

  // Selected ingredient ID for linking in recipe tab
  String? _selectedIngredientIdForLink;
  final _recipeQtyController = TextEditingController();
  bool _recipeIsRemovable = true;

  @override
  void dispose() {
    _recipeQtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);
    final ingredients = ref.watch(ingredientsProvider);

    // Default to first product if none selected
    if (_selectedProductIdForRecipe == null && products.isNotEmpty) {
      _selectedProductIdForRecipe = products.first.id;
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Gestão de Cardápio',
            style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            indicatorColor: AppColors.neonGreen,
            labelColor: AppColors.neonGreen,
            unselectedLabelColor: AppColors.textMuted,
            tabs: [
              Tab(icon: Icon(Icons.shopping_bag), text: 'Produtos'),
              Tab(icon: Icon(Icons.inventory_2), text: 'Estoque'),
              Tab(icon: Icon(Icons.receipt_long), text: 'Ficha Técnica'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Products
            _buildProductsTab(products),

            // Tab 2: Ingredients
            _buildIngredientsTab(ingredients),

            // Tab 3: Recipe / BOM
            _buildRecipeTab(products, ingredients),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: PRODUCTS
  // ==========================================
  Widget _buildProductsTab(List<Product> products) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: products.isEmpty
          ? const Center(
              child: Text(
                'Nenhum produto cadastrado.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.surfaceLight),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        product.category == 'Bebidas'
                            ? Icons.local_drink
                            : product.category == 'Porções'
                                ? Icons.restaurant
                                : Icons.fastfood,
                        color: AppColors.neonGreen,
                        size: 28,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                color: AppColors.textMain,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product.category,
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'R\$ ${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppColors.neonGreen,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () {
                              ref.read(productsProvider.notifier).toggleSoldOut(product.id);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: product.isSoldOut
                                    ? AppColors.danger.withValues(alpha: 0.15)
                                    : AppColors.neonGreen.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: product.isSoldOut ? AppColors.danger : AppColors.neonGreen,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                product.isSoldOut ? 'ESGOTADO' : 'ATIVO',
                                style: TextStyle(
                                  color: product.isSoldOut ? AppColors.danger : AppColors.neonGreen,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.neonGreen,
        foregroundColor: Colors.black,
        onPressed: () => _showAddProductDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddProductDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    String selectedCategory = 'Lanches';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text(
                'Cadastrar Novo Produto',
                style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold),
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Name
                      TextFormField(
                        controller: nameController,
                        style: const TextStyle(color: AppColors.textMain),
                        decoration: const InputDecoration(
                          labelText: 'Nome do Produto',
                          labelStyle: TextStyle(color: AppColors.textMuted),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceLight)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neonGreen)),
                        ),
                        validator: (val) => val == null || val.isEmpty ? 'Informe o nome' : null,
                      ),
                      const SizedBox(height: 16),
                      // Price
                      TextFormField(
                        controller: priceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: AppColors.textMain),
                        decoration: const InputDecoration(
                          labelText: 'Preço (R\$)',
                          labelStyle: TextStyle(color: AppColors.textMuted),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceLight)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neonGreen)),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Informe o preço';
                          if (double.tryParse(val.replaceAll(',', '.')) == null) return 'Preço inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Category Dropdown
                      DropdownButtonFormField<String>(
                        dropdownColor: AppColors.surface,
                        value: selectedCategory,
                        style: const TextStyle(color: AppColors.textMain),
                        decoration: const InputDecoration(
                          labelText: 'Categoria',
                          labelStyle: TextStyle(color: AppColors.textMuted),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceLight)),
                        ),
                        items: ['Lanches', 'Bebidas', 'Porções'].map((cat) {
                          return DropdownMenuItem(value: cat, child: Text(cat));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedCategory = val);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('CANCELAR', style: TextStyle(color: AppColors.textMuted)),
                ),
                TextButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final name = nameController.text;
                      final price = double.parse(priceController.text.replaceAll(',', '.'));
                      ref.read(productsProvider.notifier).addProduct(name, price, selectedCategory);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$name cadastrado com sucesso!'),
                          backgroundColor: AppColors.neonGreen,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: const Text('SALVAR', style: TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==========================================
  // TAB 2: INGREDIENTS
  // ==========================================
  Widget _buildIngredientsTab(List<Ingredient> ingredients) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ingredients.isEmpty
          ? const Center(
              child: Text(
                'Nenhum ingrediente em estoque.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ingredients.length,
              itemBuilder: (context, index) {
                final ingredient = ingredients[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.surfaceLight),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.kitchen_outlined, color: AppColors.neonGreen, size: 28),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          ingredient.name,
                          style: const TextStyle(
                            color: AppColors.textMain,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${ingredient.inStock.toStringAsFixed(1)} ${ingredient.unitMeasure}',
                            style: const TextStyle(
                              color: AppColors.neonGreen,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Em Estoque',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.neonGreen,
        foregroundColor: Colors.black,
        onPressed: () => _showAddIngredientDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddIngredientDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final stockController = TextEditingController();
    String selectedUnit = 'un';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text(
                'Cadastrar Novo Ingrediente',
                style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold),
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      style: const TextStyle(color: AppColors.textMain),
                      decoration: const InputDecoration(
                        labelText: 'Nome do Ingrediente',
                        labelStyle: TextStyle(color: AppColors.textMuted),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceLight)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neonGreen)),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Informe o nome' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: stockController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(color: AppColors.textMain),
                            decoration: const InputDecoration(
                              labelText: 'Qtd. Estoque Inicial',
                              labelStyle: TextStyle(color: AppColors.textMuted),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceLight)),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neonGreen)),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Informe o estoque';
                              if (double.tryParse(val.replaceAll(',', '.')) == null) return 'Número inválido';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            dropdownColor: AppColors.surface,
                            value: selectedUnit,
                            style: const TextStyle(color: AppColors.textMain),
                            decoration: const InputDecoration(
                              labelText: 'Unidade',
                              labelStyle: TextStyle(color: AppColors.textMuted),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceLight)),
                            ),
                            items: ['un', 'g', 'kg', 'ml', 'l'].map((u) {
                              return DropdownMenuItem(value: u, child: Text(u));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setDialogState(() => selectedUnit = val);
                              }
                            },
                          ),
                        ),
                      ],
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
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final name = nameController.text;
                      final stock = double.parse(stockController.text.replaceAll(',', '.'));
                      ref.read(ingredientsProvider.notifier).addIngredient(name, selectedUnit, stock);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Ingrediente $name cadastrado com sucesso!'),
                          backgroundColor: AppColors.neonGreen,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: const Text('SALVAR', style: TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==========================================
  // TAB 3: RECIPE / FICHA TÉCNICA
  // ==========================================
  Widget _buildRecipeTab(List<Product> products, List<Ingredient> ingredients) {
    if (products.isEmpty) {
      return const Center(
        child: Text(
          'Cadastre produtos primeiro para criar fichas técnicas.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 16),
        ),
      );
    }

    final currentProductId = _selectedProductIdForRecipe ?? products.first.id;
    final recipeIngredients = ref.watch(productRecipeProvider(currentProductId));

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Dropdown Seleção de Produto
        const Text(
          'Selecionar Produto',
          style: TextStyle(color: AppColors.textMuted, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.surfaceLight),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: AppColors.surface,
              value: currentProductId,
              isExpanded: true,
              style: const TextStyle(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.bold),
              items: products.map((prod) {
                return DropdownMenuItem(
                  value: prod.id,
                  child: Text(prod.name),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedProductIdForRecipe = val;
                    _selectedIngredientIdForLink = null;
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Ingredientes Vinculados
        const Text(
          'Ingredientes da Ficha Técnica',
          style: TextStyle(color: AppColors.textMuted, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        recipeIngredients.isEmpty
            ? Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceLight, style: BorderStyle.solid),
                ),
                child: const Center(
                  child: Text(
                    'Esta receita está vazia. Vincule ingredientes abaixo.',
                    style: TextStyle(color: AppColors.textMuted, fontStyle: FontStyle.italic),
                  ),
                ),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: recipeIngredients.map((recipeItem) {
                  return Chip(
                    backgroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: recipeItem.isRemovable ? AppColors.neonGreen.withValues(alpha: 0.4) : AppColors.surfaceLight,
                      ),
                    ),
                    label: Text(
                      '${recipeItem.name} (${recipeItem.defaultQuantity.toStringAsFixed(1)} ${recipeItem.unitMeasure})',
                      style: const TextStyle(color: AppColors.textMain),
                    ),
                    avatar: Icon(
                      recipeItem.isRemovable ? Icons.remove_circle_outline : Icons.lock_outline,
                      color: recipeItem.isRemovable ? AppColors.neonGreen : AppColors.textMuted,
                      size: 16,
                    ),
                    deleteIcon: const Icon(Icons.cancel, color: AppColors.danger, size: 18),
                    onDeleted: () {
                      ref.read(recipeProvider.notifier).removeIngredientFromRecipe(
                            currentProductId,
                            recipeItem.id,
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Ingrediente ${recipeItem.name} removido da ficha técnica.'),
                          backgroundColor: AppColors.danger,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),

        const SizedBox(height: 32),
        const Divider(color: AppColors.surfaceLight),
        const SizedBox(height: 24),

        // Form para Vincular Ingrediente
        const Text(
          'Adicionar Ingrediente à Ficha Técnica',
          style: TextStyle(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.surfaceLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ingredient Selection
              const Text('Ingrediente', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                dropdownColor: AppColors.surface,
                value: _selectedIngredientIdForLink,
                style: const TextStyle(color: AppColors.textMain),
                decoration: const InputDecoration(
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceLight)),
                ),
                items: ingredients.map((ing) {
                  return DropdownMenuItem(value: ing.id, child: Text('${ing.name} (${ing.unitMeasure})'));
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedIngredientIdForLink = val);
                },
                hint: const Text('Selecione...', style: TextStyle(color: AppColors.textMuted)),
              ),
              const SizedBox(height: 16),
              // Quantity
              TextField(
                controller: _recipeQtyController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: AppColors.textMain),
                decoration: const InputDecoration(
                  labelText: 'Quantidade Padrão',
                  labelStyle: TextStyle(color: AppColors.textMuted),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceLight)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neonGreen)),
                ),
              ),
              const SizedBox(height: 16),
              // Removable Checkbox
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Removível pelo Garçom?',
                    style: TextStyle(color: AppColors.textMain),
                  ),
                  Switch(
                    activeColor: AppColors.neonGreen,
                    value: _recipeIsRemovable,
                    onChanged: (val) {
                      setState(() => _recipeIsRemovable = val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              NeonButton(
                onTap: () {
                  final ingId = _selectedIngredientIdForLink;
                  final qtyText = _recipeQtyController.text;
                  final qty = double.tryParse(qtyText.replaceAll(',', '.'));

                  if (ingId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Selecione um ingrediente'), backgroundColor: AppColors.danger),
                    );
                    return;
                  }
                  if (qty == null || qty <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Informe uma quantidade válida'), backgroundColor: AppColors.danger),
                    );
                    return;
                  }

                  // Find ingredient name and measure
                  final ingredient = ingredients.firstWhere((ing) => ing.id == ingId);

                  ref.read(recipeProvider.notifier).addIngredientToRecipe(
                        productId: currentProductId,
                        ingredientId: ingId,
                        name: ingredient.name,
                        quantity: qty,
                        unitMeasure: ingredient.unitMeasure,
                        isRemovable: _recipeIsRemovable,
                      );

                  _recipeQtyController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${ingredient.name} adicionado à receita!'),
                      backgroundColor: AppColors.neonGreen,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                text: 'Vincular Ingrediente',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
