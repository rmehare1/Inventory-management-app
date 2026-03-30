import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Backgrounds
  static const background = Color(0xFF0A0A0F);
  static const surface = Color(0xFF12121A);
  static const card = Color(0xFF1A1A2E);
  static const cardHover = Color(0xFF1F1F35);

  // Primary gradient (purple → blue)
  static const primaryGradientStart = Color(0xFF7C3AED);
  static const primaryGradientEnd = Color(0xFF2563EB);

  // Secondary gradient (cyan → blue)
  static const secondaryGradientStart = Color(0xFF06B6D4);
  static const secondaryGradientEnd = Color(0xFF3B82F6);

  // Accent gradient (pink → orange)
  static const accentGradientStart = Color(0xFFEC4899);
  static const accentGradientEnd = Color(0xFFF97316);

  // Status colors
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  // Text colors
  static const textPrimary = Color(0xFFF1F5F9);
  static const textSecondary = Color(0xFF94A3B8);
  static const textTertiary = Color(0xFF64748B);
  static const textDisabled = Color(0xFF475569);

  // Border & divider
  static const border = Color(0xFF1E293B);
  static const divider = Color(0xFF1E293B);

  // Glass effect colors
  static const glassFill = Color(0x0DFFFFFF); // white 5%
  static const glassBorder = Color(0x1AFFFFFF); // white 10%
  static const glassHighlight = Color(0x33FFFFFF); // white 20%

  // Gradients
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGradientStart, primaryGradientEnd],
  );

  static const secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryGradientStart, secondaryGradientEnd],
  );

  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentGradientStart, accentGradientEnd],
  );

  static const surfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A2E), Color(0xFF12121A)],
  );

  static const shimmerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A1A2E),
      Color(0xFF252540),
      Color(0xFF1A1A2E),
    ],
  );
}
