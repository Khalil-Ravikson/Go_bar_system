import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Verifique se os caminhos dos imports batem com as pastas do seu projeto
import '../../../../core/database/database_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../design_system/components/app_product_card.dart';
import '../../application/cart_provider.dart';

class PosMenuArea extends ConsumerStatefulWidget {
  final bool isDesktop;

  const PosMenuArea({super.key, required this.isDesktop});

  @override
  ConsumerState<PosMenuArea> createState() => _PosMenuAreaState();
}

class _PosMenuAreaState extends ConsumerState<PosMenuArea> {
  // Guardamos o estado da categoria selecionada apenas neste pedaço da tela
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. TOP BAR (Novo Pedido / Mesa)
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              const Icon(Icons.point_of_sale, color: AppColors.primaryNeon, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Novo Pedido', 
                style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Text('Mesa 12', style: TextStyle(color: AppColors.primaryNeon, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
        
        // 2. LISTA DE CATEGORIAS
        _buildCategoryList(),
        
        // 3. GRELHA DE PRODUTOS
        Expanded(child: _buildProductGrid()),
      ],
    );
  }

  // ==========================================
  // FUNÇÕES DE CONSTRUÇÃO INTERNAS
  // ==========================================

  Widget _buildCategoryList() {
    final categoriesAsync = ref.watch(watchCategoriesProvider);

    return Container(
      height: 60,
      margin: const EdgeInsets.only(bottom: 16),
      child: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNeon)),
        error: (e, st) => const Center(child: Text('Erro ao carregar', style: TextStyle(color: AppColors.error))),
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: Text('Sem categorias', style: TextStyle(color: AppColors.textSecondary)));
          }

          // Se nenhuma categoria estiver selecionada, seleciona a primeira automaticamente
          if (_selectedCategoryId == null && categories.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _selectedCategoryId = categories.first.id);
            });
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = category.id == _selectedCategoryId;

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ChoiceChip(
                  label: Text(category.name),
                  selected: isSelected,
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.primaryNeon.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primaryNeon : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: isSelected ? AppColors.primaryNeon.withValues(alpha: 0.5) : AppColors.border),
                  ),
                  onSelected: (_) => setState(() => _selectedCategoryId = category.id),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    if (_selectedCategoryId == null) return const SizedBox.shrink();

    // Busca os produtos da categoria selecionada
    final productsAsync = ref.watch(watchProductsByCategoryProvider(_selectedCategoryId!));

    return productsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNeon)),
      error: (e, st) => const Center(child: Text('Erro ao carregar', style: TextStyle(color: AppColors.error))),
      data: (products) {
        if (products.isEmpty) {
          return const Center(child: Text('Sem produtos', style: TextStyle(color: AppColors.textSecondary)));
        }

        return LayoutBuilder(builder: (context, constraints) {
          int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;

          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.15, // Ratio que criámos na refatoração
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];

              // Usando o nosso novo "Lego" do Design System!
              return AppProductCard(
                name: product.name,
                priceInCents: product.currentPrice,
                onTap: () {
                  ref.read(cartProvider.notifier).addProduct(product);
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '+ 1 ${product.name}', 
                        style: const TextStyle(color: AppColors.background, fontWeight: FontWeight.bold)
                      ),
                      backgroundColor: AppColors.primaryNeon,
                      duration: const Duration(milliseconds: 400),
                    ),
                  );
                },
              );
            },
          );
        });
      },
    );
  }
}