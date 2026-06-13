import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/features/crm/application/customers_provider.dart';

/// Modal de seleção de cliente para vincular à comanda atual.
void showLinkCustomerDialog(
  BuildContext context,
  WidgetRef ref,
  List<Customer> customers,
) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Vincular Cliente à Comanda',
          style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold),
        ),
        content: customers.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Text(
                  'Nenhum cliente cadastrado no CRM.',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              )
            : SizedBox(
                width: 300,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: customers.length,
                  separatorBuilder: (context, _) =>
                      const Divider(color: AppColors.surfaceLight),
                  itemBuilder: (context, index) {
                    final c = customers[index];
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          ref.read(selectedCustomerProvider.notifier).state = c;
                          Navigator.of(context).pop();
                        },
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: AppColors.surfaceLight,
                            child: Text(
                              c.name[0],
                              style: const TextStyle(
                                color: AppColors.neonGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            c.name,
                            style: const TextStyle(
                              color: AppColors.textMain,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            c.currentBalance > 0
                                ? 'Saldo Devedor: R\$ ${c.currentBalance.toStringAsFixed(2)}'
                                : 'Sem débitos',
                            style: TextStyle(
                              color: c.currentBalance > 0
                                  ? AppColors.danger
                                  : AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'CANCELAR',
              style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    },
  );
}
