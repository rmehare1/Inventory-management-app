import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    this.prefix = '₹',
    this.suffix = '',
    this.duration = const Duration(milliseconds: 800),
    this.textStyle,
    this.curve = Curves.easeOutCubic,
    this.decimalPlaces = 0,
  });

  final double value;
  final String prefix;
  final String suffix;
  final Duration duration;
  final TextStyle? textStyle;
  final Curve curve;
  final int decimalPlaces;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: duration,
      curve: curve,
      builder: (context, animatedValue, child) {
        String formatted;
        if (decimalPlaces > 0) {
          formatted = animatedValue.toStringAsFixed(decimalPlaces);
        } else {
          formatted = _formatWithCommas(animatedValue.toInt());
        }
        return Text(
          '$prefix$formatted$suffix',
          style: textStyle ?? AppTextStyles.numberLarge,
        );
      },
    );
  }

  /// Formats an integer with Indian-style commas: 1,23,456.
  String _formatWithCommas(int value) {
    if (value < 0) return '-${_formatWithCommas(-value)}';
    final str = value.toString();
    if (str.length <= 3) return str;

    final last3 = str.substring(str.length - 3);
    final remaining = str.substring(0, str.length - 3);
    final buffer = StringBuffer();
    for (var i = 0; i < remaining.length; i++) {
      if (i > 0 && (remaining.length - i) % 2 == 0) {
        buffer.write(',');
      }
      buffer.write(remaining[i]);
    }
    return '$buffer,$last3';
  }
}
