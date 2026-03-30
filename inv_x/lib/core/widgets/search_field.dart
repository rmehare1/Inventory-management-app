import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onMicPressed,
    this.hintText = 'Search...',
    this.autofocus = false,
    this.showMicButton = false,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final VoidCallback? onMicPressed;
  final String hintText;
  final bool autofocus;
  final bool showMicButton;
  final bool enabled;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        autofocus: widget.autofocus,
        enabled: widget.enabled,
        style: AppTextStyles.bodyMedium,
        cursorColor: AppColors.primaryGradientStart,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textTertiary,
            size: 22,
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_hasText)
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged?.call('');
                    widget.onClear?.call();
                  },
                ),
              if (widget.showMicButton)
                IconButton(
                  icon: const Icon(
                    Icons.mic_none_rounded,
                    color: AppColors.textTertiary,
                    size: 22,
                  ),
                  onPressed: widget.onMicPressed,
                ),
            ],
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
