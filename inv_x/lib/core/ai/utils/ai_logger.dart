import 'package:hive/hive.dart';

class AILogger {
  static const String _boxName = 'ai_logs';
  static const int _maxLogAge = 30; // days

  Box? _box;

  Future<void> initialize() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox(_boxName);
    } else {
      _box = Hive.box(_boxName);
    }
  }

  /// Logs a single AI call with all relevant metadata.
  Future<void> logCall({
    required String provider,
    required String tier,
    required bool success,
    required int latencyMs,
    required double cost,
    required int tokensUsed,
    String? model,
    String? error,
    String? requestType,
    int fallbacksAttempted = 0,
    List<String> failedProviders = const [],
  }) async {
    final entry = {
      'timestamp': DateTime.now().toIso8601String(),
      'provider': provider,
      'tier': tier,
      'success': success,
      'latencyMs': latencyMs,
      'cost': cost,
      'tokensUsed': tokensUsed,
      'model': model,
      'error': error,
      'requestType': requestType,
      'fallbacksAttempted': fallbacksAttempted,
      'failedProviders': failedProviders,
    };

    await _box?.add(entry);
  }

  /// Returns the N most recent log entries.
  List<Map<String, dynamic>> getRecentLogs({int limit = 50}) {
    if (_box == null || _box!.isEmpty) return [];

    final total = _box!.length;
    final start = total > limit ? total - limit : 0;
    final logs = <Map<String, dynamic>>[];

    for (int i = total - 1; i >= start; i--) {
      final raw = _box!.getAt(i);
      if (raw != null) {
        logs.add(Map<String, dynamic>.from(raw as Map));
      }
    }

    return logs;
  }

  /// Removes log entries older than [_maxLogAge] days.
  Future<int> cleanOldLogs() async {
    if (_box == null || _box!.isEmpty) return 0;

    final cutoff =
        DateTime.now().subtract(const Duration(days: _maxLogAge));
    final keysToDelete = <dynamic>[];

    for (int i = 0; i < _box!.length; i++) {
      final raw = _box!.getAt(i);
      if (raw == null) continue;
      final entry = Map<String, dynamic>.from(raw as Map);
      final ts = DateTime.tryParse(entry['timestamp'] as String? ?? '');
      if (ts != null && ts.isBefore(cutoff)) {
        keysToDelete.add(_box!.keyAt(i));
      }
    }

    for (final key in keysToDelete) {
      await _box!.delete(key);
    }

    if (keysToDelete.length > 50) {
      await _box!.compact();
    }

    return keysToDelete.length;
  }

  /// Returns usage analytics derived from logs.
  Map<String, dynamic> getUsageAnalytics() {
    final logs = getRecentLogs(limit: 1000);
    if (logs.isEmpty) {
      return {
        'totalCalls': 0,
        'successRate': 0.0,
        'avgLatencyMs': 0.0,
        'providerBreakdown': <String, int>{},
        'tierBreakdown': <String, int>{},
      };
    }

    int totalCalls = logs.length;
    int successCount = 0;
    double totalLatency = 0;
    final providerCounts = <String, int>{};
    final tierCounts = <String, int>{};

    for (final log in logs) {
      if (log['success'] == true) successCount++;
      totalLatency += (log['latencyMs'] as num?)?.toDouble() ?? 0;
      final p = log['provider'] as String? ?? 'unknown';
      providerCounts[p] = (providerCounts[p] ?? 0) + 1;
      final t = log['tier'] as String? ?? 'unknown';
      tierCounts[t] = (tierCounts[t] ?? 0) + 1;
    }

    return {
      'totalCalls': totalCalls,
      'successRate':
          totalCalls > 0 ? (successCount / totalCalls) * 100 : 0.0,
      'avgLatencyMs': totalCalls > 0 ? totalLatency / totalCalls : 0.0,
      'providerBreakdown': providerCounts,
      'tierBreakdown': tierCounts,
    };
  }
}
