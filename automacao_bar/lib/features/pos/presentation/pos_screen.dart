import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_provider.dart';

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  String? _selectedCategoryId;

  String _formatPrice(int priceInCents) {
    final value = priceInCents / 100;
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(watchCategoriesProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // Remoção do background color fixo: ele agora usa o background do seu app_colors
      appBar: AppBar(
        title: const Text('Novo Pedido - Mesa --', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, // Deixa o fundo escuro brilhar
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. BARRA DE CATEGORIAS
          Container(
            height: 70,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
            ),
            child: categoriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Erro: $e', style: const TextStyle(color: Colors.red))),
              data: (categories) {
                if (categories.isEmpty) return const Center(child: Text('Nenhuma categoria.', style: TextStyle(color: Colors.grey)));

                if (_selectedCategoryId == null && categories.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _selectedCategoryId = categories.first.id);
                  });
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = category.id == _selectedCategoryId;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text(category.name),
                        selected: isSelected,
                        selectedColor: colorScheme.secondary.withOpacity(0.2), // Usa o laranja do tema
                        backgroundColor: Theme.of(context).cardColor,
                        labelStyle: TextStyle(
                          color: isSelected ? colorScheme.secondary : Colors.white70,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected ? colorScheme.secondary : Colors.transparent,
                        ),
                        onSelected: (_) => setState(() => _selectedCategoryId = category.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // 2. GRADE DE PRODUTOS
          Expanded(
            child: _selectedCategoryId == null
                ? const Center(child: Text('Selecione uma categoria', style: TextStyle(color: Colors.grey)))
                : Consumer(
                    builder: (context, ref, child) {
                      final productsAsync = ref.watch(watchProductsByCategoryProvider(_selectedCategoryId!));

                      return productsAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, st) => Center(child: Text('Erro: $e', style: const TextStyle(color: Colors.red))),
                        data: (products) {
                          if (products.isEmpty) return const Center(child: Text('Nenhum produto.', style: TextStyle(color: Colors.grey)));

                          return GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.1,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];

                              return InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${product.name} adicionado!', style: const TextStyle(color: Colors.white)),
                                      backgroundColor: colorScheme.primary, // Usa o Neon do tema
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        product.name,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        _formatPrice(product.currentPrice),
                                        style: TextStyle(fontSize: 16, color: colorScheme.primary, fontWeight: FontWeight.w600),
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
          
          // 3. BARRA INFERIOR (Total)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Total', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Text('R\$ 0,00', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.secondary, // Botão Laranja
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Revisar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}