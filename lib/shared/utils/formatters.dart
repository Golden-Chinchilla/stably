import 'package:intl/intl.dart';

String formatCompactNumber(num? value, {String fallback = '—'}) {
  if (value == null) {
    return fallback;
  }

  return NumberFormat.compact().format(value);
}

String formatCurrency(
  num? value, {
  String symbol = '\$',
  String fallback = '—',
}) {
  if (value == null) {
    return fallback;
  }

  return '$symbol${NumberFormat.compact().format(value)}';
}

String formatPercent(
  num? value, {
  int fractionDigits = 2,
  String fallback = '—',
}) {
  if (value == null) {
    return fallback;
  }

  return '${value.toStringAsFixed(fractionDigits)}%';
}
