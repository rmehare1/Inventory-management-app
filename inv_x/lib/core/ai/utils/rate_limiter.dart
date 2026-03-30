class RateLimiter {
  /// provider-name -> list of request timestamps within the current window.
  final Map<String, List<DateTime>> _timestamps = {};

  /// Returns true if the provider has capacity within the given rate limit.
  bool canMakeRequest(String provider, int maxPerMinute) {
    _cleanOldEntries(provider);
    final stamps = _timestamps[provider];
    if (stamps == null) return true;
    return stamps.length < maxPerMinute;
  }

  /// Records a request timestamp for the provider.
  void recordRequest(String provider) {
    _timestamps.putIfAbsent(provider, () => []);
    _timestamps[provider]!.add(DateTime.now());
  }

  /// Returns the number of requests made in the current window.
  int currentCount(String provider) {
    _cleanOldEntries(provider);
    return _timestamps[provider]?.length ?? 0;
  }

  /// Returns seconds until the next request slot is available.
  int secondsUntilAvailable(String provider, int maxPerMinute) {
    _cleanOldEntries(provider);
    final stamps = _timestamps[provider];
    if (stamps == null || stamps.length < maxPerMinute) return 0;

    // The oldest entry will expire first.
    final oldest = stamps.first;
    final expiresAt = oldest.add(const Duration(seconds: 60));
    final remaining = expiresAt.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  /// Removes timestamps older than 60 seconds for the given provider.
  void _cleanOldEntries(String provider) {
    final stamps = _timestamps[provider];
    if (stamps == null) return;
    final cutoff = DateTime.now().subtract(const Duration(seconds: 60));
    stamps.removeWhere((t) => t.isBefore(cutoff));
  }

  /// Clears all tracking data.
  void reset() => _timestamps.clear();
}
