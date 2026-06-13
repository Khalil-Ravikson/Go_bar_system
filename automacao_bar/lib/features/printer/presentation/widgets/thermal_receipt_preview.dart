import 'package:flutter/material.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/features/printer/application/printer_provider.dart';

class ThermalReceiptPreview extends StatefulWidget {
  final String tableNumber;
  final List<Map<String, dynamic>> preparingItems;
  final List<Map<String, dynamic>> deliveredItems;
  final double subtotal;
  final double serviceTax;
  final double total;
  final PaperWidth paperWidth;

  const ThermalReceiptPreview({
    super.key,
    required this.tableNumber,
    required this.preparingItems,
    required this.deliveredItems,
    required this.subtotal,
    required this.serviceTax,
    required this.total,
    required this.paperWidth,
  });

  @override
  State<ThermalReceiptPreview> createState() => _ThermalReceiptPreviewState();
}

class _ThermalReceiptPreviewState extends State<ThermalReceiptPreview> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allItems = [...widget.preparingItems, ...widget.deliveredItems];
    final is80mm = widget.paperWidth == PaperWidth.width80mm;
    final paperWidthPx = is80mm ? 360.0 : 270.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Printer Slot simulation bar
          Container(
            width: paperWidthPx + 20,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: paperWidthPx,
                height: 3,
                color: Colors.black,
              ),
            ),
          ),

          // Animate receipt rolling out
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _slideAnimation.value,
                  child: child,
                ),
              );
            },
            child: Container(
              width: paperWidthPx,
              decoration: BoxDecoration(
                color: const Color(0xFFFAF9F5), // Off-white thermal paper
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(
                horizontal: is80mm ? 24 : 12,
                vertical: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Receipt Header
                  const Center(
                    child: Text(
                      '*** GoBar System ***',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      'ECOSISTEMA DE AUTOMAÇÃO',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: Colors.black,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Text(
                    'Mesa: Mesa ${widget.tableNumber}',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'Data: ${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year} ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: Colors.black,
                      fontSize: 11,
                    ),
                  ),
                  const Text(
                    '- - - - - - - - - - - - - - - - - -',
                    maxLines: 1,
                    style: TextStyle(fontFamily: 'monospace', color: Colors.black54),
                  ),

                  // Receipt Items
                  ...allItems.map((item) {
                    final name = item['name'] as String;
                    final qty = item['quantity'] as int;
                    final price = item['price'] as double;
                    final total = qty * price;
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${qty}x $name',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                color: Colors.black,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            'R\$ ${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const Text(
                    '- - - - - - - - - - - - - - - - - -',
                    maxLines: 1,
                    style: TextStyle(fontFamily: 'monospace', color: Colors.black54),
                  ),

                  // Totals
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Subtotal:',
                        style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 12),
                      ),
                      Text(
                        'R\$ ${widget.subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 12),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Taxa Servico (10%):',
                        style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 12),
                      ),
                      Text(
                        'R\$ ${widget.serviceTax.toStringAsFixed(2)}',
                        style: const TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL A PAGAR:',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'R\$ ${widget.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  
                  const Text(
                    '- - - - - - - - - - - - - - - - - -',
                    maxLines: 1,
                    style: TextStyle(fontFamily: 'monospace', color: Colors.black54),
                  ),
                  const SizedBox(height: 8),

                  // Simple Barcode Simulation
                  Center(
                    child: Container(
                      height: 40,
                      width: 180,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.black, width: 1),
                          bottom: BorderSide(color: Colors.black, width: 1),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(35, (index) {
                          return Container(
                            width: (index % 3 == 0 || index % 5 == 0) ? 3 : 1,
                            color: Colors.black,
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Center(
                    child: Text(
                      '3920194850381029',
                      style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'OBRIGADO PELA PREFERENCIA!',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Print Actions Overlay
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('OK, CONCLUÍDO', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
