import 'package:dio/dio.dart';
import 'package:inv_x/core/ai/models/ai_request.dart';
import 'package:inv_x/core/ai/models/ai_response.dart';

enum ProviderTier { local, free, paid }

abstract class BaseAIProvider {
  // --- Identity ---
  String get name;
  ProviderTier get tier;
  int get priority;

  // --- Endpoint ---
  String get baseUrl;
  String get model;
  String? get fallbackModel => null;

  // --- Limits ---
  Duration get timeout => const Duration(seconds: 20);
  int get maxRetries => 1;
  int get rateLimit => 30; // requests per minute
  double get costPerMillionTokens => 0.0;
  bool get apiKeyRequired => true;

  // --- Shared Dio instance per provider ---
  late final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: timeout,
    receiveTimeout: timeout,
    sendTimeout: timeout,
  ));

  Dio get dio => _dio;

  /// Subclasses implement actual HTTP call and response parsing.
  Future<AIResponse> sendRequest(AIRequest request, String? apiKey);

  /// Builds the INV-X system prompt, optionally enriched with business context.
  String buildSystemPrompt(AIContext? context) {
    final buf = StringBuffer();
    buf.writeln('You are INV-X AI, an expert inventory management assistant.');
    buf.writeln('You help small and medium businesses manage stock efficiently.');
    buf.writeln('You provide actionable, concise advice. Use data when available.');
    buf.writeln('Always respond in the same language the user writes in.');
    buf.writeln('When discussing money, use the user\'s local currency.');
    buf.writeln('Format numbers clearly. Use bullet points for lists.');
    buf.writeln('If you are unsure, say so honestly rather than guessing.');

    if (context != null) {
      buf.writeln();
      buf.writeln('--- Current Business Context ---');
      buf.writeln(context.toPromptString());
      buf.writeln('--- End Context ---');
    }

    return buf.toString();
  }

  /// Convenience: parse a standard OpenAI-compatible JSON body.
  Map<String, dynamic> buildOpenAIChatBody({
    required String systemPrompt,
    required String userPrompt,
    required String modelName,
    double temperature = 0.7,
    int maxTokens = 1024,
  }) {
    return {
      'model': modelName,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': userPrompt},
      ],
      'temperature': temperature,
      'max_tokens': maxTokens,
    };
  }

  /// Convenience: extract text from standard OpenAI-compatible response.
  String extractOpenAIText(Map<String, dynamic> data) {
    return (data['choices'] as List).first['message']['content'] as String;
  }

  /// Convenience: extract token usage from standard OpenAI-compatible response.
  int extractOpenAITokens(Map<String, dynamic> data) {
    final usage = data['usage'];
    if (usage == null) return 0;
    return (usage['total_tokens'] ?? 0) as int;
  }

  /// Makes a POST request with common error handling.
  Future<Response<dynamic>> postWithHandling({
    required String path,
    required Map<String, dynamic> body,
    Map<String, String>? extraHeaders,
    String? apiKey,
    String authScheme = 'Bearer',
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (apiKey != null && apiKey.isNotEmpty) {
      headers['Authorization'] = '$authScheme $apiKey';
    }

    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }

    final response = await dio.post<Map<String, dynamic>>(
      path,
      data: body,
      options: Options(headers: headers),
    );

    if (response.statusCode != null && response.statusCode! >= 400) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'HTTP ${response.statusCode}: ${response.statusMessage}',
      );
    }

    return response;
  }

  @override
  String toString() => '$name (tier=${tier.name}, priority=$priority)';
}
