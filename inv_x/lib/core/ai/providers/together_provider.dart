import 'package:inv_x/core/ai/models/ai_request.dart';
import 'package:inv_x/core/ai/models/ai_response.dart';
import 'package:inv_x/core/ai/providers/base_provider.dart';
import 'package:inv_x/core/ai/utils/response_normalizer.dart';

/// Priority 5 — FREE tier. Together AI (OpenAI-compatible).
class TogetherProvider extends BaseAIProvider {
  @override
  String get name => 'together';

  @override
  ProviderTier get tier => ProviderTier.free;

  @override
  int get priority => 5;

  @override
  String get baseUrl => 'https://api.together.xyz';

  @override
  String get model =>
      'meta-llama/Llama-3.1-8B-Instruct-Turbo';

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
      path: '/v1/chat/completions',
      body: body,
      apiKey: apiKey,
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
