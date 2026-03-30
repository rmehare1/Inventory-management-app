import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'gradient_text.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.useGradientTitle = false,
    this.actions,
    this.leading,
    this.showBackButton = false,
    this.onBackPressed,
    this.bottom,
    this.elevation = 0,
    this.enableGlassEffect = true,
    this.titleWidget,
  });

  final String title;
  final bool useGradientTitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final PreferredSizeWidget? bottom;
  final double elevation;
  final bool enableGlassEffect;
  final Widget? titleWidget;

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    final titleContent = titleWidget ??
        (useGradientTitle
            ? GradientText(
                title,
                style: AppTextStyles.titleLarge,
                gradient: AppColors.primaryGradient,
              )
            : Text(title, style: AppTextStyles.titleLarge));

    final effectiveLeading = leading ??
        (showBackButton
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                ),
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              )
            : null);

    if (!enableGlassEffect) {
      return AppBar(
        title: titleContent,
        leading: effectiveLeading,
        actions: actions,
        bottom: bottom,
        elevation: elevation,
        backgroundColor: Colors.transparent,
      );
    }

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.8),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          child: AppBar(
            title: titleContent,
            leading: effectiveLeading,
            actions: actions,
            bottom: bottom,
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
        ),
      ),
    );
  }
}
