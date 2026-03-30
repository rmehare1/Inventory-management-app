import 'dart:developer' as dev;
import 'providers/base_provider.dart';
import 'models/ai_request.dart';
import 'models/ai_response.dart';
import 'config/api_keys_manager.dart';
import 'config/provider_registry.dart';
import 'utils/circuit_breaker.dart';
import 'utils/rate_limiter.dart';
import 'utils/cost_tracker.dart';

/// The brain of INV-X AI: cascading fallback across 8 providers.
///
/// Order: Ollama (local) → Groq → OpenRouter → HuggingFace →
///        Together → Cohere → Gemini (paid) → OpenAI (paid)
class AIFallbackManager {
  final ApiKeysManager _keysManager;
  final Map<String, CircuitBreaker> _circuitBreakers = {};
  final RateLimiter _rateLimiter = RateLimiter();
  final CostTracker costTracker = CostTracker();


  // Settings (injected from AppSettings)
  double dailyCostLimit = 1.0;
  bool enablePaidFallback = true;

  AIFallbackManager({ApiKeysManager? keysManager})
      : _keysManager = keysManager ?? ApiKeysManager.instance {
    // Initialize circuit breakers for each provider
    for (final provider in ProviderRegistry.providers) {
      _circuitBreakers[provider.name] = CircuitBreaker();
    }
  }

  /// Initialize persistent cost tracking.
  Future<void> initialize() async {
    await costTracker.initialize();
  }

  /// Main entry point: tries each provider in priority order.
  Future<AIResponse> getResponse(AIRequest request) async {
    final errors = <String>[];
    final failedProviders = <String>[];
    final stopwatch = Stopwatch()..start();
    int fallbacksAttempted = 0;

    for (final provider in ProviderRegistry.providers) {
      final breaker = _circuitBreakers[provider.name]!;

      // CHECK 1: Circuit Breaker
      if (!breaker.canAttempt()) {
        errors.add('${provider.name}: circuit OPEN');
        failedProviders.add(provider.name);
        fallbacksAttempted++;
        continue;
      }

      // CHECK 2: Rate Limit
      if (!_rateLimiter.canMakeRequest(provider.name, provider.rateLimit)) {
        errors.add('${provider.name}: rate limited');
        failedProviders.add(provider.name);
        fallbacksAttempted++;
        continue;
      }

      // CHECK 3: Cost Limit (paid providers only)
      if (provider.tier == ProviderTier.paid) {
        if (!enablePaidFallback) {
          errors.add('${provider.name}: paid fallback disabled');
          failedProviders.add(provider.name);
          fallbacksAttempted++;
          continue;
        }
        if (!costTracker.canUsePaidProvider(dailyLimit: dailyCostLimit)) {
          errors.add('${provider.name}: daily cost limit reached');
          failedProviders.add(provider.name);
          fallbacksAttempted++;
          continue;
        }
      }

      // CHECK 4: API key available
      String? apiKey;
      if (provider.apiKeyRequired) {
        apiKey = await _keysManager.getKey(provider.name);
        if (apiKey == null) {
          errors.add('${provider.name}: no API key configured');
          failedProviders.add(provider.name);
          fallbacksAttempted++;
          continue;
        }
      }

      // ATTEMPT REQUEST
      try {
        dev.log(
          '🔄 Trying ${provider.name} (Tier: ${provider.tier.name})...',
          name: 'AIFallback',
        );

        final response = await provider
            .sendRequest(request, apiKey)
            .timeout(provider.timeout);

        breaker.recordSuccess(latencyMs: response.latencyMs);
        _rateLimiter.recordRequest(provider.name);

        final cost = response.cost;
        if (cost > 0) {
          await costTracker.recordCost(cost);
        }

        stopwatch.stop();
        dev.log(
          '✅ ${provider.name} succeeded '
          '(${stopwatch.elapsedMilliseconds}ms, '
          '\$${cost.toStringAsFixed(6)})',
          name: 'AIFallback',
        );

        // Return enriched response with fallback info
        return AIResponse(
          text: response.text,
          provider: provider.name,
          tier: provider.tier,
          tokensUsed: response.tokensUsed,
          cost: cost,
          latencyMs: stopwatch.elapsedMilliseconds,
          success: true,
          fallbacksAttempted: fallbacksAttempted,
          failedProviders: failedProviders,
        );
      } catch (e) {
        breaker.recordFailure(error: e.toString());
        final errorMsg = '${provider.name}: $e';
        errors.add(errorMsg);
        failedProviders.add(provider.name);
        fallbacksAttempted++;
        dev.log('❌ $errorMsg', name: 'AIFallback');

        // Try key rotation on rate limit errors
        if (_isRateLimitError(e)) {
          final nextKey =
              await _keysManager.getNextKey(provider.name, apiKey);
          if (nextKey != null && nextKey != apiKey) {
            dev.log('🔑 Rotating key for ${provider.name}...', name: 'AIFallback');
            try {
              final retryResponse = await provider
                  .sendRequest(request, nextKey)
                  .timeout(provider.timeout);
              breaker.recordSuccess();
              return AIResponse(
                text: retryResponse.text,
                provider: provider.name,
                tier: provider.tier,
                tokensUsed: retryResponse.tokensUsed,
                cost: retryResponse.cost,
                latencyMs: stopwatch.elapsedMilliseconds,
                success: true,
                fallbacksAttempted: fallbacksAttempted,
                failedProviders: failedProviders,
              );
            } catch (_) {
              // Key rotation didn't help, continue to next provider
            }
          }
        }

        continue;
      }
    }

    // ALL 8 PROVIDERS FAILED
    stopwatch.stop();
    dev.log('💀 All providers failed. Returning offline response.', name: 'AIFallback');

    return AIResponse(
      text: _getOfflineFallbackResponse(request),
      provider: 'offline',
      tier: ProviderTier.local,
      tokensUsed: 0,
      cost: 0,
      latencyMs: stopwatch.elapsedMilliseconds,
      success: false,
      fallbacksAttempted: fallbacksAttempted,
      failedProviders: failedProviders,
      errorMessage: errors.join('\n'),
    );
  }

