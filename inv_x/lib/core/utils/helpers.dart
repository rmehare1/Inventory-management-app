import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';

/// Formats a number as Indian Rupees.
String formatCurrency(num amount, {int decimals = 2}) {
  final formatter = NumberFormat.currency(
    locale: AppConstants.currencyLocale,
    symbol: AppConstants.defaultCurrency,
    decimalDigits: decimals,
  );
  return formatter.format(amount);
}

/// Generates a SKU string like "PRD-00001234".
String generateSku({String prefix = 'PRD', int? seed}) {
  final random = Random(seed);
  final number = random.nextInt(99999999);
  return '$prefix-${number.toString().padLeft(8, '0')}';
}

/// Returns a colour based on stock percentage.
/// 0–10%  → error (red)
/// 10–25% → warning (amber)
/// 25–50% → info (blue)
/// 50%+   → success (green)
Color getStockColor(double percentage) {
  if (percentage <= AppConstants.stockCriticalThreshold) {
    return AppColors.error;
  } else if (percentage <= AppConstants.stockLowThreshold) {
    return AppColors.warning;
  } else if (percentage <= AppConstants.stockWarningThreshold) {
    return AppColors.info;
  } else {
    return AppColors.success;
  }
}

/// Returns a human-readable stock status label.
String getStockLabel(double percentage) {
  if (percentage <= AppConstants.stockCriticalThreshold) return 'Critical';
  if (percentage <= AppConstants.stockLowThreshold) return 'Low';
  if (percentage <= AppConstants.stockWarningThreshold) return 'Warning';
  return 'Healthy';
}

/// Returns a colour for severity levels: critical, high, medium, low.
Color getSeverityColor(String severity) {
  switch (severity.toLowerCase()) {
    case 'critical':
      return AppColors.error;
    case 'high':
      return const Color(0xFFEF4444);
    case 'medium':
      return AppColors.warning;
    case 'low':
      return AppColors.info;
    default:
      return AppColors.textSecondary;
  }
}

/// Returns an icon for severity levels.
IconData getSeverityIcon(String severity) {
  switch (severity.toLowerCase()) {
    case 'critical':
      return Icons.error_rounded;
    case 'high':
      return Icons.warning_amber_rounded;
    case 'medium':
      return Icons.info_rounded;
    case 'low':
      return Icons.check_circle_rounded;
    default:
      return Icons.help_outline_rounded;
  }
}

/// Compact number formatting: 1.2K, 3.5L, 1.2Cr.
String compactNumber(num value) {
  if (value >= 10000000) return '${(value / 10000000).toStringAsFixed(1)}Cr';
  if (value >= 100000) return '${(value / 100000).toStringAsFixed(1)}L';
  if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
  return value.toStringAsFixed(value == value.toInt() ? 0 : 1);
}

/// Clamps a value to a range and maps it to 0..1.
double normalise(num value, num min, num max) {
  if (max == min) return 0;
  return ((value - min) / (max - min)).clamp(0.0, 1.0);
}
