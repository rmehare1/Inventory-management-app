import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SnackbarHelper {
  SnackbarHelper._();

  static void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle_rounded,
      color: AppColors.success,
    );
  }

  static void showError(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.error_rounded,
      color: AppColors.error,
    );
  }

  static void showWarning(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.warning_amber_rounded,
      color: AppColors.warning,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.info_rounded,
      color: AppColors.info,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color color,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.card,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: color.withValues(alpha: 0.3)),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          duration: duration,
          dismissDirection: DismissDirection.horizontal,
        ),
      );
  }
}
