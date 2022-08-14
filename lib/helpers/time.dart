import 'package:intl/intl.dart';

toDateTime(String inputString) {
  final dateFormat = DateFormat('yyyy-MM-dd hh:mm:ss');

  return dateFormat.format(DateTime.parse(inputString));
}