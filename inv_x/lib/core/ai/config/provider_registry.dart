import '../providers/base_provider.dart';
import '../providers/ollama_provider.dart';
import '../providers/groq_provider.dart';
import '../providers/openrouter_provider.dart';
import '../providers/huggingface_provider.dart';
import '../providers/together_provider.dart';
import '../providers/cohere_provider.dart';
import '../providers/gemini_provider.dart';
import '../providers/openai_provider.dart';

/// Registry of all 8 AI providers, ordered by priority.
class ProviderRegistry {
  ProviderRegistry._();

  /// All providers sorted by priority (lowest priority number = tried first).
  static final List<BaseAIProvider> providers = [
    OllamaProvider(),   // Priority 1 — LOCAL
    GroqProvider(),      // Priority 2 — FREE (ultra-fast)
    OpenRouterProvider(),// Priority 3 — FREE
    HuggingFaceProvider(), // Priority 4 — FREE (can be slow)
    TogetherProvider(),  // Priority 5 — FREE
    CohereProvider(),    // Priority 6 — FREE
    GeminiProvider(),    // Priority 7 — PAID (cheap)
    OpenAIProvider(),    // Priority 8 — PAID (last resort)
  ];

  /// Get a provider by name.
  static BaseAIProvider? getByName(String name) {
    try {
      return providers.firstWhere((p) => p.name == name);
    } catch (_) {
      return null;
    }
  }

  /// Get all providers in a specific tier.
  static List<BaseAIProvider> getByTier(ProviderTier tier) {
    return providers.where((p) => p.tier == tier).toList();
  }

  /// Get all free providers.
  static List<BaseAIProvider> get freeProviders =>
      getByTier(ProviderTier.free);

  /// Get all paid providers.
  static List<BaseAIProvider> get paidProviders =>
      getByTier(ProviderTier.paid);

  /// Get the local provider (Ollama).
  static BaseAIProvider get localProvider => providers.first;

  /// Provider display info for UI.
  static Map<String, dynamic> getProviderInfo(String name) {
    final provider = getByName(name);
    if (provider == null) return {};
    return {
      'name': provider.name,
      'tier': provider.tier.name,
      'priority': provider.priority,
      'model': provider.model,
      'rateLimit': provider.rateLimit,
      'apiKeyRequired': provider.apiKeyRequired,
      'costPerMillionTokens': provider.costPerMillionTokens,
    };
  }
}
