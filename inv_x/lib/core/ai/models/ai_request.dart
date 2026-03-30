import 'ai_context.dart';
export 'ai_context.dart';

enum AIRequestType { chat, forecast, anomaly, categorize, report, negotiate }

class AIRequest {
  final String prompt;
  final AIRequestType type;
  final AIContext? context;
  final double temperature;
  final int maxTokens;
  final DateTime createdAt;

  AIRequest({
    required this.prompt,
    this.type = AIRequestType.chat,
    this.context,
    this.temperature = 0.7,
    this.maxTokens = 1024,
  }) : createdAt = DateTime.now();

  Map<String, dynamic> toMap() => {
        'prompt': prompt,
        'type': type.name,
        'temperature': temperature,
        'maxTokens': maxTokens,
        'createdAt': createdAt.toIso8601String(),
      };
}
