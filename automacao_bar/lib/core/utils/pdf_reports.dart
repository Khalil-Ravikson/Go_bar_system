import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:automacao_bar/core/database/app_database.dart';
import 'package:automacao_bar/core/database/daos/inventory_dao.dart';

class PdfReports {
  static Future<Uint8List> generateInventoryReport({
    required List<ProductBalance> productBalances,
    required List<StockItem> stockItems,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('PROMULTI - RELATORIO DE ESTOQUE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                pw.Text(DateTime.now().toLocal().toString().substring(0, 16), style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text('Estoque de Produtos de Venda', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headers: ['Produto', 'Categoria', 'Saldo Atual', 'Estoque Min', 'Status'],
            data: productBalances.map((pb) {
              final isLow = pb.isLowStock;
              return [
                pb.product.name,
                pb.categoryName ?? 'Sem categoria',
                pb.balance.toStringAsFixed(1),
                pb.product.minStock.toStringAsFixed(0),
                isLow ? 'CRITICO' : 'NORMAL',
              ];
            }).toList(),
            border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
          ),
          pw.SizedBox(height: 30),
          pw.Text('Estoque de Insumos / Materia-Prima', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headers: ['Insumo', 'Unidade', 'Qtd Atual', 'Preco Custo', 'Valor Total', 'Alerta Qtd'],
            data: stockItems.map((item) {
              final totalCost = item.quantity * item.costPrice;
              return [
                item.name,
                item.unit,
                item.quantity.toStringAsFixed(2),
                'R\$ ${item.costPrice.toStringAsFixed(2)}',
                'R\$ ${totalCost.toStringAsFixed(2)}',
                item.alertMinQty.toStringAsFixed(1),
              ];
            }).toList(),
            border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generateClosingReport({
    required double revenueToday,
    required int orderCountToday,
    required Map<String, double> revenueByMethod,
    required List<Map<String, dynamic>> topProducts,
    required List<WasteRecord> wasteRecords,
    required List<StockItem> stockItems,
  }) async {
    final pdf = pw.Document();

    final avgTicket = orderCountToday > 0 ? revenueToday / orderCountToday : 0.0;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('PROMULTI - FECHAMENTO DIARIO DE CAIXA', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                pw.Text(DateTime.now().toLocal().toString().substring(0, 10), style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('FATURAMENTO TOTAL', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                  pw.Text('R\$ ${revenueToday.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.green)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('TOTAL DE COMANDAS', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                  pw.Text('$orderCountToday', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('TICKET MEDIO', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                  pw.Text('R\$ ${avgTicket.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 30),
          pw.Text('Receita por Metodo de Pagamento', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headers: ['Metodo', 'Valor Faturado'],
            data: revenueByMethod.entries.map((e) {
              return [
                e.key.toUpperCase(),
                'R\$ ${e.value.toStringAsFixed(2)}',
              ];
            }).toList(),
            border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
          ),
          pw.SizedBox(height: 30),
          pw.Text('Mais Vendidos do Dia', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headers: ['Produto', 'Quantidade', 'Faturamento'],
            data: topProducts.map((p) {
              return [
                p['name']?.toString() ?? '',
                p['qty']?.toString() ?? '0',
                'R\$ ${(p['total'] as double? ?? 0.0).toStringAsFixed(2)}',
              ];
            }).toList(),
            border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
          ),
          if (wasteRecords.isNotEmpty) ...[
            pw.SizedBox(height: 30),
            pw.Text('Desperdicios de Insumos Registrados', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              headers: ['Insumo', 'Quantidade', 'Motivo', 'Custo Perda'],
              data: wasteRecords.map((w) {
                final item = stockItems.firstWhere((s) => s.id == w.stockItemId, orElse: () => StockItem(id: '', name: 'Insumo Desconhecido', unit: '', quantity: 0, costPrice: 0, alertMinQty: 0, updatedAt: 0));
                return [
                  item.name,
                  '${w.quantity.toStringAsFixed(2)} ${item.unit}',
                  w.reason.toUpperCase(),
                  'R\$ ${w.costLost.toStringAsFixed(2)}',
                ];
              }).toList(),
              border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
            ),
          ],
        ],
      ),
    );

    return pdf.save();
  }
}
