import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dashboard_provider.dart';
import '../../rh/application/shift_provider.dart';
import '../../waste/application/waste_provider.dart';
import '../../../services/pdf_helper.dart';

final reportsProvider = Provider((ref) {
  return ReportsService(ref);
});

class ReportsService {
  final Ref ref;
  ReportsService(this.ref);

  Future<void> exportDailyReportPdf() async {
    final dashboard = ref.read(dashboardProvider);
    final shift = ref.read(shiftProvider);
    final wastes = ref.read(wasteProvider);

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('GoBar System - Fechamento de Caixa', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                      pw.Text(DateTime.now().toLocal().toString().substring(0, 16), style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 24),
                
                // Resumo Financeiro
                pw.Text('Resumo Financeiro do Dia', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.Divider(),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Faturamento Total de Hoje:'),
                    pw.Text('R\$ ${dashboard.totalToday.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Meta Diária:'),
                    pw.Text('R\$ ${dashboard.dailyGoal.toStringAsFixed(2)}'),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Atingimento da Meta:'),
                    pw.Text('${((dashboard.totalToday / dashboard.dailyGoal) * 100).toStringAsFixed(1)}%'),
                  ],
                ),
                pw.SizedBox(height: 24),

                // RH / Gorjetas
                pw.Text('Relatório de Garçons & Gorjetas', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.Divider(),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Garçom Ativo:'),
                    pw.Text(shift.isActive ? (shift.waiterName ?? 'N/A') : 'Nenhum ativo'),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Gorjetas Acumuladas (10%):'),
                    pw.Text('R\$ ${shift.tipsEarned.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 24),

                // Desperdício / Quebras
                pw.Text('Registro de Quebras & Desperdício', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.Divider(),
                pw.SizedBox(height: 8),
                wastes.isEmpty
                    ? pw.Text('Nenhum desperdício registrado hoje.')
                    : pw.Column(
                        children: wastes.map((w) {
                          return pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(vertical: 2),
                            child: pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text('${w.quantity.toStringAsFixed(0)}x ${w.productName}'),
                                pw.Text('Motivo: ${w.reason}'),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                pw.Spacer(),
                pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text('GoBar System ERP - Omnichannel Solution', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                ),
              ],
            ),
          );
        },
      ),
    );

    final bytes = await pdf.save();
    await PdfHelper.saveAndOpenPdf(bytes, 'fecho_de_caixa.pdf');
  }
}
