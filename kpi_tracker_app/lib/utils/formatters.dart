import 'package:intl/intl.dart';

/// Formats a value in Nepali Rupees using the NRs. lakh/crore-friendly
/// digit grouping the source workbook uses (e.g. NRs. 10,30,000).
class Formatters {
  Formatters._();

  static final NumberFormat _nepaliGrouping = NumberFormat('#,##,##0', 'en_IN');

  static String currency(num value) {
    return 'NRs. ${_nepaliGrouping.format(value.round())}';
  }

  static String number(num value) {
    return _nepaliGrouping.format(value.round());
  }

  static String percent(double fraction, {int decimals = 0}) {
    return '${(fraction * 100).toStringAsFixed(decimals)}%';
  }

  static String multiplier(double value, {int decimals = 1}) {
    return '${value.toStringAsFixed(decimals)}x';
  }
}
