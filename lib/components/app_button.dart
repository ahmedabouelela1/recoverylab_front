import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../configurations/colors.dart';

enum AppButtonVariant { solid, stroke }

enum AppButtonIconPosition { left, right }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final AppButtonVariant variant;
  final Color? color;
  final Color? textColor;
  final Color? borderColor; // for stroke variant border customization
  final EdgeInsetsGeometry? padding; // 👈 customizable padding
  final double borderRadius; // 👈 customizable corner radius
  final double fontSize;
  final IconData? icon;
  final AppButtonIconPosition iconPosition;
  final double? width; // 👈 NEW (null = auto, number = fixed, infinity = full)

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.solid,
    this.color,
    this.textColor,
    this.borderColor,
    this.padding,
    this.borderRadius = 12,
    this.fontSize = 16,
    this.icon,
    this.iconPosition = AppButtonIconPosition.left,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = variant == AppButtonVariant.solid
        ? (color ?? AppColors.primary)
        : Colors.transparent;

    final effectiveBorderColor = borderColor ?? AppColors.primary;

    final labelColor =
        textColor ??
        (variant == AppButtonVariant.solid
            ? AppColors.secondary
            : effectiveBorderColor);

    return SizedBox(
      width:
          width, // 👈 if null → auto, if set → fixed, if double.infinity → full width
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor, // solid or transparent
          foregroundColor: labelColor,
          padding:
              padding ??
              const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          side: variant == AppButtonVariant.stroke
              ? BorderSide(color: effectiveBorderColor, width: 1.5)
              : BorderSide.none,
          elevation: 0, // flat for stroke
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null && iconPosition == AppButtonIconPosition.left) ...[
              Icon(icon, size: fontSize.sp, color: labelColor),
              SizedBox(width: 2.w),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize.sp,
                fontWeight: FontWeight.w600,
                color: labelColor,
              ),
            ),
            if (icon != null &&
                iconPosition == AppButtonIconPosition.right) ...[
              SizedBox(width: 2.w),
              Icon(icon, size: fontSize.sp, color: labelColor),
            ],
          ],
        ),
      ),
    );
  }
}
