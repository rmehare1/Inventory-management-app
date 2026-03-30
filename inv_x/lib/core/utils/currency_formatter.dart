import 'package:intl/intl.dart';

/// Indian currency formatting with lakhs / crores notation.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final _indianFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '\u20B9', // ₹
    decimalDigits: 2,
  );

  static final _indianFormatCompact = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '\u20B9',
    decimalDigits: 0,
  );

  // ── Standard formatting ─────────────────────────────────────────────────

  /// "₹1,25,000.00"
  static String format(double amount) => _indianFormat.format(amount);

  /// "₹1,25,000"  (no decimals)
  static String formatRounded(double amount) =>
      _indianFormatCompact.format(amount);

  // ── Compact (lakhs / crores) ────────────────────────────────────────────

  /// Returns human-friendly Indian notation:
  ///   - < 1,000        → "₹999"
  ///   - < 1,00,000     → "₹45.2K"
  ///   - < 1,00,00,000  → "₹12.5L"
  ///   - >= 1,00,00,000 → "₹3.4Cr"
  static String formatCompact(double amount) {
    final abs = amount.abs();
    final sign = amount < 0 ? '-' : '';

    if (abs < 1000) {
      return '$sign\u20B9${abs.toStringAsFixed(abs == abs.roundToDouble() ? 0 : 2)}';
    } else if (abs < 100000) {
      // Thousands
      final val = abs / 1000;
      return '$sign\u20B9${_trimTrailingZeros(val.toStringAsFixed(1))}K';
    } else if (abs < 10000000) {
      // Lakhs
      final val = abs / 100000;
      return '$sign\u20B9${_trimTrailingZeros(val.toStringAsFixed(1))}L';
    } else {
      // Crores
      final val = abs / 10000000;
      return '$sign\u20B9${_trimTrailingZeros(val.toStringAsFixed(1))}Cr';
    }
  }

  /// Parses a formatted string back to a double.
  /// Handles "₹", commas, "K", "L", "Cr" suffixes.
  static double? tryParse(String text) {
    var cleaned = text.replaceAll('\u20B9', '').replaceAll(',', '').trim();

    double multiplier = 1;
    if (cleaned.endsWith('Cr')) {
      multiplier = 10000000;
      cleaned = cleaned.substring(0, cleaned.length - 2);
    } else if (cleaned.endsWith('L')) {
      multiplier = 100000;
      cleaned = cleaned.substring(0, cleaned.length - 1);
    } else if (cleaned.endsWith('K')) {
      multiplier = 1000;
      cleaned = cleaned.substring(0, cleaned.length - 1);
    }

    final value = double.tryParse(cleaned.trim());
    return value != null ? value * multiplier : null;
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  /// "12.0" → "12", "12.5" → "12.5"
  static String _trimTrailingZeros(String s) {
    if (!s.contains('.')) return s;
    var trimmed = s;
    while (trimmed.endsWith('0')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    if (trimmed.endsWith('.')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }

  /// Formats as a percentage string: "23.5%".
  static String formatPercent(double value, {int decimals = 1}) =>
      '${value.toStringAsFixed(decimals)}%';

  /// Formats the difference between two amounts: "+₹500" or "-₹1,200".
  static String formatDelta(double delta) {
    final prefix = delta >= 0 ? '+' : '';
    return '$prefix${format(delta)}';
  }
}
