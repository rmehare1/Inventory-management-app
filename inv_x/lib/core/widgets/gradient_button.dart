import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.gradient,
    this.height = 50,
    this.width,
    this.borderRadius = 12,
    this.textStyle,
    this.isLoading = false,
    this.enabled = true,
    this.padding,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Gradient? gradient;
  final double height;
  final double? width;
  final double borderRadius;
  final TextStyle? textStyle;
  final bool isLoading;
  final bool enabled;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isActive = enabled && !isLoading;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isActive ? 1.0 : 0.5,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: gradient ?? AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: ElevatedButton(
          onPressed: isActive ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            padding: padding ??
                const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: AppColors.textPrimary, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: textStyle ??
                          AppTextStyles.labelLarge.copyWith(
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
