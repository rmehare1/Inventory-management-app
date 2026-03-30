import 'package:inv_x/core/ai/providers/base_provider.dart';

class AIResponse {
  final String text;
  final String provider;
  final ProviderTier tier;
  final int tokensUsed;
  final double cost;
  final int latencyMs;
  final bool success;
  final int fallbacksAttempted;
  final List<String> failedProviders;
  final String? errorMessage;

  const AIResponse({
    required this.text,
    required this.provider,
    required this.tier,
    this.tokensUsed = 0,
    this.cost = 0.0,
    this.latencyMs = 0,
    this.success = true,
    this.fallbacksAttempted = 0,
    this.failedProviders = const [],
    this.errorMessage,
  });

  factory AIResponse.error({
    required String message,
    int fallbacksAttempted = 0,
    List<String> failedProviders = const [],
  }) {
    return AIResponse(
      text: 'I apologize, but I am unable to process your request right now. '
          'All AI providers are currently unavailable. '
          'Please check your internet connection or try again later.\n\n'
          'Error: $message',
      provider: 'none',
      tier: ProviderTier.local,
      success: false,
      fallbacksAttempted: fallbacksAttempted,
      failedProviders: failedProviders,
      errorMessage: message,
    );
  }

  factory AIResponse.offlineFallback({
    required String prompt,
    int fallbacksAttempted = 0,
    List<String> failedProviders = const [],
  }) {
    return AIResponse(
      text: _generateOfflineResponse(prompt),
      provider: 'offline_fallback',
      tier: ProviderTier.local,
      success: true,
      fallbacksAttempted: fallbacksAttempted,
      failedProviders: failedProviders,
      errorMessage: 'All providers exhausted — using offline fallback.',
    );
  }

  Map<String, dynamic> toMap() => {
        'text': text,
        'provider': provider,
        'tier': tier.name,
        'tokensUsed': tokensUsed,
        'cost': cost,
        'latencyMs': latencyMs,
        'success': success,
        'fallbacksAttempted': fallbacksAttempted,
        'failedProviders': failedProviders,
        'errorMessage': errorMessage,
      };

  static String _generateOfflineResponse(String prompt) {
    final lower = prompt.toLowerCase();

    if (lower.contains('forecast') || lower.contains('predict') || lower.contains('demand')) {
      return 'Offline mode: I cannot generate AI-powered forecasts without an internet connection. '
          'However, you can review your historical stock movement charts in the Analytics tab '
          'to identify trends manually. Consider reordering items that have shown consistent '
          'weekly demand.';
    }

    if (lower.contains('anomal') || lower.contains('unusual') || lower.contains('suspicious')) {
      return 'Offline mode: Anomaly detection requires AI processing. '
          'In the meantime, check the Alerts tab for any low-stock or expiry warnings '
          'that the local rule engine has flagged.';
    }

    if (lower.contains('report') || lower.contains('summary')) {
      return 'Offline mode: AI-generated reports are unavailable. '
          'You can still export raw data from the Reports section as PDF or Excel. '
          'AI insights will be added when connectivity is restored.';
    }

    if (lower.contains('categor') || lower.contains('classify')) {
      return 'Offline mode: Automatic categorization is unavailable. '
          'Please assign categories manually from the product edit screen.';
    }

    if (lower.contains('negoti') || lower.contains('supplier') || lower.contains('price')) {
      return 'Offline mode: Supplier negotiation analysis requires AI. '
          'You can review past purchase prices in the supplier section to prepare '
          'your negotiation points manually.';
    }

    return 'I am currently offline and cannot process AI requests. '
        'Basic inventory operations (add, edit, scan, alerts) still work normally. '
        'AI features will resume when connectivity is restored.';
  }
}
