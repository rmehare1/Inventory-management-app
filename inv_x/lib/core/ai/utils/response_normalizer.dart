import 'package:inv_x/core/ai/models/ai_response.dart';
import 'package:inv_x/core/ai/providers/base_provider.dart';

class ResponseNormalizer {
  /// Normalizes a raw provider response into a consistent AIResponse.
  static AIResponse normalize({
    required String rawText,
    required String providerName,
    required ProviderTier tier,
    int tokensUsed = 0,
    double costPerMillionTokens = 0.0,
    int latencyMs = 0,
    int fallbacksAttempted = 0,
    List<String> failedProviders = const [],
  }) {
    final cleaned = _cleanText(rawText);
    final cost = _calculateCost(tokensUsed, costPerMillionTokens);

    return AIResponse(
      text: cleaned,
      provider: providerName,
      tier: tier,
      tokensUsed: tokensUsed,
      cost: cost,
      latencyMs: latencyMs,
      success: true,
      fallbacksAttempted: fallbacksAttempted,
      failedProviders: failedProviders,
    );
  }

  /// Strips common artifacts from provider responses.
  static String _cleanText(String text) {
    var cleaned = text.trim();

    // Remove leading/trailing quotes that some providers add.
    if (cleaned.startsWith('"') && cleaned.endsWith('"') && cleaned.length > 2) {
      cleaned = cleaned.substring(1, cleaned.length - 1);
    }

    // Remove any "<|assistant|>" or similar tokens some models leak.
    cleaned = cleaned.replaceAll(RegExp(r'<\|[^>]+\|>'), '');

    // Remove excessive whitespace.
    cleaned = cleaned.replaceAll(RegExp(r'\n{4,}'), '\n\n\n');

    return cleaned.trim();
  }

  /// Calculates the dollar cost given tokens used and price per million tokens.
  static double _calculateCost(int tokensUsed, double costPerMillionTokens) {
    if (tokensUsed <= 0 || costPerMillionTokens <= 0) return 0.0;
    return (tokensUsed / 1000000.0) * costPerMillionTokens;
  }
}
