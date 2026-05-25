class CurrencyFormatter {
  static String format(int priceInCents) {
    final value = priceInCents / 100;
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}