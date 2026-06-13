import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/features/crm/application/customers_provider.dart';

/// Dialog de cadastro de novo cliente no CRM.
class AddCustomerDialog extends ConsumerStatefulWidget {
  const AddCustomerDialog({super.key});

  static void show(BuildContext context) {
    showDialog(context: context, builder: (_) => const AddCustomerDialog());
  }

  @override
  ConsumerState<AddCustomerDialog> createState() => _AddCustomerDialogState();
}

class _AddCustomerDialogState extends ConsumerState<AddCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textMuted),
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.surfaceLight)),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.neonGreen)),
      );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Cadastrar Novo Cliente',
        style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: AppColors.textMain),
              decoration: _inputDecoration('Nome Completo'),
              validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: AppColors.textMain),
              decoration: _inputDecoration('Telefone / WhatsApp'),
              validator: (v) => v == null || v.isEmpty ? 'Informe o telefone' : null,
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
            if (_formKey.currentState!.validate()) {
              ref.read(customersProvider.notifier).addCustomer(
                    _nameController.text,
                    _phoneController.text,
                  );
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  'Cliente ${_nameController.text} cadastrado!',
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                backgroundColor: AppColors.neonGreen,
              ));
            }
          },
          child: const Text('SALVAR',
              style: TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
