import 'package:inv_x/core/ai/models/ai_request.dart';
import 'package:inv_x/core/ai/models/ai_response.dart';
import 'package:inv_x/core/ai/providers/base_provider.dart';
import 'package:inv_x/core/ai/utils/response_normalizer.dart';

/// Priority 2 — FREE tier. Groq cloud inference (OpenAI-compatible).
class GroqProvider extends BaseAIProvider {
  @override
  String get name => 'groq';

  @override
  ProviderTier get tier => ProviderTier.free;

  @override
  int get priority => 2;

  @override
  String get baseUrl => 'https://api.groq.com';

  @override
  String get model => 'llama-3.1-70b-versatile';

  @override
  String? get fallbackModel => 'mixtral-8x7b-32768';

  @override
  Duration get timeout => const Duration(seconds: 15);

  @override
  int get rateLimit => 30;

  @override
  bool get apiKeyRequired => true;

  @override
  Future<AIResponse> sendRequest(AIRequest request, String? apiKey) async {
    final sw = Stopwatch()..start();

    final systemPrompt = buildSystemPrompt(request.context);

    try {
      return await _call(
        modelName: model,
        systemPrompt: systemPrompt,
        request: request,
        apiKey: apiKey,
        stopwatch: sw,
      );
    } catch (e) {
      // Try fallback model if primary fails.
      if (fallbackModel != null) {
        return await _call(
          modelName: fallbackModel!,
          systemPrompt: systemPrompt,
          request: request,
          apiKey: apiKey,
          stopwatch: sw,
        );
      }
      rethrow;
    }
  }

  Future<AIResponse> _call({
    required String modelName,
    required String systemPrompt,
    required AIRequest request,
    required String? apiKey,
    required Stopwatch stopwatch,
  }) async {
    final body = buildOpenAIChatBody(
      systemPrompt: systemPrompt,
      userPrompt: request.prompt,
      modelName: modelName,
      temperature: request.temperature,
      maxTokens: request.maxTokens,
    );

    final response = await postWithHandling(
      path: '/openai/v1/chat/completions',
      body: body,
      apiKey: apiKey,
    );

    stopwatch.stop();
    final data = response.data as Map<String, dynamic>;

    return ResponseNormalizer.normalize(
      rawText: extractOpenAIText(data),
      providerName: name,
      tier: tier,
      tokensUsed: extractOpenAITokens(data),
      latencyMs: stopwatch.elapsedMilliseconds,
    );
  }
}
