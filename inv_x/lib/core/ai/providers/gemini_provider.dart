import 'package:dio/dio.dart';
import 'package:inv_x/core/ai/models/ai_request.dart';
import 'package:inv_x/core/ai/models/ai_response.dart';
import 'package:inv_x/core/ai/providers/base_provider.dart';
import 'package:inv_x/core/ai/utils/response_normalizer.dart';

/// Priority 7 — PAID tier. Google Gemini.
/// Unique body format: "contents" + "generationConfig".
class GeminiProvider extends BaseAIProvider {
  @override
  String get name => 'gemini';

  @override
  ProviderTier get tier => ProviderTier.paid;

  @override
  int get priority => 7;

  @override
  String get baseUrl =>
      'https://generativelanguage.googleapis.com';

  @override
  String get model => 'gemini-1.5-flash';

  @override
  String? get fallbackModel => 'gemini-1.5-pro';

  @override
  Duration get timeout => const Duration(seconds: 20);

  @override
  int get rateLimit => 60;

  @override
  double get costPerMillionTokens => 0.075;

  @override
  bool get apiKeyRequired => true;

  @override
  Future<AIResponse> sendRequest(AIRequest request, String? apiKey) async {
    final sw = Stopwatch()..start();

    try {
      return await _call(
        modelName: model,
        request: request,
        apiKey: apiKey!,
        stopwatch: sw,
      );
    } catch (e) {
      if (fallbackModel != null) {
        return await _call(
          modelName: fallbackModel!,
          request: request,
          apiKey: apiKey!,
          stopwatch: sw,
        );
      }
      rethrow;
    }
  }

  Future<AIResponse> _call({
    required String modelName,
    required AIRequest request,
    required String apiKey,
    required Stopwatch stopwatch,
  }) async {
    final systemPrompt = buildSystemPrompt(request.context);

    // Gemini-specific body format.
    final body = {
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': '$systemPrompt\n\n${request.prompt}'},
          ],
        },
      ],
      'generationConfig': {
        'temperature': request.temperature,
        'maxOutputTokens': request.maxTokens,
      },
    };

    // Gemini passes the API key as a query parameter, not a header.
    final response = await dio.post<Map<String, dynamic>>(
      '/v1beta/models/$modelName:generateContent',
      data: body,
      queryParameters: {'key': apiKey},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    stopwatch.stop();

    final data = response.data!;
    final text = data['candidates'][0]['content']['parts'][0]['text'] as String;

    // Token usage from Gemini.
    int tokensUsed = 0;
    final usageMetadata = data['usageMetadata'] as Map<String, dynamic>?;
    if (usageMetadata != null) {
      tokensUsed =
          ((usageMetadata['promptTokenCount'] as int?) ?? 0) +
          ((usageMetadata['candidatesTokenCount'] as int?) ?? 0);
    }

    return ResponseNormalizer.normalize(
      rawText: text,
      providerName: name,
      tier: tier,
      tokensUsed: tokensUsed,
      costPerMillionTokens: costPerMillionTokens,
      latencyMs: stopwatch.elapsedMilliseconds,
    );
  }
}
