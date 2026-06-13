import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/features/dashboard/application/dashboard_provider.dart';
import 'package:automacao_bar/features/dashboard/application/reports_provider.dart';
import 'package:automacao_bar/features/rh/application/shift_provider.dart';
import 'package:automacao_bar/features/waste/application/waste_provider.dart';

class FinancialReportsScreen extends ConsumerStatefulWidget {
  const FinancialReportsScreen({super.key});

  @override
  ConsumerState<FinancialReportsScreen> createState() => _FinancialReportsScreenState();
}

class _FinancialReportsScreenState extends ConsumerState<FinancialReportsScreen> {
  bool _isExporting = false;

  Future<void> _handlePdfExport() async {
    setState(() => _isExporting = true);
    try {
      await ref.read(reportsProvider).exportDailyReportPdf();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Relatório PDF exportado com sucesso!'),
            backgroundColor: AppColors.neonGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao exportar PDF: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = ref.watch(dashboardProvider);
    final shift = ref.watch(shiftProvider);
    final wastes = ref.watch(wasteProvider);

    final double totalWasteLoss = wastes.fold(0.0, (sum, w) => sum + (w.quantity * 25.0));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Auditoria & Relatórios Contábeis', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Demonstração do Resultado Operacional',
                style: TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Audite faturamento bruto, custos com comissões de garçom e perdas por desperdício.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 24),

              // Summary metric cards
              _buildMetricCard(
                title: 'FATURAMENTO DO DIA',
                value: 'R\$ ${dashboard.totalToday.toStringAsFixed(2)}',
                subtitle: 'Meta: R\$ ${dashboard.dailyGoal.toStringAsFixed(2)}',
                icon: Icons.payments,
                color: AppColors.neonGreen,
              ),
              const SizedBox(height: 16),

              _buildMetricCard(
                title: 'COMISSÕES DE GORJETA',
                value: 'R\$ ${shift.tipsEarned.toStringAsFixed(2)}',
                subtitle: shift.isActive ? 'Garçom: ${shift.waiterName}' : 'Turno Encerrado',
                icon: Icons.monetization_on,
                color: AppColors.orange,
              ),
              const SizedBox(height: 16),

              _buildMetricCard(
                title: 'PREJUÍZO POR QUEBRAS',
                value: 'R\$ ${totalWasteLoss.toStringAsFixed(2)}',
                subtitle: '${wastes.length} incidentes hoje',
                icon: Icons.delete_sweep,
                color: AppColors.danger,
              ),
              const SizedBox(height: 32),

              // Export PDF Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonGreen,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _isExporting 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)) 
                      : const Icon(Icons.picture_as_pdf),
                  label: Text(
                    _isExporting ? 'GERANDO DOCUMENTO...' : 'EXPORTAR FECHO DE CAIXA (PDF)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  onPressed: _isExporting ? null : _handlePdfExport,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            radius: 24,
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(color: AppColors.textMain, fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
