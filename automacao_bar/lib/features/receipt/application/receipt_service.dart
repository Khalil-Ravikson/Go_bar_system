import 'package:url_launcher/url_launcher.dart';

class ReceiptService {
  static String formatReceiptText({
    required String tableNumber,
    required List<Map<String, dynamic>> preparingItems,
    required List<Map<String, dynamic>> deliveredItems,
    required double subtotal,
    required double serviceTax,
    required double total,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('🍻 *GOBAR SYSTEM - RECIBO DIGITAL* 🍻');
    buffer.writeln('------------------------------------');
    buffer.writeln('Mesa: $tableNumber');
    buffer.writeln('Data: ${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')} às ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}');
    buffer.writeln('------------------------------------');
    
    // Add items
    final allItems = [...preparingItems, ...deliveredItems];
    for (var item in allItems) {
      final name = item['name'] as String;
      final qty = item['quantity'] as int;
      final price = item['price'] as double;
      final totalItem = qty * price;
      buffer.writeln('${qty}x $name - R\$ ${totalItem.toStringAsFixed(2)}');
    }
    
    buffer.writeln('------------------------------------');
    buffer.writeln('Subtotal: R\$ ${subtotal.toStringAsFixed(2)}');
    buffer.writeln('Taxa de Serviço (10%): R\$ ${serviceTax.toStringAsFixed(2)}');
    buffer.writeln('*TOTAL: R\$ ${total.toStringAsFixed(2)}*');
    buffer.writeln('------------------------------------');
    buffer.writeln('Obrigado pela preferência! Volte sempre! 👋');
    
    return buffer.toString();
  }

  static Future<void> shareToWhatsApp({
    required String phone,
    required String text,
  }) async {
    // Sanitize phone number to keep only digits
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    
    // If no phone is supplied, open general WhatsApp chat text share
    final urlString = cleanPhone.isEmpty
        ? 'https://api.whatsapp.com/send?text=${Uri.encodeComponent(text)}'
        : 'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(text)}';
        
    final url = Uri.parse(urlString);
    
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      // Log errors safely
    }
  }
}
