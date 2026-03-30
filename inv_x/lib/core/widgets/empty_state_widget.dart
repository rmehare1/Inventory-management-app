import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'gradient_button.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconSize = 64,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double iconSize;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: iconSize + 32,
              height: iconSize + 32,
              decoration: BoxDecoration(
                color: AppColors.card,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: iconColor ?? AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              GradientButton(
                label: actionLabel!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
