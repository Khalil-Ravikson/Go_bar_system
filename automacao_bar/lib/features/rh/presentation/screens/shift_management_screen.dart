import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/shared/presentation/components/neon_button.dart';
import 'package:automacao_bar/features/rh/application/shift_provider.dart';
import 'package:automacao_bar/features/waste/application/waste_provider.dart';

class ShiftManagementScreen extends ConsumerStatefulWidget {
  const ShiftManagementScreen({super.key});

  @override
  ConsumerState<ShiftManagementScreen> createState() => _ShiftManagementScreenState();
}

class _ShiftManagementScreenState extends ConsumerState<ShiftManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _waiterNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _waiterNameController.dispose();
    super.dispose();
  }

  String _formatTime(int? timestamp) {
    if (timestamp == null) return '--:--';
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final shift = ref.watch(shiftProvider);
    final wastes = ref.watch(wasteProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: AppColors.surface,
            elevation: 0,
            flexibleSpace: const FlexibleSpaceBar(
              titlePadding: EdgeInsetsDirectional.only(start: 24, bottom: 52),
              title: Text(
                'RH & Turnos',
                style: TextStyle(
                  color: AppColors.textMain,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.neonGreen,
              labelColor: AppColors.neonGreen,
              unselectedLabelColor: AppColors.textMuted,
              tabs: const [
                Tab(icon: Icon(Icons.assignment_ind), text: 'Controle de Turnos'),
                Tab(icon: Icon(Icons.delete_sweep), text: 'Desperdício'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildShiftTab(shift),
            _buildWasteTab(wastes),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftTab(Shift shift) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Registro de Entrada & Comissão de Garçom',
            style: TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Faça clock-in antes de iniciar o atendimento para computar suas vendas e comissões.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 24),

          if (!shift.isActive) ...[
            // CLOCK-IN FORM
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceLight),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lock_clock, color: AppColors.neonGreen),
                        SizedBox(width: 12),
                        Text(
                          'Iniciar Novo Turno (Clock-In)',
                          style: TextStyle(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _waiterNameController,
                      style: const TextStyle(color: AppColors.textMain),
                      decoration: const InputDecoration(
                        labelText: 'Nome do Garçom / Operador',
                        labelStyle: TextStyle(color: AppColors.textMuted),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceLight)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neonGreen)),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Insira seu nome' : null,
                    ),
                    const SizedBox(height: 32),
                    NeonButton(
                      text: 'INICIAR TURNO',
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          ref.read(shiftProvider.notifier).clockIn(_waiterNameController.text);
                          _waiterNameController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // ACTIVE SHIFT PANEL
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.3), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: AppColors.neonGreen,
                            child: Icon(Icons.person, color: Colors.black),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shift.waiterName ?? '',
                                style: const TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              const Text('Garçom Ativo', style: TextStyle(color: AppColors.neonGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.neonGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.neonGreen),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.timer_outlined, color: AppColors.neonGreen, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              'Entrada: ${_formatTime(shift.startTime)}',
                              style: const TextStyle(color: AppColors.neonGreen, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Divider(color: AppColors.surfaceLight),
                  const SizedBox(height: 24),

                  // Stats grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildShiftStat(
                          title: 'VENDAS DO TURNO',
                          value: 'R\$ ${shift.totalSales.toStringAsFixed(2)}',
                          icon: Icons.payments,
                          color: AppColors.neonGreen,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildShiftStat(
                          title: 'GORJETAS ESTIMADAS (10%)',
                          value: 'R\$ ${shift.tipsEarned.toStringAsFixed(2)}',
                          icon: Icons.monetization_on,
                          color: Colors.cyanAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Clock out button
                  ElevatedButton(
                    onPressed: () => _confirmClockOut(shift),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      'FINALIZAR TURNO (CLOCK-OUT)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShiftStat({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: AppColors.textMuted, fontSize: 10, letterSpacing: 0.8)),
              Icon(icon, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  void _confirmClockOut(Shift shift) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Resumo de Fechamento de Turno', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Colaborador: ${shift.waiterName}', style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Vendas Acumuladas: R\$ ${shift.totalSales.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 6),
            Text('Gorjeta Calculada (10%): R\$ ${shift.tipsEarned.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text(
              'Confirmar encerramento e liberação de gaveta?',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCELAR', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              ref.read(shiftProvider.notifier).clockOut();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Turno finalizado e relatório arquivado com sucesso!'),
                  backgroundColor: AppColors.neonGreen,
                ),
              );
            },
            child: const Text('CLOCK-OUT', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildWasteTab(List<WasteItem> wastes) {
    // Calculate total values
    final double totalWasteCount = wastes.fold(0.0, (sum, w) => sum + w.quantity);
    // Approximate financial loss (mocked at R$ 30 per burger/portion)
    final double totalEstimatedLoss = wastes.fold(0.0, (sum, w) => sum + (w.quantity * 25.0));

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Registro de Quebras & Desperdício de Cozinha',
                    style: TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Listagem de cancelamentos enviados à cozinha classificados como desperdício.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'R\$ ${totalEstimatedLoss.toStringAsFixed(2)}',
                    style: const TextStyle(color: AppColors.danger, fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  Text('${totalWasteCount.toInt()} itens | Prejuízo Est.', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: wastes.isEmpty
                ? const Center(
                    child: Text('Nenhum desperdício registrado hoje.', style: TextStyle(color: AppColors.textMuted)),
                  )
                : ListView.separated(
                    itemCount: wastes.length,
                    separatorBuilder: (context, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final w = wastes[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.danger.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.danger.withValues(alpha: 0.15),
                                  child: const Icon(Icons.delete_outline, color: AppColors.danger),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${w.quantity.toInt()}x ${w.productName}',
                                      style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Motivo: ${w.reason}',
                                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Text(
                              _formatDateTime(w.reportedAt),
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
