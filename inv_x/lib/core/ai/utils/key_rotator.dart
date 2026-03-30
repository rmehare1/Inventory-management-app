class KeyRotator {
  /// provider-name -> list of API keys.
  final Map<String, List<String>> _keys = {};

  /// provider-name -> current index in the key list.
  final Map<String, int> _currentIndex = {};

  /// Loads keys for a provider.
  void setKeys(String provider, List<String> keys) {
    _keys[provider] = List<String>.from(keys);
    _currentIndex[provider] = 0;
  }

  /// Returns the current active key for the provider, or null if none.
  String? getCurrentKey(String provider) {
    final keys = _keys[provider];
    if (keys == null || keys.isEmpty) return null;
    final idx = _currentIndex[provider] ?? 0;
    return keys[idx % keys.length];
  }

  /// Rotates to the next key. Returns the new key, or null if no more keys.
  String? rotateKey(String provider) {
    final keys = _keys[provider];
    if (keys == null || keys.isEmpty) return null;
    final current = (_currentIndex[provider] ?? 0) + 1;
    if (current >= keys.length) {
      // Wrapped around — all keys have been tried.
      _currentIndex[provider] = 0;
      return null; // Signal that we have exhausted all keys.
    }
    _currentIndex[provider] = current;
    return keys[current];
  }

  /// Returns true if there are untried keys remaining in the current rotation.
  bool hasMoreKeys(String provider) {
    final keys = _keys[provider];
    if (keys == null || keys.isEmpty) return false;
    final current = _currentIndex[provider] ?? 0;
    return current < keys.length - 1;
  }

  /// Resets the rotation index (e.g. on a new minute window).
  void resetRotation(String provider) {
    _currentIndex[provider] = 0;
  }

  /// Resets all rotations.
  void resetAll() {
    _currentIndex.clear();
  }

  /// Returns number of keys configured for a provider.
  int keyCount(String provider) => _keys[provider]?.length ?? 0;
}
