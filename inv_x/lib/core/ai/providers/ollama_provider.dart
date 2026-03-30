import 'package:dio/dio.dart';
import 'package:inv_x/core/ai/models/ai_request.dart';
import 'package:inv_x/core/ai/models/ai_response.dart';
import 'package:inv_x/core/ai/providers/base_provider.dart';
import 'package:inv_x/core/ai/utils/response_normalizer.dart';

/// Priority 1 — LOCAL Ollama instance.
/// No API key required. Runs on localhost.
class OllamaProvider extends BaseAIProvider {
  @override
  String get name => 'ollama';

  @override
  ProviderTier get tier => ProviderTier.local;

  @override
  int get priority => 1;

  @override
  String get baseUrl => 'http://localhost:11434';

  @override
  String get model => 'llama3.1:8b';

  @override
  Duration get timeout => const Duration(seconds: 60);

  @override
  int get maxRetries => 1;

  @override
  int get rateLimit => 999; // effectively unlimited locally

  @override
  bool get apiKeyRequired => false;

  @override
  Future<AIResponse> sendRequest(AIRequest request, String? apiKey) async {
    final sw = Stopwatch()..start();

    final systemPrompt = buildSystemPrompt(request.context);

    final body = {
      'model': model,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': request.prompt},
      ],
      'stream': false,
      'options': {
        'temperature': request.temperature,
        'num_predict': request.maxTokens,
      },
    };

    final response = await dio.post<Map<String, dynamic>>(
      '/api/chat',
      data: body,
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    sw.stop();

    final data = response.data!;
    final text = data['message']['content'] as String;

    // Ollama returns eval_count for tokens generated.
    final tokensUsed =
        (data['eval_count'] as int?) ?? 0;

    return ResponseNormalizer.normalize(
      rawText: text,
      providerName: name,
      tier: tier,
      tokensUsed: tokensUsed,
      latencyMs: sw.elapsedMilliseconds,
    );
  }

  /// Checks if Ollama is running locally.
  Future<bool> healthCheck() async {
    try {
      final response = await dio.get<dynamic>(
        '/api/tags',
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
        ),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
