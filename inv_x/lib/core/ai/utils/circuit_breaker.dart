enum CircuitState { closed, open, halfOpen }

class CircuitBreaker {
  final int failureThreshold;
  final Duration resetTimeout;

  int _failureCount = 0;
  CircuitState _state = CircuitState.closed;
  DateTime? _lastFailureTime;
  String? _lastError;
  int _totalCalls = 0;
  int _successCalls = 0;
  final List<int> _latencies = [];

  CircuitBreaker({
    this.failureThreshold = 3,
    this.resetTimeout = const Duration(minutes: 5),
  });

  CircuitState get state => _state;
  String? get lastError => _lastError;
  int get totalCalls => _totalCalls;

  double get successRate =>
      _totalCalls == 0 ? 0.0 : (_successCalls / _totalCalls) * 100;

  double get avgLatencyMs {
    if (_latencies.isEmpty) return 0.0;
    final sum = _latencies.fold<int>(0, (a, b) => a + b);
    return sum / _latencies.length;
  }

  /// Returns true if a request can be attempted through this breaker.
  bool canAttempt() {
    switch (_state) {
      case CircuitState.closed:
        return true;

      case CircuitState.open:
        // Check if enough time has passed to transition to half-open.
        if (_lastFailureTime != null &&
            DateTime.now().difference(_lastFailureTime!) >= resetTimeout) {
          _state = CircuitState.halfOpen;
          return true;
        }
        return false;

      case CircuitState.halfOpen:
        return true;
    }
  }

  /// Record a successful call — resets failure count, closes circuit.
  void recordSuccess({int latencyMs = 0}) {
    _totalCalls++;
    _successCalls++;
    _failureCount = 0;
    _state = CircuitState.closed;
    if (latencyMs > 0) _latencies.add(latencyMs);
    // Keep latency list bounded.
    if (_latencies.length > 100) _latencies.removeAt(0);
  }

  /// Record a failed call — may trip the circuit open.
  void recordFailure({String? error}) {
    _totalCalls++;
    _failureCount++;
    _lastError = error;
    _lastFailureTime = DateTime.now();

    if (_failureCount >= failureThreshold) {
      _state = CircuitState.open;
    }
  }

  /// Force-reset the breaker (e.g. when user reconfigures keys).
  void reset() {
    _failureCount = 0;
    _state = CircuitState.closed;
    _lastFailureTime = null;
    _lastError = null;
  }
}
