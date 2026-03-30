class HiveBoxes {
  HiveBoxes._();

  static const products = 'products';
  static const categories = 'categories';
  static const suppliers = 'suppliers';
  static const stockMovements = 'stock_movements';
  static const purchaseOrders = 'purchase_orders';
  static const chatHistory = 'chat_history';
  static const aiLogs = 'ai_logs';
  static const forecasts = 'forecasts';
  static const anomalies = 'anomalies';
  static const settings = 'settings';

  /// All box names for bulk initialization.
  static const allBoxes = [
    products,
    categories,
    suppliers,
    stockMovements,
    purchaseOrders,
    chatHistory,
    aiLogs,
    forecasts,
    anomalies,
    settings,
  ];
}
