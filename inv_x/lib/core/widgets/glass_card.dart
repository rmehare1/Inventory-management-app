import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.fillOpacity = 0.05,
    this.borderOpacity = 0.1,
    this.blurAmount = 10,
    this.onTap,
    this.gradientBorderColor,
    this.width,
    this.height,
  });

  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double fillOpacity;
  final double borderOpacity;
  final double blurAmount;
  final VoidCallback? onTap;
  final Color? gradientBorderColor;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final card = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: blurAmount,
          sigmaY: blurAmount,
        ),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: fillOpacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: gradientBorderColor?.withValues(alpha: borderOpacity) ??
                  Colors.white.withValues(alpha: borderOpacity),
            ),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );

    final Widget result = margin != null
        ? Padding(padding: margin!, child: card)
        : card;

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: result,
      );
    }

    return result;
  }
}

/// A variant that wraps GlassCard with a gradient border effect
/// by layering two containers.
class GlassCardGradientBorder extends StatelessWidget {
  const GlassCardGradientBorder({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.borderWidth = 1.5,
    this.gradient,
    this.onTap,
  });

  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double borderWidth;
  final Gradient? gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Container(
        margin: EdgeInsets.all(borderWidth),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(borderRadius - borderWidth),
        ),
        padding: padding,
        child: child,
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: card,
      );
    }

    return card;
  }
}
