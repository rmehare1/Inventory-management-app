import 'package:inv_x/core/ai/models/ai_request.dart';
import 'package:inv_x/core/ai/models/ai_response.dart';
import 'package:inv_x/core/ai/providers/base_provider.dart';
import 'package:inv_x/core/ai/utils/response_normalizer.dart';

/// Priority 8 — PAID tier. OpenAI (standard format).
class OpenAIProvider extends BaseAIProvider {
  @override
  String get name => 'openai';

  @override
  ProviderTier get tier => ProviderTier.paid;

  @override
  int get priority => 8;

  @override
  String get baseUrl => 'https://api.openai.com';

  @override
  String get model => 'gpt-4o-mini';

  @override
  String? get fallbackModel => 'gpt-4o';

  @override
  Duration get timeout => const Duration(seconds: 30);

  @override
  int get rateLimit => 60;

  @override
  double get costPerMillionTokens => 0.15;

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
      path: '/v1/chat/completions',
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
      costPerMillionTokens: costPerMillionTokens,
      latencyMs: stopwatch.elapsedMilliseconds,
    );
  }
}
