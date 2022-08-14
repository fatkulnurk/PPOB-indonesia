import 'package:intl/intl.dart';

toRupiah(dynamic number) {
  NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  return currencyFormatter.format(number);
}