  bool _isRateLimitError(Object error) {
    final msg = error.toString().toLowerCase();
    return msg.contains('429') || msg.contains('rate limit');
  }

  String _getOfflineFallbackResponse(AIRequest request) {
    switch (request.type) {
      case AIRequestType.chat:
        return '⚠️ I\'m currently offline and unable to reach any AI provider. '
            'Your inventory data is still fully accessible — you can add, edit, '
            'and manage products normally. AI features will resume when a '
            'provider becomes available.\n\n'
            'Tip: Add API keys in Settings → AI Configuration to enable AI.';
      case AIRequestType.forecast:
        return '⚠️ Unable to generate forecast — no AI providers available.';
      case AIRequestType.anomaly:
        return '⚠️ Anomaly detection unavailable — no AI providers reachable.';
      case AIRequestType.categorize:
        return '⚠️ Auto-categorization unavailable offline.';
      case AIRequestType.report:
        return '⚠️ AI report generation unavailable — please try again later.';
      case AIRequestType.negotiate:
        return '⚠️ AI negotiation unavailable — no providers reachable.';
    }
  }

  /// Get health status for all providers.
  Future<List<Map<String, dynamic>>> getProviderHealth() async {
    final health = <Map<String, dynamic>>[];
    for (final provider in ProviderRegistry.providers) {
      final breaker = _circuitBreakers[provider.name]!;
      final hasKey = provider.apiKeyRequired
          ? await _keysManager.hasKeys(provider.name)
          : true;

      health.add({
        'name': provider.name,
        'tier': provider.tier.name,
        'priority': provider.priority,
        'circuitState': breaker.state.name,
        'failureCount': breaker.totalCalls,
        'successRate': breaker.successRate,
        'avgLatencyMs': breaker.avgLatencyMs,
        'hasApiKey': hasKey,
        'isAvailable': breaker.canAttempt() && hasKey,
        'model': provider.model,
        'rateLimit': provider.rateLimit,
      });
    }
    return health;
  }

  /// Count of healthy (available) providers.
  Future<int> get healthyProviderCount async {
    final health = await getProviderHealth();
    return health.where((h) => h['isAvailable'] == true).length;
  }
}
