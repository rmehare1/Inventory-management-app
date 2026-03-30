import 'package:inv_x/core/ai/models/ai_request.dart';
import 'package:inv_x/core/ai/models/ai_response.dart';
import 'package:inv_x/core/ai/providers/base_provider.dart';
import 'package:inv_x/core/ai/utils/response_normalizer.dart';

/// Priority 3 — FREE tier. OpenRouter (OpenAI-compatible with extra headers).
class OpenRouterProvider extends BaseAIProvider {
  @override
  String get name => 'openrouter';

  @override
  ProviderTier get tier => ProviderTier.free;

  @override
  int get priority => 3;

  @override
  String get baseUrl => 'https://openrouter.ai';

  @override
  String get model => 'meta-llama/llama-3.1-8b-instruct:free';

  @override
  Duration get timeout => const Duration(seconds: 20);

  @override
  int get rateLimit => 10;

  @override
  bool get apiKeyRequired => true;

  @override
  Future<AIResponse> sendRequest(AIRequest request, String? apiKey) async {
    final sw = Stopwatch()..start();

    final systemPrompt = buildSystemPrompt(request.context);

    final body = buildOpenAIChatBody(
      systemPrompt: systemPrompt,
      userPrompt: request.prompt,
      modelName: model,
      temperature: request.temperature,
      maxTokens: request.maxTokens,
    );

    final response = await postWithHandling(
      path: '/api/v1/chat/completions',
      body: body,
      apiKey: apiKey,
      extraHeaders: {
        'HTTP-Referer': 'https://inv-x.app',
        'X-Title': 'INV-X Inventory Manager',
      },
    );

    sw.stop();
    final data = response.data as Map<String, dynamic>;

    return ResponseNormalizer.normalize(
      rawText: extractOpenAIText(data),
      providerName: name,
      tier: tier,
      tokensUsed: extractOpenAITokens(data),
      latencyMs: sw.elapsedMilliseconds,
    );
  }
}
