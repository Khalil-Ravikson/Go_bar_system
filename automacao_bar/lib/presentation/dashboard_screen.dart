import 'package:flutter/material.dart';
import 'theme/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos LayoutBuilder para ajustar as margens se estivermos num PC ou telemóvel
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;
        final padding = isDesktop ? 40.0 : 20.0;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildKPIs(isDesktop),
                  const SizedBox(height: 40),
                  Text(
                    'Caderno Digital (Últimos Registos)',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRecentLogs(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // 1. CABEÇALHO
  // ==========================================
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Visão Geral',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Sexta-feira, 22 de Maio', // Pode ser dinâmico depois (ex: DateFormat)
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(Icons.notifications_none, color: AppColors.primaryNeon),
        ),
      ],
    );
  }

  // ==========================================
  // 2. MÉTRICAS (KPIs) COM EFEITO NEON
  // ==========================================
  Widget _buildKPIs(bool isDesktop) {
    final kpiCards = [
      _buildKPICard('Faturação do Dia', 'R\$ 691,00', Icons.attach_money, isPrimary: true),
      _buildKPICard('Pedidos Abertos', '12', Icons.receipt_long),
      _buildKPICard('Ticket Médio', 'R\$ 57,50', Icons.analytics_outlined),
    ];

    if (isDesktop) {
      return Row(
        children: kpiCards.map((card) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 16.0), child: card))).toList(),
      );
    } else {
      return Column(
        children: kpiCards.map((card) => Padding(padding: const EdgeInsets.only(bottom: 16.0), child: card)).toList(),
      );
    }
  }

  Widget _buildKPICard(String title, String value, IconData icon, {bool isPrimary = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPrimary ? AppColors.primaryNeon.withOpacity(0.5) : AppColors.border,
          width: isPrimary ? 1.5 : 1.0,
        ),
        boxShadow: isPrimary
            ? [BoxShadow(color: AppColors.primaryNeon.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 4))]
            : [],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPrimary ? AppColors.primaryNeon.withOpacity(0.1) : AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: isPrimary ? AppColors.primaryNeon : AppColors.textSecondary, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: isPrimary ? AppColors.primaryNeon : AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. O "CADERNO" DIGITAL (Logs)
  // ==========================================
  Widget _buildRecentLogs() {
    // Dados mockados baseados no caderno real
    final logs = [
      {'time': '22:15', 'desc': '1 Churrasco Carne + 1 Refri (Mesa 5)', 'value': 'R\$ 27,00', 'type': 'PIX'},
      {'time': '21:52', 'desc': '2 Hamburgueres + 1 Hot-Dog (Mesa 2)', 'value': 'R\$ 53,00', 'type': 'Crédito'},
      {'time': '21:30', 'desc': '3 Churrasco Carne (Retirada)', 'value': 'R\$ 66,00', 'type': 'Dinheiro'},
      {'time': '21:05', 'desc': '1 Churrasco Misto (Alana)', 'value': 'R\$ 22,00', 'type': 'Débito'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: logs.length,
        separatorBuilder: (context, index) => const Divider(color: AppColors.border, height: 1),
        itemBuilder: (context, index) {
          final log = logs[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Text(
              log['time']!,
              style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
            ),
            title: Text(log['desc']!, style: const TextStyle(color: AppColors.textPrimary)),
            subtitle: Text('Pagamento: ${log['type']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            trailing: Text(
              log['value']!,
              style: const TextStyle(color: AppColors.primaryNeon, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          );
        },
      ),
    );
  }
}