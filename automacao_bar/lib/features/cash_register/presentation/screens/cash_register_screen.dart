import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/features/auth/application/auth_provider.dart';
import 'package:automacao_bar/features/cash_register/application/cash_register_provider.dart';

class CashRegisterScreen extends ConsumerStatefulWidget {
  const CashRegisterScreen({super.key});

  @override
  ConsumerState<CashRegisterScreen> createState() => _CashRegisterScreenState();
}

class _CashRegisterScreenState extends ConsumerState<CashRegisterScreen> {
  final _openingAmountController = TextEditingController(text: '100.00');
  final _openingNotesController = TextEditingController();
  final _transactionAmountController = TextEditingController();
  final _transactionReasonController = TextEditingController();
  final _closingAmountController = TextEditingController();
  final _closingNotesController = TextEditingController();

  @override
  void dispose() {
    _openingAmountController.dispose();
    _openingNotesController.dispose();
    _transactionAmountController.dispose();
    _transactionReasonController.dispose();
    _closingAmountController.dispose();
    _closingNotesController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month às $hour:$minute';
  }

  void _showTransactionDialog(bool isSangria) {
    _transactionAmountController.clear();
    _transactionReasonController.clear();
    final title = isSangria ? 'Registrar Sangria (Retirada)' : 'Registrar Suprimento (Reforço)';
    final label = isSangria ? 'Valor da Retirada' : 'Valor do Depósito';
    final reasonHint = isSangria ? 'Ex: Sangria de segurança, compra de gelo...' : 'Ex: Troco adicional, suprimento de moedas...';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(title, style: const TextStyle(color: AppColors.textMain)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _transactionAmountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: AppColors.textMain),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(color: AppColors.textMuted),
                hintText: '0.00',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceLight)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neonGreen)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _transactionReasonController,
              style: const TextStyle(color: AppColors.textMain),
              decoration: InputDecoration(
                labelText: 'Motivo / Observação',
                labelStyle: const TextStyle(color: AppColors.textMuted),
                hintText: reasonHint,
                hintStyle: const TextStyle(color: AppColors.textMuted),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceLight)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neonGreen)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(_transactionAmountController.text) ?? 0.0;
              final reason = _transactionReasonController.text;
              if (amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor, informe um valor válido.')),
                );
                return;
              }
              final session = ref.read(authProvider);
              if (session == null) return;
              ref.read(cashRegisterProvider.notifier).addTransaction(
                amount: amount,
                type: isSangria ? CashTransactionType.sangria : CashTransactionType.suprimento,
                reason: reason.isEmpty ? (isSangria ? 'Retirada avulsa' : 'Suprimento de troco') : reason,
                user: session.name,
              );
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isSangria ? 'Sangria registrada com sucesso!' : 'Suprimento registrado com sucesso!',
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: AppColors.neonGreen,
                ),
              );
            },
            child: const Text('Confirmar', style: TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCloseRegisterDialog(double expectedAmount) {
    _closingAmountController.clear();
    _closingNotesController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Fechar Caixa de Turno', style: TextStyle(color: AppColors.textMain)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Valor esperado em caixa: R\$ ${expectedAmount.toStringAsFixed(2)}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _closingAmountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: AppColors.textMain),
              decoration: const InputDecoration(
                labelText: 'Valor Contado em Caixa (Real)',
                labelStyle: TextStyle(color: AppColors.textMuted),
                hintText: '0.00',
                hintStyle: TextStyle(color: AppColors.textMuted),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceLight)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neonGreen)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _closingNotesController,
              style: const TextStyle(color: AppColors.textMain),
              decoration: const InputDecoration(
                labelText: 'Notas / Justificativa',
                labelStyle: TextStyle(color: AppColors.textMuted),
                hintText: 'Ex: Tudo conferido, ou falta de troco de R\$ 2...',
                hintStyle: TextStyle(color: AppColors.textMuted),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceLight)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neonGreen)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              final counted = double.tryParse(_closingAmountController.text) ?? -1.0;
              final notes = _closingNotesController.text;
              if (counted < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor, informe o valor contado.')),
                );
                return;
              }
              final session = ref.read(authProvider);
              if (session == null) return;
              final diff = counted - expectedAmount;
              
              ref.read(cashRegisterProvider.notifier).closeRegister(counted, notes, session.name);
              Navigator.of(context).pop();

              // Report closure result
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: const Text('Resumo de Fechamento', style: TextStyle(color: AppColors.textMain)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Esperado: R\$ ${expectedAmount.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.textMain)),
                      const SizedBox(height: 4),
                      Text('Contado: R\$ ${counted.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.textMain)),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Diferença:', style: TextStyle(color: AppColors.textMuted)),
                          Text(
                            diff == 0
                                ? 'SEM DISCREPÂNCIA'
                                : (diff > 0 
                                    ? 'SOBRA: +R\$ ${diff.toStringAsFixed(2)}'
                                    : 'QUEBRA: -R\$ ${(-diff).toStringAsFixed(2)}'),
                            style: TextStyle(
                              color: diff == 0
                                  ? AppColors.neonGreen
                                  : (diff > 0 ? Colors.blue : AppColors.danger),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Concluído', style: TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Fechar Caixa', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authProvider);
    final cashState = ref.watch(cashRegisterProvider);

    if (session == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.neonGreen),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Gestão de Caixa',
          style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: cashState.isOpen
              ? _buildOpenRegisterDashboard(cashState, session.name)
              : _buildClosedRegisterForm(session.name),
        ),
      ),
    );
  }

  // Renders when register is closed (opening shift form)
  Widget _buildClosedRegisterForm(String activeUser) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Card(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.surfaceLight),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: Icon(Icons.lock_outline, color: AppColors.neonGreen, size: 64),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'O Caixa de Turno está Fechado',
                  style: TextStyle(color: AppColors.textMain, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Abra o caixa informando o fundo de troco inicial para operar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ),
              const SizedBox(height: 32),
              
              TextField(
                controller: _openingAmountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: AppColors.textMain),
                decoration: const InputDecoration(
                  labelText: 'Fundo de Troco Inicial (R\$)',
                  labelStyle: TextStyle(color: AppColors.textMuted),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceLight)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neonGreen)),
                ),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _openingNotesController,
                style: const TextStyle(color: AppColors.textMain),
                decoration: const InputDecoration(
                  labelText: 'Observações de Abertura',
                  labelStyle: TextStyle(color: AppColors.textMuted),
                  hintText: 'Ex: Notas baixas para facilidade de troco...',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceLight)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neonGreen)),
                ),
              ),
              
              const SizedBox(height: 48),
              
              ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(_openingAmountController.text) ?? 0.0;
                  final notes = _openingNotesController.text;
                  if (amount < 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Valor inicial inválido.')),
                    );
                    return;
                  }
                  ref.read(cashRegisterProvider.notifier).openRegister(amount, notes, activeUser);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Caixa aberto com sucesso!',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: AppColors.neonGreen,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'ABRIR CAIXA DE TURNO',
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Renders when register is open (active shift dashboard)
  Widget _buildOpenRegisterDashboard(CashRegisterState state, String activeUser) {
    // Calculate metric elements
    double inflows = 0.0;
    double outflows = 0.0;
    for (var tx in state.transactions) {
      if (tx.type == CashTransactionType.suprimento || tx.type == CashTransactionType.venda) {
        inflows += tx.amount;
      } else if (tx.type == CashTransactionType.sangria) {
        outflows += tx.amount;
      }
    }

    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        // Operator details info header card
        Container(
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
                  const Text('Caixa Aberto & Operando', style: TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('Operador: ${state.openedBy ?? activeUser}', style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w600)),
                ],
              ),
              Text(
                state.openedAt != null ? _formatDateTime(state.openedAt!) : '',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Metrics Grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.6,
          children: [
            _buildMetricCard('Saldo Inicial', state.initialAmount, AppColors.textMuted),
            _buildMetricCard('Entradas (+)', inflows, AppColors.neonGreen),
            _buildMetricCard('Saídas (-)', outflows, AppColors.danger),
            _buildMetricCard('Saldo em Gaveta', state.currentAmount, Colors.blue, highlight: true),
          ],
        ),
        const SizedBox(height: 24),

        // Quick Actions Row
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('REFORÇO (SUPRIMENTO)'),
                onPressed: () => _showTransactionDialog(false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceLight,
                  foregroundColor: AppColors.textMain,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.remove, size: 18),
                label: const Text('SANGRIA (RETIRADA)'),
                onPressed: () => _showTransactionDialog(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceLight,
                  foregroundColor: AppColors.textMain,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Transactions log
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Histórico do Turno',
              style: TextStyle(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${state.transactions.length} lançamento(s)',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (state.transactions.isEmpty) ...[
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32.0),
              child: Text('Nenhum lançamento no caixa.', style: TextStyle(color: AppColors.textMuted)),
            ),
          ),
        ] else ...[
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.transactions.length,
            separatorBuilder: (context, idx) => const SizedBox(height: 8),
            itemBuilder: (context, idx) {
              final tx = state.transactions[idx];
              return _buildTransactionRow(tx);
            },
          ),
        ],
        const SizedBox(height: 48),

        // Close register trigger
        ElevatedButton(
          onPressed: () => _showCloseRegisterDialog(state.currentAmount),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger.withValues(alpha: 0.15),
            foregroundColor: AppColors.danger,
            side: const BorderSide(color: AppColors.danger, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text(
            'ENCERRAR TURNO & FECHAR CAIXA',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildMetricCard(String label, double value, Color color, {bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: highlight ? color.withValues(alpha: 0.4) : AppColors.surfaceLight, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'R\$ ${value.toStringAsFixed(2)}',
            style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(CashTransaction tx) {
    IconData icon;
    Color color;
    String typeLabel;

    switch (tx.type) {
      case CashTransactionType.abertura:
        icon = Icons.lock_open;
        color = Colors.blue;
        typeLabel = 'Abertura';
        break;
      case CashTransactionType.suprimento:
        icon = Icons.arrow_upward;
        color = AppColors.neonGreen;
        typeLabel = 'Reforço';
        break;
      case CashTransactionType.sangria:
        icon = Icons.arrow_downward;
        color = AppColors.danger;
        typeLabel = 'Sangria';
        break;
      case CashTransactionType.venda:
        icon = Icons.shopping_cart;
        color = Colors.blue;
        typeLabel = 'Venda';
        break;
      case CashTransactionType.fechamento:
        icon = Icons.lock;
        color = AppColors.textMuted;
        typeLabel = 'Fechamento';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      typeLabel,
                      style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      'R\$ ${tx.amount.toStringAsFixed(2)}',
                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        tx.reason,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      tx.user,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
