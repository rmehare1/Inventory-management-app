import 'models/ai_request.dart';
import 'models/ai_response.dart';
import 'fallback_manager.dart';

/// Singleton AI engine — the single entry point for ALL AI features in INV-X.
class InvXAIEngine {
  InvXAIEngine._();
  static final instance = InvXAIEngine._();

  late final AIFallbackManager _fallbackManager;
  bool _initialized = false;

  /// Initialize the engine. Call once on app startup.
  Future<void> initialize({
    double dailyCostLimit = 1.0,
    bool enablePaidFallback = true,
  }) async {
    if (_initialized) return;
    _fallbackManager = AIFallbackManager();
    _fallbackManager.dailyCostLimit = dailyCostLimit;
    _fallbackManager.enablePaidFallback = enablePaidFallback;
    _initialized = true;
  }

  AIFallbackManager get fallbackManager {
    assert(_initialized, 'InvXAIEngine not initialized. Call initialize() first.');
    return _fallbackManager;
  }

  /// Update cost settings (from settings screen).
  void updateSettings({
    double? dailyCostLimit,
    bool? enablePaidFallback,
  }) {
    if (dailyCostLimit != null) {
      _fallbackManager.dailyCostLimit = dailyCostLimit;
    }
    if (enablePaidFallback != null) {
      _fallbackManager.enablePaidFallback = enablePaidFallback;
    }
  }

  // ─────────────────────────────────────────────────────
  // PUBLIC API — All AI features
  // ─────────────────────────────────────────────────────

  /// General chat with the AI assistant.
  Future<AIResponse> chat(String message, {AIContext? context}) async {
    final aiContext = context ?? await AIContext.buildFromHive();
    return _fallbackManager.getResponse(AIRequest(
      prompt: message,
      type: AIRequestType.chat,
      context: aiContext,
    ));
  }

  /// Demand forecast for a specific product.
  Future<AIResponse> forecastDemand(
    String productId, {
    int days = 30,
    AIContext? context,
  }) async {
    final aiContext = context ?? await AIContext.buildFromHive();
    return _fallbackManager.getResponse(AIRequest(
      prompt: 'Generate a $days-day demand forecast for product ID: $productId. '
          'Analyze historical stock movements, identify trends, seasonal patterns, '
          'and provide: predicted daily demand, confidence score, trend direction, '
          'recommended reorder quantity and date. Format as structured data.',
      type: AIRequestType.forecast,
      context: aiContext,
      temperature: 0.3,
    ));
  }

  /// Analyze a transaction or stock movement for anomalies.
  Future<AIResponse> analyzeAnomaly(
    Map<String, dynamic> transactionData, {
    AIContext? context,
  }) async {
    final aiContext = context ?? await AIContext.buildFromHive();
    return _fallbackManager.getResponse(AIRequest(
      prompt: 'Analyze this inventory transaction for anomalies:\n'
          '${transactionData.toString()}\n\n'
          'Check for: unusual quantities, time-of-day patterns, missing records, '
          'price discrepancies. Rate severity: CRITICAL/HIGH/MEDIUM/LOW. '
          'Provide explanation and recommended action.',
      type: AIRequestType.anomaly,
      context: aiContext,
      temperature: 0.2,
    ));
  }

  /// Auto-categorize a product from its name/description.
  Future<AIResponse> categorizeProduct(
    String description, {
    AIContext? context,
  }) async {
    final aiContext = context ?? await AIContext.buildFromHive();
    return _fallbackManager.getResponse(AIRequest(
      prompt: 'Categorize this product: "$description". '
          'Return JSON with: category, subcategory, suggested_tags (array), '
          'suggested_description, estimated_price_range_inr.',
      type: AIRequestType.categorize,
      context: aiContext,
      temperature: 0.3,
      maxTokens: 512,
    ));
  }

  /// Generate a business report.
  Future<AIResponse> generateReport(
    String reportType,
    Map<String, dynamic> data, {
    AIContext? context,
  }) async {
    final aiContext = context ?? await AIContext.buildFromHive();
    return _fallbackManager.getResponse(AIRequest(
      prompt: 'Generate a "$reportType" business report using this data:\n'
          '${data.toString()}\n\n'
          'Include: executive summary, key metrics, trends, concerns, '
          'recommendations, and action items. Format professionally with '
          'headings and bullet points.',
      type: AIRequestType.report,
      context: aiContext,
      temperature: 0.5,
      maxTokens: 2048,
    ));
  }

  /// Suggest the best supplier deal for a product.
  Future<AIResponse> negotiateSupplier(
    String productId,
    int quantity, {
    AIContext? context,
  }) async {
    final aiContext = context ?? await AIContext.buildFromHive();
    return _fallbackManager.getResponse(AIRequest(
      prompt: 'I need to order $quantity units of product $productId. '
          'Compare all available suppliers and recommend the best deal '
          'considering: price, delivery time, reliability score, and total cost. '
          'Format as a comparison table with a clear recommendation.',
      type: AIRequestType.negotiate,
      context: aiContext,
      temperature: 0.4,
    ));
  }

  /// Smart auto-fill product details from just a name.
  Future<AIResponse> smartAutoFill(
    String productName, {
    AIContext? context,
  }) async {
    final aiContext = context ?? await AIContext.buildFromHive();
    return _fallbackManager.getResponse(AIRequest(
      prompt: 'Auto-fill product details for: "$productName". '
          'Return JSON with: name, description, category, tags (array), '
          'suggested_cost_price_inr, suggested_selling_price_inr, '
          'suggested_unit (pcs/kg/liters/boxes/meters/dozen), '
          'storage_tips.',
      type: AIRequestType.categorize,
      context: aiContext,
      temperature: 0.4,
      maxTokens: 512,
    ));
  }

  /// Get health status of all providers.
  Future<List<Map<String, dynamic>>> getProviderHealth() async {
    return _fallbackManager.getProviderHealth();
  }

  /// Get cost analytics.
  Map<String, dynamic> getCostAnalytics() {
    return _fallbackManager.costTracker.getAnalytics();
  }

  /// Get today's total cost.
  double get todayCost => _fallbackManager.costTracker.totalCostToday;
}
