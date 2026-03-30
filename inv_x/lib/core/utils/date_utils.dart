import 'package:intl/intl.dart';

/// Date formatting helpers used throughout the INV-X app.
class AppDateUtils {
  AppDateUtils._();

  // ── Formatters ──────────────────────────────────────────────────────────

  static final _dayMonthYear = DateFormat('dd MMM yyyy');
  static final _dayMonthYearTime = DateFormat('dd MMM yyyy, hh:mm a');
  static final _shortDate = DateFormat('dd/MM/yy');
  static final _monthYear = DateFormat('MMM yyyy');
  static final _time = DateFormat('hh:mm a');
  static final _iso = DateFormat('yyyy-MM-dd');
  static final _dayMonth = DateFormat('dd MMM');
  static final _weekday = DateFormat('EEEE');
  static final _shortWeekday = DateFormat('EEE');

  // ── Format helpers ──────────────────────────────────────────────────────

  /// "25 Mar 2026"
  static String formatDate(DateTime date) => _dayMonthYear.format(date);

  /// "25 Mar 2026, 02:30 PM"
  static String formatDateTime(DateTime date) =>
      _dayMonthYearTime.format(date);

  /// "25/03/26"
  static String formatShortDate(DateTime date) => _shortDate.format(date);

  /// "Mar 2026"
  static String formatMonthYear(DateTime date) => _monthYear.format(date);

  /// "02:30 PM"
  static String formatTime(DateTime date) => _time.format(date);

  /// "2026-03-25"
  static String formatIso(DateTime date) => _iso.format(date);

  /// "25 Mar"
  static String formatDayMonth(DateTime date) => _dayMonth.format(date);

  /// "Monday"
  static String formatWeekday(DateTime date) => _weekday.format(date);

  /// "Mon"
  static String formatShortWeekday(DateTime date) =>
      _shortWeekday.format(date);

  // ── Relative time ───────────────────────────────────────────────────────

  /// Returns a human-friendly relative string: "Just now", "5m ago",
  /// "3h ago", "Yesterday", "3 days ago", or falls back to [formatDate].
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.isNegative) return formatDate(date);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    return formatDate(date);
  }

  /// Returns a string like "Expires in 3 days" or "Expired 2 days ago".
  static String expiryLabel(DateTime expiryDate) {
    final now = DateTime.now();
    final diff = expiryDate.difference(now);

    if (diff.isNegative) {
      final daysAgo = diff.inDays.abs();
      return daysAgo == 0 ? 'Expired today' : 'Expired $daysAgo days ago';
    }
    if (diff.inDays == 0) return 'Expires today';
    if (diff.inDays == 1) return 'Expires tomorrow';
    return 'Expires in ${diff.inDays} days';
  }

  // ── Day helpers ─────────────────────────────────────────────────────────

  /// True when [date] falls on Saturday or Sunday.
  static bool isWeekend(DateTime date) =>
      date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

  /// Start of the day (midnight).
  static DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// End of the day (23:59:59.999).
  static DateTime endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

  /// Number of full days between two dates (ignoring time component).
  static int daysBetween(DateTime a, DateTime b) =>
      startOfDay(b).difference(startOfDay(a)).inDays;

  /// Returns a list of [DateTime]s from [start] to [end] (inclusive).
  static List<DateTime> dateRange(DateTime start, DateTime end) {
    final days = <DateTime>[];
    var current = startOfDay(start);
    final last = startOfDay(end);
    while (!current.isAfter(last)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }
    return days;
  }

  /// Generates a date [daysFromNow] days in the future (positive) or
  /// past (negative) relative to now.
  static DateTime daysFromNow(int days) =>
      DateTime.now().add(Duration(days: days));
}
