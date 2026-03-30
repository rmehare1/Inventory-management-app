class AppConstants {
  AppConstants._();

  // App info
  static const appName = 'INV-X';
  static const appTagline = 'AI-Powered Inventory Management';
  static const appVersion = '1.0.0';

  // Currency
  static const defaultCurrency = '₹';
  static const currencyLocale = 'en_IN';

  // Cache & data retention
  static const cacheDuration = Duration(minutes: 5);
  static const aiLogRetentionDays = 30;
  static const forecastHistoryDays = 90;
  static const anomalyRetentionDays = 60;
  static const maxChatHistoryMessages = 500;

  // Pagination
  static const defaultPageSize = 20;
  static const maxPageSize = 100;

  // Search
  static const searchDebounceMs = 300;
  static const minSearchLength = 2;

  // Scanner
  static const scannerTimeout = Duration(seconds: 30);
  static const barcodeFormats = ['QR_CODE', 'EAN_13', 'EAN_8', 'CODE_128'];

  // Stock thresholds (percentage)
  static const stockCriticalThreshold = 10.0;
  static const stockLowThreshold = 25.0;
  static const stockWarningThreshold = 50.0;

  // AI tiers
  static const aiTierLocal = 'LOCAL';
  static const aiTierFree = 'FREE';
  static const aiTierPaid = 'PAID';

  // Animation durations
  static const animFast = Duration(milliseconds: 200);
  static const animNormal = Duration(milliseconds: 300);
  static const animSlow = Duration(milliseconds: 500);
  static const animVerySlow = Duration(milliseconds: 800);

  // Layout
  static const maxContentWidth = 600.0;
  static const horizontalPadding = 16.0;
  static const cardBorderRadius = 16.0;
  static const inputBorderRadius = 12.0;

  // File size limits
  static const maxImageSizeMB = 5;
  static const maxExportRowCount = 10000;

  // Regex patterns
  static const emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const phonePattern = r'^[+]?[\d\s\-()]{7,15}$';
  static const skuPattern = r'^[A-Z]{2,4}-\d{4,8}$';
}
