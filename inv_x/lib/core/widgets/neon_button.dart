import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class NeonButton extends StatefulWidget {
  const NeonButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.gradient,
    this.glowColor,
    this.height = 52,
    this.borderRadius = 12,
    this.textStyle,
    this.isLoading = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Gradient? gradient;
  final Color? glowColor;
  final double height;
  final double borderRadius;
  final TextStyle? textStyle;
  final bool isLoading;
  final bool enabled;

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isActive => widget.enabled && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final effectiveGlowColor =
        widget.glowColor ?? AppColors.primaryGradientStart;

    return GestureDetector(
      onTapDown: _isActive ? (_) => _controller.forward() : null,
      onTapUp: _isActive
          ? (_) {
              _controller.reverse();
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: _isActive ? () => _controller.reverse() : null,
      child: AnimatedBuilder(
        listenable: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _isActive ? 1.0 : 0.5,
          child: Container(
            height: widget.height,
            decoration: BoxDecoration(
              gradient: widget.gradient ?? AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: _isActive
                  ? [
                      BoxShadow(
                        color: effectiveGlowColor.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: effectiveGlowColor.withValues(alpha: 0.2),
                        blurRadius: 40,
                        spreadRadius: 4,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.textPrimary),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, color: AppColors.textPrimary, size: 20),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.label,
                          style: widget.textStyle ??
                              AppTextStyles.labelLarge.copyWith(
                                color: AppColors.textPrimary,
                              ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Alias for AnimatedBuilder to keep compatibility.
class AnimatedBuilder extends AnimatedWidget {
  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
    this.child,
  });

  final TransitionBuilder builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) => builder(context, child);

  @override
  // ignore: override_on_non_overriding_member
  Animation<double> get listenable => super.listenable as Animation<double>;
}
