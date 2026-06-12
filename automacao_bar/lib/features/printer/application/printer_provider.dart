import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PaperWidth {
  width58mm,
  width80mm,
}

class PrinterState {
  final String? selectedPrinter;
  final PaperWidth paperWidth;
  final List<String> availablePrinters;
  final bool isScanning;

  const PrinterState({
    this.selectedPrinter,
    required this.paperWidth,
    required this.availablePrinters,
    required this.isScanning,
  });

  PrinterState copyWith({
    String? selectedPrinter,
    PaperWidth? paperWidth,
    List<String>? availablePrinters,
    bool? isScanning,
  }) {
    return PrinterState(
      selectedPrinter: selectedPrinter ?? this.selectedPrinter,
      paperWidth: paperWidth ?? this.paperWidth,
      availablePrinters: availablePrinters ?? this.availablePrinters,
      isScanning: isScanning ?? this.isScanning,
    );
  }
}

class PrinterNotifier extends Notifier<PrinterState> {
  @override
  PrinterState build() {
    return const PrinterState(
      selectedPrinter: 'Termica-Caixa-80mm (Bluetooth)',
      paperWidth: PaperWidth.width80mm,
      availablePrinters: [
        'Termica-Caixa-80mm (Bluetooth)',
        'Termica-Cozinha-58mm (Bluetooth)',
        'Impressora-Bar-80mm',
      ],
      isScanning: false,
    );
  }

  Future<void> scanPrinters() async {
    if (state.isScanning) return;
    
    state = state.copyWith(isScanning: true);
    
    // Simulate Bluetooth scanning latency
    await Future.delayed(const Duration(milliseconds: 1500));
    
    state = state.copyWith(
      isScanning: false,
      availablePrinters: [
        'Termica-Caixa-80mm (Bluetooth)',
        'Termica-Cozinha-58mm (Bluetooth)',
        'Impressora-Bar-80mm',
        'MPT-III 80mm Printer',
        'GoBar-Virtual-58mm',
      ],
    );
  }

  void connectPrinter(String name) {
    state = state.copyWith(selectedPrinter: name);
  }

  void setPaperWidth(PaperWidth width) {
    state = state.copyWith(paperWidth: width);
  }
}

final printerProvider = NotifierProvider<PrinterNotifier, PrinterState>(() {
  return PrinterNotifier();
});
