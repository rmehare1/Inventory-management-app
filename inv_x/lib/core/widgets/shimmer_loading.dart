import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.child,
  });

  final double? width;
  final double? height;
  final double borderRadius;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.card,
      highlightColor: AppColors.cardHover,
      child: child ??
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
    );
  }
}

/// Convenience builder for a list of shimmer placeholders.
class ShimmerList extends StatelessWidget {
  const ShimmerList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.spacing = 12,
    this.padding,
  });

  final int itemCount;
  final double itemHeight;
  final double spacing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(
          itemCount,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: spacing),
            child: ShimmerLoading(
              width: double.infinity,
              height: itemHeight,
              borderRadius: 16,
            ),
          ),
        ),
      ),
    );
  }
}
