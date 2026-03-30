import 'package:inv_x/core/ai/models/ai_request.dart';
import 'package:inv_x/core/ai/models/ai_response.dart';
import 'package:inv_x/core/ai/providers/base_provider.dart';
import 'package:inv_x/core/ai/utils/response_normalizer.dart';

/// Priority 6 — FREE tier. Cohere (non-OpenAI format).
/// Uses "message" (not "messages") and "preamble" (not "system").
class CohereProvider extends BaseAIProvider {
  @override
  String get name => 'cohere';

  @override
  ProviderTier get tier => ProviderTier.free;

  @override
  int get priority => 6;

  @override
  String get baseUrl => 'https://api.cohere.ai';

  @override
  String get model => 'command-r-plus';

  @override
  Duration get timeout => const Duration(seconds: 25);

  @override
  int get rateLimit => 5;

  @override
  bool get apiKeyRequired => true;

  @override
  Future<AIResponse> sendRequest(AIRequest request, String? apiKey) async {
    final sw = Stopwatch()..start();

    final systemPrompt = buildSystemPrompt(request.context);

    // Cohere-specific body format.
    final body = {
      'model': model,
      'message': request.prompt,
      'preamble': systemPrompt,
      'temperature': request.temperature,
      'max_tokens': request.maxTokens,
    };

    final response = await postWithHandling(
      path: '/v1/chat',
      body: body,
      apiKey: apiKey,
    );

    sw.stop();
    final data = response.data as Map<String, dynamic>;

    final text = data['text'] as String;
    final tokensUsed = _extractTokens(data);

    return ResponseNormalizer.normalize(
      rawText: text,
      providerName: name,
      tier: tier,
      tokensUsed: tokensUsed,
      latencyMs: sw.elapsedMilliseconds,
    );
  }

  int _extractTokens(Map<String, dynamic> data) {
    final meta = data['meta'] as Map<String, dynamic>?;
    if (meta == null) return 0;
    final billedUnits = meta['billed_units'] as Map<String, dynamic>?;
    if (billedUnits == null) return 0;
    final input = (billedUnits['input_tokens'] as num?)?.toInt() ?? 0;
    final output = (billedUnits['output_tokens'] as num?)?.toInt() ?? 0;
    return input + output;
  }
}
