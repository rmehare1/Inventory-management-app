import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages API keys for all AI providers using encrypted secure storage.
class ApiKeysManager {
  ApiKeysManager._();
  static final instance = ApiKeysManager._();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Provider key names in secure storage
  static const _keyPrefix = {
    'ollama': 'ollama_keys',
    'groq': 'groq_keys',
    'openrouter': 'openrouter_keys',
    'huggingface': 'huggingface_keys',
    'together': 'together_keys',
    'cohere': 'cohere_keys',
    'gemini': 'gemini_keys',
    'openai': 'openai_keys',
  };

  String _storageKey(String provider) =>
      _keyPrefix[provider] ?? '${provider}_keys';

  /// Save a single key for a provider (appends to existing keys).
  Future<void> saveKey(String provider, String key) async {
    final keys = await getKeys(provider);
    if (!keys.contains(key)) {
      keys.add(key);
      await _storage.write(
        key: _storageKey(provider),
        value: jsonEncode(keys),
      );
    }
  }

  /// Save multiple keys at once (replaces all keys).
  Future<void> saveKeys(String provider, List<String> keys) async {
    await _storage.write(
      key: _storageKey(provider),
      value: jsonEncode(keys),
    );
  }

  /// Retrieve all keys for a provider.
  Future<List<String>> getKeys(String provider) async {
    final raw = await _storage.read(key: _storageKey(provider));
    if (raw == null || raw.isEmpty) return [];
    try {
      return List<String>.from(jsonDecode(raw) as List);
    } catch (_) {
      return [];
    }
  }

  /// Get the first available key for a provider.
  Future<String?> getKey(String provider) async {
    final keys = await getKeys(provider);
    return keys.isNotEmpty ? keys.first : null;
  }

  /// Delete a specific key by index.
  Future<void> deleteKey(String provider, int index) async {
    final keys = await getKeys(provider);
    if (index >= 0 && index < keys.length) {
      keys.removeAt(index);
      await saveKeys(provider, keys);
    }
  }

  /// Delete all keys for a provider.
  Future<void> deleteAllKeys(String provider) async {
    await _storage.delete(key: _storageKey(provider));
  }

  /// Check if any keys are configured for a provider.
  Future<bool> hasKeys(String provider) async {
    final keys = await getKeys(provider);
    return keys.isNotEmpty;
  }

  /// Get list of providers that have at least one key configured.
  Future<List<String>> getConfiguredProviders() async {
    final configured = <String>[];
    for (final provider in _keyPrefix.keys) {
      if (await hasKeys(provider)) {
        configured.add(provider);
      }
    }
    return configured;
  }

  /// Mask a key for display: "gsk_Xxxx...xxxx"
  String maskKey(String key) {
    if (key.length <= 8) return '••••••••';
    return '${key.substring(0, 4)}...${key.substring(key.length - 4)}';
  }

  /// Get the next key for rotation (round-robin).
  Future<String?> getNextKey(String provider, String? currentKey) async {
    final keys = await getKeys(provider);
    if (keys.isEmpty) return null;
    if (currentKey == null) return keys.first;

    final currentIndex = keys.indexOf(currentKey);
    if (currentIndex == -1 || currentIndex >= keys.length - 1) {
      return keys.first;
    }
    return keys[currentIndex + 1];
  }
}
