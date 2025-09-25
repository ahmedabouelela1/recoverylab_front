import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../configurations/colors.dart';

enum AppButtonVariant { solid, stroke }

enum AppButtonIconPosition { left, right }

enum AppButtonSize { small, medium, large }

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final Color? color;
  final Color? textColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final double? fontSize;
  final IconData? icon;
  final AppButtonIconPosition iconPosition;
  final double? width;
  final Duration debounceDuration; // 👈 new

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.solid,
    this.size = AppButtonSize.medium,
    this.color,
    this.textColor,
    this.borderColor,
    this.padding,
    this.borderRadius,
    this.fontSize,
    this.icon,
    this.iconPosition = AppButtonIconPosition.left,
    this.width,
    this.debounceDuration = const Duration(milliseconds: 800), // default
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  // Default font sizes
  double _getFontSize() {
    if (widget.fontSize != null) return widget.fontSize!;
    switch (widget.size) {
      case AppButtonSize.small:
        return 10.sp;
      case AppButtonSize.medium:
        return 12.sp;
      case AppButtonSize.large:
        return 16.sp;
    }
  }

  // Default padding
  EdgeInsetsGeometry _getPadding() {
    if (widget.padding != null) return widget.padding!;
    switch (widget.size) {
      case AppButtonSize.small:
        return EdgeInsets.symmetric(vertical: 1.2.h, horizontal: 4.w);
      case AppButtonSize.medium:
        return EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 5.w);
      case AppButtonSize.large:
        return EdgeInsets.symmetric(vertical: 2.h, horizontal: 6.w);
    }
  }

  double _getRadius() => widget.borderRadius ?? 12;

  void _handlePress() {
    if (_isPressed || widget.onPressed == null) return;

    setState(() => _isPressed = true);

    widget.onPressed!();

    Future.delayed(widget.debounceDuration, () {
      if (mounted) {
        setState(() => _isPressed = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = widget.variant == AppButtonVariant.solid
        ? (widget.color ?? AppColors.primary)
        : Colors.transparent;

    final effectiveBorderColor = widget.borderColor ?? AppColors.primary;

    final labelColor =
        widget.textColor ??
        (widget.variant == AppButtonVariant.solid
            ? AppColors.secondary
            : effectiveBorderColor);

    final isDisabled = widget.onPressed == null;

    return SizedBox(
      width: widget.width,
      child: ElevatedButton(
        onPressed: isDisabled ? null : _handlePress,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled
              ? Colors.grey.shade400
              : buttonColor, // 👈 disabled color
          foregroundColor: labelColor,
          padding: _getPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_getRadius()),
          ),
          side: widget.variant == AppButtonVariant.stroke
              ? BorderSide(
                  color: isDisabled
                      ? Colors.grey.shade500
                      : effectiveBorderColor,
                  width: 1.5,
                )
              : BorderSide.none,
          elevation: 0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null &&
                widget.iconPosition == AppButtonIconPosition.left) ...[
              Icon(widget.icon, size: _getFontSize(), color: labelColor),
              SizedBox(width: 2.w),
            ],
            Text(
              widget.label,
              style: TextStyle(
                fontSize: _getFontSize(),
                fontWeight: FontWeight.w600,
                color: labelColor,
              ),
            ),
            if (widget.icon != null &&
                widget.iconPosition == AppButtonIconPosition.right) ...[
              SizedBox(width: 2.w),
              Icon(widget.icon, size: _getFontSize(), color: labelColor),
            ],
          ],
        ),
      ),
    );
  }
}
