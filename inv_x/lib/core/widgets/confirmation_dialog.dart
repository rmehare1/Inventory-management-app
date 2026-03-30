import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.confirmColor,
    this.icon,
    this.isDestructive = false,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final Color? confirmColor;
  final IconData? icon;
  final bool isDestructive;

  /// Shows the dialog and returns true if confirmed, false otherwise.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    Color? confirmColor,
    IconData? icon,
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => ConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        confirmColor: confirmColor,
        icon: icon,
        isDestructive: isDestructive,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveConfirmColor =
        confirmColor ?? (isDestructive ? AppColors.error : AppColors.primaryGradientStart);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: effectiveConfirmColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: effectiveConfirmColor,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                title,
                style: AppTextStyles.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(cancelLabel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: effectiveConfirmColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(confirmLabel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
