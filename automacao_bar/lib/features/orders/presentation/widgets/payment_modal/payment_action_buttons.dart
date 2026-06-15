import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/features/crm/application/customers_provider.dart';

class PaymentActionButtons extends StatelessWidget {
  final double totalToPay;
  final List<Map<String, dynamic>> itemsPaid;
  final Customer? selectedCustomer;
  final void Function(double, String, List<Map<String, dynamic>>) onConfirm;

  const PaymentActionButtons({
    super.key,
    required this.totalToPay,
    required this.itemsPaid,
    required this.selectedCustomer,
    required this.onConfirm,
  });

  void _showPixDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            'PAGAMENTO VIA PIX',
            style: GoogleFonts.shareTechMono(color: AppColors.textMain, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 160,
                height: 160,
                color: Colors.white,
                padding: const EdgeInsets.all(8),
                child: CustomPaint(
                  painter: _PixQrCodePainter(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Escaneie o QR Code acima ou copie a chave Pix abaixo:',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'pix@promulti.com.br',
                        style: TextStyle(color: AppColors.textMain, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 16, color: AppColors.neonGreen),
                      onPressed: () {
                        Clipboard.setData(const ClipboardData(text: 'pix@promulti.com.br'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Chave PIX copiada!'), backgroundColor: AppColors.neonGreen),
                        );
                      },
                    ),
                  ],
                ),
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
                Navigator.of(context).pop();
                onConfirm(totalToPay, 'PIX', itemsPaid);
              },
              child: const Text('CONFIRMAR RECEBIMENTO', style: TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showFiadoDialog(BuildContext context) {
    final nameController = TextEditingController(text: selectedCustomer?.name ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            'REGISTRAR FIADO / PENDENTE',
            style: GoogleFonts.shareTechMono(color: AppColors.neonRed, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Esta conta será marcada como não paga (inadimplente) e o valor será associado ao cliente abaixo.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                style: const TextStyle(color: AppColors.textMain),
                decoration: const InputDecoration(
                  labelText: 'Nome do Cliente',
                  labelStyle: TextStyle(color: AppColors.textMuted),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceLight)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neonRed)),
                ),
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
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                
                Navigator.of(context).pop();
                onConfirm(totalToPay, 'Fiado:$name', itemsPaid);
              },
              child: const Text('CONFIRMAR FIADO', style: TextStyle(color: AppColors.neonRed, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool disabled = totalToPay <= 0.01;

    return Row(
      children: [
        _btn(
          icon: Icons.pix,
          label: 'PIX',
          onTap: disabled ? null : () => _showPixDialog(context),
        ),
        const SizedBox(width: 8),
        _btn(
          icon: Icons.credit_card,
          label: 'Cartão',
          onTap: disabled ? null : () => onConfirm(totalToPay, 'Cartão', itemsPaid),
        ),
        const SizedBox(width: 8),
        _btn(
          icon: Icons.payments_outlined,
          label: 'Dinheiro',
          onTap: disabled ? null : () => onConfirm(totalToPay, 'Dinheiro', itemsPaid),
        ),
        const SizedBox(width: 8),
        _btn(
          icon: Icons.assignment_late_outlined,
          label: 'Fiado',
          onTap: disabled ? null : () => _showFiadoDialog(context),
        ),
      ],
    );
  }

  Widget _btn({required IconData icon, required String label, required VoidCallback? onTap}) {
    final bool blocked = onTap == null;
    return Expanded(
      child: Opacity(
        opacity: blocked ? 0.4 : 1.0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: blocked ? Colors.transparent : AppColors.neonGreen.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(icon, color: blocked ? AppColors.textMuted : AppColors.neonGreen, size: 22),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: blocked ? AppColors.textMuted : AppColors.textMain,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PixQrCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    
    // Draw three finder patterns (corners)
    _drawFinderPattern(canvas, 0, 0, 40);
    _drawFinderPattern(canvas, size.width - 40, 0, 40);
    _drawFinderPattern(canvas, 0, size.height - 40, 40);

    // Draw checker blocks
    final double cellSize = size.width / 20;
    for (var x = 0; x < 20; x++) {
      for (var y = 0; y < 20; y++) {
        if ((x < 7 && y < 7) || (x > 12 && y < 7) || (x < 7 && y > 12)) continue;
        if ((x * 3 + y * 7) % 5 == 0 || (x * y) % 3 == 0) {
          canvas.drawRect(Rect.fromLTWH(x * cellSize, y * cellSize, cellSize, cellSize), paint);
        }
      }
    }
  }

  void _drawFinderPattern(Canvas canvas, double x, double y, double size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(Rect.fromLTWH(x, y, size, size), paint);
    
    paint.color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(x + 5, y + 5, size - 10, size - 10), paint);
    
    paint.color = Colors.black;
    canvas.drawRect(Rect.fromLTWH(x + 10, y + 10, size - 20, size - 20), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
