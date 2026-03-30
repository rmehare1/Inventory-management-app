import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppDecorations {
  AppDecorations._();

  /// Standard glassmorphism card decoration.
  static BoxDecoration glassCard({
    double borderRadius = 16,
    Color? borderColor,
    double borderOpacity = 0.1,
    double fillOpacity = 0.05,
  }) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: fillOpacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? Colors.white.withValues(alpha: borderOpacity),
      ),
    );
  }

  /// Glass card with a subtle gradient border.
  static BoxDecoration glassCardGradientBorder({
    double borderRadius = 16,
    Gradient? gradient,
    double fillOpacity = 0.05,
  }) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: fillOpacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: Colors.transparent),
      gradient: null,
    );
  }

  /// Container decoration that renders a gradient border using a
  /// foreground `DecoratedBox` layered on a gradient background.
  /// Usage: wrap two containers — outer with gradientBorderOuter,
  /// inner with gradientBorderInner and 1px margin.
  static BoxDecoration gradientBorderOuter({
    double borderRadius = 16,
    Gradient? gradient,
  }) {
    return BoxDecoration(
      gradient: gradient ?? AppColors.primaryGradient,
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  static BoxDecoration gradientBorderInner({
    double borderRadius = 15,
    Color? fillColor,
  }) {
    return BoxDecoration(
      color: fillColor ?? AppColors.card,
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  /// Neon glow box shadow — typically applied to buttons or active cards.
  static List<BoxShadow> neonGlow({
    Color? color,
    double blurRadius = 20,
    double spreadRadius = 2,
    double opacity = 0.4,
  }) {
    final glowColor = color ?? AppColors.primaryGradientStart;
    return [
      BoxShadow(
        color: glowColor.withValues(alpha: opacity),
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
      ),
    ];
  }

  /// Subtle elevation shadow for elevated cards.
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  /// Input field decoration with glass effect.
  static BoxDecoration inputField({double borderRadius = 12}) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.1),
      ),
    );
  }

  /// Gradient chip / badge decoration.
  static BoxDecoration gradientBadge({
    Gradient? gradient,
    double borderRadius = 20,
  }) {
    return BoxDecoration(
      gradient: gradient ?? AppColors.primaryGradient,
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  /// Status indicator dot decoration.
  static BoxDecoration statusDot(Color color) {
    return BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.4),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ],
    );
  }
}
