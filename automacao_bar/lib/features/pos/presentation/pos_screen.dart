import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../presentation/theme/app_colors.dart';
import '../application/cart_provider.dart'; // A nossa nova lógica

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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 800;

            if (isDesktop) {
              return Row(
                children: [
                  Expanded(flex: 7, child: _buildMenuArea()),
                  const VerticalDivider(width: 1, color: AppColors.border),
                  Expanded(flex: 3, child: _buildOrderPanel(isDesktop: true)),
                ],
              );
            } else {
              return Column(
                children: [
                  Expanded(child: _buildMenuArea()),
                  _buildOrderPanel(isDesktop: false),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  // ==========================================
  // ÁREA ESQUERDA: CATEGORIAS E PRODUTOS
  // ==========================================
  Widget _buildMenuArea() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              const Icon(Icons.point_of_sale, color: AppColors.primaryNeon, size: 28),
              const SizedBox(width: 12),
              const Text('Novo Pedido', style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
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
        _buildCategoryList(),
        Expanded(child: _buildProductGrid()),
      ],
    );
  }

  Widget _buildCategoryList() {
    final categoriesAsync = ref.watch(watchCategoriesProvider);

    return Container(
      height: 60,
      margin: const EdgeInsets.only(bottom: 16),
      child: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNeon)),
        error: (e, st) => const Center(child: Text('Erro ao carregar')),
        data: (categories) {
          if (categories.isEmpty) return const Center(child: Text('Sem categorias', style: TextStyle(color: AppColors.textSecondary)));

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
                  selectedColor: AppColors.primaryNeon.withOpacity(0.15),
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primaryNeon : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: isSelected ? AppColors.primaryNeon.withOpacity(0.5) : AppColors.border),
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

    final productsAsync = ref.watch(watchProductsByCategoryProvider(_selectedCategoryId!));

    return productsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryNeon)),
      error: (e, st) => const Center(child: Text('Erro ao carregar')),
      data: (products) {
        if (products.isEmpty) return const Center(child: Text('Sem produtos', style: TextStyle(color: AppColors.textSecondary)));

        return LayoutBuilder(builder: (context, constraints) {
          int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;

          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];

              return InkWell(
                onTap: () {
                  // A MÁGICA ACONTECE AQUI: Adicionar ao Provider!
                  ref.read(cartProvider.notifier).addProduct(product);
                  
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('+ 1 ${product.name}', style: const TextStyle(color: AppColors.background, fontWeight: FontWeight.bold)),
                      backgroundColor: AppColors.primaryNeon,
                      duration: const Duration(milliseconds: 400),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        product.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryNeon.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _formatPrice(product.currentPrice),
                          style: const TextStyle(color: AppColors.primaryNeon, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        });
      },
    );
  }

  // ==========================================
  // ÁREA DIREITA/INFERIOR: COMANDA ATUAL (REATIVA)
  // ==========================================
  Widget _buildOrderPanel({required bool isDesktop}) {
    // Escutamos o carrinho para atualizar o ecrã instantaneamente
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: isDesktop ? AppColors.surface.withOpacity(0.5) : AppColors.surface,
        border: Border(top: isDesktop ? BorderSide.none : const BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            if (isDesktop) ...[
              const Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.receipt_long, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Text('Comanda Atual', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Divider(color: AppColors.border, height: 1),
              
              // LISTA DE ITENS REATIVA
              Expanded(
                child: cartItems.isEmpty
                    ? const Center(child: Text('Nenhum item adicionado', style: TextStyle(color: AppColors.textSecondary)))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: cartItems.length,
                        separatorBuilder: (context, index) => const Divider(color: AppColors.border),
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return Row(
                            children: [
                              // Botões de quantidade ao estilo da sua imagem
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: AppColors.error, size: 20),
                                    onPressed: () => cartNotifier.removeProduct(item.product.id),
                                  ),
                                  Text('${item.quantity}', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryNeon, size: 20),
                                    onPressed: () => cartNotifier.addProduct(item.product),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Text(item.product.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                              ),
                              Text(
                                _formatPrice(item.product.currentPrice * item.quantity),
                                style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                              ),
                            ],
                          );
                        },
                      ),
              ),
              const Divider(color: AppColors.border, height: 1),
            ],
            
            // RODAPÉ COM VALORES REATIVOS
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (isDesktop) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                        Text(_formatPrice(cartNotifier.totalInCents), style: const TextStyle(color: AppColors.textPrimary, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isDesktop ? 'Total' : 'Mesa 12', style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                      Text(
                        _formatPrice(cartNotifier.totalInCents),
                        style: const TextStyle(color: AppColors.primaryNeon, fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: cartItems.isEmpty ? null : () {
                        // TODO: Gravar na base de dados (Drift) e disparar evento
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Comanda enviada para a mesa!'), backgroundColor: AppColors.success),
                        );
                        cartNotifier.clearCart();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryNeon,
                        disabledBackgroundColor: AppColors.border,
                        foregroundColor: AppColors.background,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'CONFIRMAR PEDIDO',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}