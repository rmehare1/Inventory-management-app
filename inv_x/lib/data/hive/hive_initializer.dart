import 'package:hive_flutter/hive_flutter.dart';
import 'package:inv_x/data/hive/hive_adapters.dart';

/// Box name constants for consistent access throughout the app.
class HiveBoxes {
  HiveBoxes._();

  static const String products = 'products';
  static const String categories = 'categories';
  static const String suppliers = 'suppliers';
  static const String stockMovements = 'stock_movements';
  static const String purchaseOrders = 'purchase_orders';
  static const String chatMessages = 'chat_messages';
  static const String aiCallLogs = 'ai_call_logs';
  static const String forecasts = 'forecasts';
  static const String anomalies = 'anomalies';
  static const String appSettings = 'app_settings';
  static const String batches = 'batches';
}

/// Initializes Hive for Flutter, registers all adapters, and opens all boxes.
///
/// Call this once in `main()` before `runApp()`.
class HiveInitializer {
  HiveInitializer._();

  static Future<void> init() async {
    // Initialize Hive with Flutter (uses app documents directory)
    await Hive.initFlutter();

    // Register all TypeAdapters
    registerAllHiveAdapters();

    // Open all boxes in parallel for faster startup
    await Future.wait([
      Hive.openBox<ProductModel>(HiveBoxes.products),
      Hive.openBox<CategoryModel>(HiveBoxes.categories),
      Hive.openBox<SupplierModel>(HiveBoxes.suppliers),
      Hive.openBox<StockMovementModel>(HiveBoxes.stockMovements),
      Hive.openBox<PurchaseOrderModel>(HiveBoxes.purchaseOrders),
      Hive.openBox<ChatMessageModel>(HiveBoxes.chatMessages),
      Hive.openBox<AiCallLog>(HiveBoxes.aiCallLogs),
      Hive.openBox<ForecastModel>(HiveBoxes.forecasts),
      Hive.openBox<AnomalyModel>(HiveBoxes.anomalies),
      Hive.openBox<AppSettingsModel>(HiveBoxes.appSettings),
      Hive.openBox<BatchModel>(HiveBoxes.batches),
    ]);
  }

  /// Closes all open Hive boxes. Call on app dispose if needed.
  static Future<void> closeAll() async {
    await Hive.close();
  }
}
