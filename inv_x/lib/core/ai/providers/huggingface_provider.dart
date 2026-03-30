import 'package:dio/dio.dart';
import 'package:inv_x/core/ai/models/ai_request.dart';
import 'package:inv_x/core/ai/models/ai_response.dart';
import 'package:inv_x/core/ai/providers/base_provider.dart';
import 'package:inv_x/core/ai/utils/response_normalizer.dart';

/// Priority 4 — FREE tier. HuggingFace Inference API.
/// Uses a different request/response format from OpenAI.
class HuggingFaceProvider extends BaseAIProvider {
  @override
  String get name => 'huggingface';

  @override
  ProviderTier get tier => ProviderTier.free;

  @override
  int get priority => 4;

  @override
  String get baseUrl =>
      'https://api-inference.huggingface.co';

  @override
  String get model =>
      'meta-llama/Meta-Llama-3.1-8B-Instruct';

  @override
  Duration get timeout => const Duration(seconds: 45);

  @override
  int get maxRetries => 2; // model loading may need retry

  @override
  int get rateLimit => 10;

  @override
  bool get apiKeyRequired => true;

  @override
  Future<AIResponse> sendRequest(AIRequest request, String? apiKey) async {
    final sw = Stopwatch()..start();

    final systemPrompt = buildSystemPrompt(request.context);

    // HuggingFace uses "inputs" instead of "messages".
    final prompt =
        '<|system|>\n$systemPrompt<|end|>\n<|user|>\n${request.prompt}<|end|>\n<|assistant|>\n';

    final body = {
      'inputs': prompt,
      'parameters': {
        'temperature': request.temperature,
        'max_new_tokens': request.maxTokens,
        'return_full_text': false,
      },
    };

    // Attempt with retry for 503 model-loading responses.
    dynamic data;
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final response = await postWithHandling(
          path: '/models/$model',
          body: body,
          apiKey: apiKey,
        );
        data = response.data;
        break;
      } on DioException catch (e) {
        final statusCode = e.response?.statusCode;
        if (statusCode == 503 && attempt < maxRetries) {
          // Model is loading — wait and retry.
          final estimatedTime =
              (e.response?.data is Map)
                  ? ((e.response!.data as Map)['estimated_time'] as num?)
                          ?.toInt() ??
                      10
                  : 10;
          final waitSeconds = estimatedTime.clamp(2, 30);
          await Future<void>.delayed(Duration(seconds: waitSeconds));
          continue;
        }
        rethrow;
      }
    }

    sw.stop();

    if (data == null) {
      throw Exception('HuggingFace: no response after retries');
    }

    // Response is a list: [{"generated_text": "..."}]
    String text;
    if (data is List && data.isNotEmpty) {
      text = data[0]['generated_text'] as String;
    } else if (data is Map && data.containsKey('generated_text')) {
      text = data['generated_text'] as String;
    } else {
      throw Exception('HuggingFace: unexpected response format');
    }

    return ResponseNormalizer.normalize(
      rawText: text,
      providerName: name,
      tier: tier,
      latencyMs: sw.elapsedMilliseconds,
    );
  }
}
