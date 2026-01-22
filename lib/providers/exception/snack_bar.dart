import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AppSnackBar {
  static void show(
    BuildContext context,
    String message, {
    Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontSize: 14.sp)),
        backgroundColor: backgroundColor ?? Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(3.w),
      ),
    );
  }
}
