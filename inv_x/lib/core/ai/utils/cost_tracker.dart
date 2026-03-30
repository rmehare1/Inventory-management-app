import 'package:hive/hive.dart';

class CostTracker {
  static const String _boxName = 'ai_costs';
  static const String _todayKey = 'cost_today';
  static const String _dateKey = 'cost_date';
  static const String _historyKey = 'cost_history';

  Box? _box;

  Future<void> initialize() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox(_boxName);
    } else {
      _box = Hive.box(_boxName);
    }
    _resetIfNewDay();
  }

  double get totalCostToday {
    _resetIfNewDay();
    return (_box?.get(_todayKey, defaultValue: 0.0) as num?)?.toDouble() ?? 0.0;
  }

  String get lastResetDate =>
      _box?.get(_dateKey, defaultValue: '') as String? ?? '';

  /// Records cost for a single request.
  Future<void> recordCost(double amount) async {
    _resetIfNewDay();
    final current = totalCostToday;
    await _box?.put(_todayKey, current + amount);
  }

  /// Returns true if spending another request is within the daily budget.
  bool canUsePaidProvider({double dailyLimit = 1.0}) {
    _resetIfNewDay();
    return totalCostToday < dailyLimit;
  }

  /// Returns cost analytics for display.
  Map<String, dynamic> getAnalytics() {
    _resetIfNewDay();
    final history = _getCostHistory();
    final totalAllTime =
        history.values.fold<double>(0.0, (sum, v) => sum + (v as double));
    return {
      'today': totalCostToday,
      'lastResetDate': lastResetDate,
      'totalAllTime': totalAllTime,
      'history': history,
      'daysTracked': history.length,
    };
  }

  // --- Private helpers ---

  void _resetIfNewDay() {
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final storedDate = _box?.get(_dateKey) as String?;

    if (storedDate != todayStr) {
      // Archive yesterday's cost into history.
      if (storedDate != null) {
        final history = _getCostHistory();
        final yesterdayCost =
            (_box?.get(_todayKey, defaultValue: 0.0) as num?)?.toDouble() ??
                0.0;
        if (yesterdayCost > 0) {
          history[storedDate] = yesterdayCost;
          // Keep 90 days of history.
          if (history.length > 90) {
            final sortedKeys = history.keys.toList()..sort();
            for (final key in sortedKeys.take(history.length - 90)) {
              history.remove(key);
            }
          }
          _box?.put(_historyKey, history);
        }
      }
      _box?.put(_todayKey, 0.0);
      _box?.put(_dateKey, todayStr);
    }
  }

  Map<String, dynamic> _getCostHistory() {
    final raw = _box?.get(_historyKey);
    if (raw == null) return {};
    return Map<String, dynamic>.from(raw as Map);
  }
}
