import 'package:intl/intl.dart';

// ── DateTime Extensions ──────────────────────────────────────────────────────

extension DateTimeX on DateTime {
  /// Returns a human-readable relative time string.
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return '$m ${m == 1 ? 'minute' : 'minutes'} ago';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return '$h ${h == 1 ? 'hour' : 'hours'} ago';
    }
    if (diff.inDays < 7) {
      final d = diff.inDays;
      return '$d ${d == 1 ? 'day' : 'days'} ago';
    }
    if (diff.inDays < 30) {
      final w = (diff.inDays / 7).floor();
      return '$w ${w == 1 ? 'week' : 'weeks'} ago';
    }
    if (diff.inDays < 365) {
      final m = (diff.inDays / 30).floor();
      return '$m ${m == 1 ? 'month' : 'months'} ago';
    }
    final y = (diff.inDays / 365).floor();
    return '$y ${y == 1 ? 'year' : 'years'} ago';
  }

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return isAfter(startOfWeek.subtract(const Duration(days: 1)));
  }

  String get formatted => DateFormat('dd MMM yyyy').format(this);

  String get formattedWithTime => DateFormat('dd MMM yyyy, hh:mm a').format(this);

  String get shortDate => DateFormat('dd/MM/yy').format(this);

  String get timeOnly => DateFormat('hh:mm a').format(this);

  String get monthYear => DateFormat('MMM yyyy').format(this);

  String get dayMonth => DateFormat('dd MMM').format(this);
}

// ── String Extensions ────────────────────────────────────────────────────────

extension StringX on String {
  /// Capitalises the first letter.
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalises each word.
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((w) => w.capitalize).join(' ');
  }

  /// Returns initials (up to 2 characters).
  String get initials {
    if (isEmpty) return '';
    final words = trim().split(RegExp(r'\s+'));
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  /// Truncates with ellipsis.
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}…';
  }

  /// Check if string is a valid email.
  bool get isValidEmail =>
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
          .hasMatch(this);

  /// Check if string is numeric.
  bool get isNumeric => double.tryParse(this) != null;
}

// ── num Extensions ───────────────────────────────────────────────────────────

extension NumX on num {
  /// Formats as Indian currency: ₹1,23,456.00
  String get currencyFormat {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );
    return formatter.format(this);
  }

  /// Compact format: 1.2K, 3.5M, etc.
  String get compact {
    if (this >= 10000000) return '${(this / 10000000).toStringAsFixed(1)}Cr';
    if (this >= 100000) return '${(this / 100000).toStringAsFixed(1)}L';
    if (this >= 1000) return '${(this / 1000).toStringAsFixed(1)}K';
    return toStringAsFixed(this == toInt() ? 0 : 1);
  }

  /// Formats as percentage.
  String get percentFormat => '${toStringAsFixed(1)}%';

  /// Formats with commas.
  String get commaFormat => NumberFormat('#,##,###').format(this);
}

// ── List Extensions ──────────────────────────────────────────────────────────

extension ListX<T> on List<T> {
  /// Returns the first element, or null if empty.
  T? get safeFirst => isEmpty ? null : first;

  /// Returns the last element, or null if empty.
  T? get safeLast => isEmpty ? null : last;

  /// Returns element at index, or null if out of bounds.
  T? safeElementAt(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
}

// ── Iterable Extensions ──────────────────────────────────────────────────────

extension IterableX<T> on Iterable<T> {
  /// Groups elements by a key.
  Map<K, List<T>> groupBy<K>(K Function(T) keyOf) {
    final map = <K, List<T>>{};
    for (final element in this) {
      final key = keyOf(element);
      (map[key] ??= []).add(element);
    }
    return map;
  }
}
