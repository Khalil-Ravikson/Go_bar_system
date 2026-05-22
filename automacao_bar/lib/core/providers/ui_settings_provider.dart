import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// Definimos os tamanhos possíveis (quanto menor o valor, mais denso/pequeno o card)
final gridItemSizeProvider = StateProvider<double>((ref) => 2.5); // 1.5 é o tamanho atual

// Função para alterar o tamanho
void updateGridSize(WidgetRef ref, double newSize) {
  ref.read(gridItemSizeProvider.notifier).state = newSize;
}