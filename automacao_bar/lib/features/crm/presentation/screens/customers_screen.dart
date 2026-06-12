import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/features/crm/application/customers_provider.dart';

class CustomersScreen extends ConsumerWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = ref.watch(customersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('CRM - Gestão de Clientes', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Carteira de Clientes & Limite de Fiado',
                style: TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Acompanhe o saldo devedor e contas correntes dos clientes do restaurante.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 24),
              
              // Customers List
              Expanded(
                child: customers.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum cliente cadastrado.',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 16),
                        ),
                      )
                    : ListView.separated(
                        itemCount: customers.length,
                        separatorBuilder: (context, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final c = customers[index];
                          final hasDebt = c.currentBalance > 0;

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: hasDebt 
                                    ? AppColors.danger.withValues(alpha: 0.3) 
                                    : AppColors.surfaceLight,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: hasDebt 
                                      ? AppColors.danger.withValues(alpha: 0.15) 
                                      : AppColors.neonGreen.withValues(alpha: 0.15),
                                  child: Text(
                                    c.name[0],
                                    style: TextStyle(
                                      color: hasDebt ? AppColors.danger : AppColors.neonGreen,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.name,
                                        style: const TextStyle(
                                          color: AppColors.textMain,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        c.phone,
                                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'R\$ ${c.currentBalance.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: hasDebt ? AppColors.danger : AppColors.textMuted,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      hasDebt ? 'Saldo Devedor' : 'Sem débitos',
                                      style: TextStyle(
                                        color: hasDebt ? AppColors.danger.withValues(alpha: 0.7) : AppColors.textMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                // Repay/Payment Action Button
                                IconButton(
                                  icon: const Icon(Icons.payment, color: AppColors.neonGreen),
                                  tooltip: 'Amortizar Dívida',
                                  onPressed: () => _showRepayDialog(context, ref, c),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.neonGreen,
        foregroundColor: Colors.black,
        onPressed: () => _showAddCustomerDialog(context, ref),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  void _showRepayDialog(BuildContext context, WidgetRef ref, Customer customer) {
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Amortizar Conta de ${customer.name}',
            style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Saldo devedor total: R\$ ${customer.currentBalance.toStringAsFixed(2)}',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: AppColors.textMain),
                  decoration: const InputDecoration(
                    labelText: 'Valor Pago (R\$)',
                    labelStyle: TextStyle(color: AppColors.textMuted),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceLight)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neonGreen)),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Informe o valor';
                    final numVal = double.tryParse(val.replaceAll(',', '.'));
                    if (numVal == null || numVal <= 0) return 'Valor inválido';
                    return null;
                  },
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
                  final amount = double.parse(amountController.text.replaceAll(',', '.'));
                  ref.read(customersProvider.notifier).payDebt(customer.id, amount);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Pagamento de R\$ ${amount.toStringAsFixed(2)} amortizado com sucesso!'),
                      backgroundColor: AppColors.neonGreen,
                    ),
                  );
                }
              },
              child: const Text('CONFIRMAR', style: TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showAddCustomerDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Cadastrar Novo Cliente',
            style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 18),
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
                    labelText: 'Nome Completo',
                    labelStyle: TextStyle(color: AppColors.textMuted),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceLight)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neonGreen)),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Informe o nome' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: AppColors.textMain),
                  decoration: const InputDecoration(
                    labelText: 'Telefone / WhatsApp',
                    labelStyle: TextStyle(color: AppColors.textMuted),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceLight)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neonGreen)),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Informe o telefone' : null,
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
                  final phone = phoneController.text;
                  ref.read(customersProvider.notifier).addCustomer(name, phone);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Cliente $name cadastrado com sucesso!'),
                      backgroundColor: AppColors.neonGreen,
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
  }
}
