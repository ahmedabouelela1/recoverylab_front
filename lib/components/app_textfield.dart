import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../configurations/colors.dart';

enum AppTextFieldSize { small, medium, large }

class AppTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onSuffixTap;
  final VoidCallback? onTap; // 👈 NEW
  final TextInputType keyboardType;
  final AppTextFieldSize size;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? fillColor;
  final Color? borderColor;
  final Color? textColor;
  final double? fontSize;
  final Duration debounceDuration;

  const AppTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.onTap, // 👈 NEW
    this.keyboardType = TextInputType.text,
    this.size = AppTextFieldSize.medium,
    this.borderRadius,
    this.padding,
    this.fillColor,
    this.borderColor,
    this.textColor,
    this.fontSize,
    this.debounceDuration = const Duration(milliseconds: 400),
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _isSuffixTapped = false;

  // Default font size per size
  double _getFontSize() {
    if (widget.fontSize != null) return widget.fontSize!;
    switch (widget.size) {
      case AppTextFieldSize.small:
        return 12.sp;
      case AppTextFieldSize.medium:
        return 14.sp;
      case AppTextFieldSize.large:
        return 16.sp;
    }
  }

  // Default padding per size
  EdgeInsetsGeometry _getPadding() {
    if (widget.padding != null) return widget.padding!;
    switch (widget.size) {
      case AppTextFieldSize.small:
        return EdgeInsets.symmetric(vertical: 1.2.h, horizontal: 3.w);
      case AppTextFieldSize.medium:
        return EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 4.w);
      case AppTextFieldSize.large:
        return EdgeInsets.symmetric(vertical: 2.h, horizontal: 5.w);
    }
  }

  double _getRadius() => widget.borderRadius ?? 12;

  void _handleSuffixTap() {
    if (_isSuffixTapped || widget.onSuffixTap == null) return;

    setState(() => _isSuffixTapped = true);
    widget.onSuffixTap!();

    Future.delayed(widget.debounceDuration, () {
      if (mounted) setState(() => _isSuffixTapped = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = widget.textColor ?? AppColors.textPrimary;
    final effectiveBorderColor =
        widget.borderColor ?? AppColors.textFieldBorder;
    final effectiveFillColor =
        widget.fillColor ?? AppColors.textFieldBackground;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        TextField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          onTap: widget.onTap, // 👈 this enables onTap
          style: TextStyle(color: effectiveTextColor, fontSize: _getFontSize()),
          decoration: InputDecoration(
            contentPadding: _getPadding(),
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.7),
              fontSize: _getFontSize(),
            ),
            filled: true,
            fillColor: effectiveFillColor,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon != null
                ? GestureDetector(
                    onTap: _handleSuffixTap,
                    child: widget.suffixIcon,
                  )
                : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_getRadius()),
              borderSide: BorderSide(color: effectiveBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_getRadius()),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
