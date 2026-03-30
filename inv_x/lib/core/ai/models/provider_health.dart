import 'package:inv_x/core/ai/providers/base_provider.dart';
import 'package:inv_x/core/ai/utils/circuit_breaker.dart';

class ProviderHealth {
  final String name;
  final ProviderTier tier;
  final bool isHealthy;
  final CircuitState circuitState;
  final int totalCalls;
  final double successRate;
  final double avgLatencyMs;
  final String? lastError;
  final DateTime? lastChecked;

  const ProviderHealth({
    required this.name,
    required this.tier,
    required this.isHealthy,
    required this.circuitState,
    this.totalCalls = 0,
    this.successRate = 0.0,
    this.avgLatencyMs = 0.0,
    this.lastError,
    this.lastChecked,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'tier': tier.name,
        'isHealthy': isHealthy,
        'circuitState': circuitState.name,
        'totalCalls': totalCalls,
        'successRate': successRate,
        'avgLatencyMs': avgLatencyMs,
        'lastError': lastError,
        'lastChecked': lastChecked?.toIso8601String(),
      };
}
