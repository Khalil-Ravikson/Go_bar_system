import 'package:flutter/material.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';

/// Diálogo de QR code para acesso ao cardápio digital da mesa.
class QrCodeDialog extends StatelessWidget {
  final String tableNumber;

  const QrCodeDialog({super.key, required this.tableNumber});

  static void show(BuildContext context, String tableNumber) {
    showDialog(
      context: context,
      builder: (_) => QrCodeDialog(tableNumber: tableNumber),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'QR Cardápio — Mesa $tableNumber',
        style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Escaneie o QR Code abaixo para acessar o cardápio digital desta mesa.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            width: 180,
            height: 180,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.neonGreen.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: CustomPaint(
              size: const Size(164, 164),
              painter: _QrCodeMockPainter(),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'gobar.app/cardapio/mesa$tableNumber',
            style: const TextStyle(
              color: AppColors.neonGreen,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
      actions: [
        Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'FECHAR',
              style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

class _QrCodeMockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.neonGreen;
    final bgPaint = Paint()..color = Colors.black87;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
    final pixelSize = size.width / 15;

    void drawFinder(double x, double y) {
      canvas.drawRect(Rect.fromLTWH(x, y, pixelSize * 5, pixelSize * 5), paint);
      canvas.drawRect(Rect.fromLTWH(x + pixelSize, y + pixelSize, pixelSize * 3, pixelSize * 3), bgPaint);
      canvas.drawRect(Rect.fromLTWH(x + pixelSize * 2, y + pixelSize * 2, pixelSize, pixelSize), paint);
    }

    drawFinder(0, 0);
    drawFinder(size.width - pixelSize * 5, 0);
    drawFinder(0, size.height - pixelSize * 5);

    for (var pix in [
      [2, 7], [3, 7], [4, 7], [7, 2], [7, 3], [7, 4],
      [10, 10], [10, 11], [10, 12], [11, 10], [12, 10],
      [8, 8], [9, 9], [6, 12], [12, 6], [14, 14], [13, 14],
      [8, 14], [14, 8], [7, 7], [7, 8], [8, 7], [9, 6], [6, 9]
    ]) {
      canvas.drawRect(
        Rect.fromLTWH(pix[0] * pixelSize, pix[1] * pixelSize, pixelSize, pixelSize),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
