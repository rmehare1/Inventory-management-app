import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.textStyle,
    this.icon,
    this.padding,
  });

  final String label;
  final Color color;
  final TextStyle? textStyle;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: textStyle ??
                AppTextStyles.labelSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
          ),
        ],
      ),
    );
  }
}
