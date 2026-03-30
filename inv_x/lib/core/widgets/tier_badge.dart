import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_constants.dart';

class TierBadge extends StatelessWidget {
  const TierBadge({
    super.key,
    required this.tier,
    this.compact = false,
  });

  final String tier;
  final bool compact;

  Color get _color {
    switch (tier.toUpperCase()) {
      case AppConstants.aiTierLocal:
        return AppColors.success;
      case AppConstants.aiTierFree:
        return AppColors.info;
      case AppConstants.aiTierPaid:
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData get _icon {
    switch (tier.toUpperCase()) {
      case AppConstants.aiTierLocal:
        return Icons.smartphone_rounded;
      case AppConstants.aiTierFree:
        return Icons.cloud_outlined;
      case AppConstants.aiTierPaid:
        return Icons.diamond_outlined;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, color: color, size: compact ? 12 : 14),
          SizedBox(width: compact ? 3 : 5),
          Text(
            tier.toUpperCase(),
            style: (compact ? AppTextStyles.overline : AppTextStyles.labelSmall)
                .copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
