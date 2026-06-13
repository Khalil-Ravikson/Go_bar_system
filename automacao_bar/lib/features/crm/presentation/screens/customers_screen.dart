import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/features/crm/application/customers_provider.dart';
import 'package:automacao_bar/shared/presentation/components/app_empty_state.dart';
import '../widgets/customer_list_tile.dart';
import '../widgets/repay_debt_dialog.dart';
import '../widgets/add_customer_dialog.dart';

class CustomersScreen extends ConsumerWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = ref.watch(customersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.neonGreen,
        foregroundColor: Colors.black,
        onPressed: () => AddCustomerDialog.show(context),
        child: const Icon(Icons.person_add),
      ),
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar com scroll collapse ──────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: AppColors.surface,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(start: 24, bottom: 16),
              title: const Text(
                'CRM — Clientes',
                style: TextStyle(
                  color: AppColors.textMain,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              background: Container(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 52),
                alignment: Alignment.bottomLeft,
                decoration: const BoxDecoration(color: AppColors.surface),
                child: const Text(
                  'Carteira de clientes e controle de fiado',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ),
            ),
          ),

          // ── Customer list ──────────────────────────────────────────────
          customers.isEmpty
              ? const SliverFillRemaining(
                  child: AppEmptyState(
                    icon: Icons.people_outline,
                    title: 'Nenhum cliente cadastrado',
                    subtitle: 'Toque no + para adicionar o primeiro cliente.',
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final c = customers[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index < customers.length - 1 ? 12 : 0,
                          ),
                          child: CustomerListTile(
                            customer: c,
                            onRepay: () => showDialog(
                              context: context,
                              builder: (_) => RepayDebtDialog(customer: c),
                            ),
                          ),
                        );
                      },
                      childCount: customers.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
