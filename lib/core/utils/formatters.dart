import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

/// Formatting helpers shared across screens.
class Formatters {
  Formatters._();

  /// Format [amount] as currency for the given ISO code.
  static String currency(num amount, {String? code, int decimals = 2}) {
    final c = code ?? AppConstants.defaultCurrencyCode;
    final symbol = _symbolFor(c);
    final fmt = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimals,
    );
    return fmt.format(amount);
  }

  /// Compact representation: 1.2K, 3.4M.
  static String compactCurrency(num amount, {String? code}) {
    final c = code ?? AppConstants.defaultCurrencyCode;
    final symbol = _symbolFor(c);
    final fmt = NumberFormat.compactCurrency(symbol: symbol, decimalDigits: 1);
    return fmt.format(amount);
  }

  static String _symbolFor(String code) {
    return kSupportedCurrencies
        .firstWhere(
          (c) => c.code == code,
          orElse: () => kSupportedCurrencies.first,
        )
        .symbol;
  }

  /// Short date like 'Mar 5, 2026'.
  static String date(DateTime date) => DateFormat.yMMMd().format(date);

  /// Day + time like 'Mar 5, 14:30'.
  static String dateTime(DateTime date) =>
      DateFormat('MMM d, HH:mm').format(date);

  /// Friendly relative label: Today, Yesterday, or 'Mar 5'.
  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return DateFormat('EEEE').format(date);
    return DateFormat.MMMd().format(date);
  }

  /// Month and year like 'March 2026'.
  static String monthYear(DateTime date) => DateFormat.yMMMM().format(date);
}
