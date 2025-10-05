// lib/views/user_view/bookings/widget/progress_indicator_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:recoverylab_front/configurations/colors.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepNames = const [
    "Book",
    "Booking Info",
    "Checkout",
    "Confirm",
  ];

  const ProgressIndicatorWidget({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(totalSteps, (index) {
            final stepNumber = index + 1;
            final isCompleted = stepNumber < currentStep;
            final isActive = stepNumber == currentStep;
            final color = isActive || isCompleted
                ? AppColors.primary
                : AppColors.textSecondary.withOpacity(0.5);

            return Expanded(
              child: Row(
                children: [
                  _buildStepCircle(stepNumber, color, isActive),
                  if (index < totalSteps - 1)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 1.w),
                        child: Divider(color: color, thickness: 2, height: 1),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        SizedBox(height: 1.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 1.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: stepNames.map((name) {
              final index = stepNames.indexOf(name) + 1;
              final color = index == currentStep
                  ? AppColors.primary
                  : AppColors.textSecondary;

              return Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: index == currentStep
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: color,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStepCircle(int stepNumber, Color color, bool isActive) {
    return Container(
      width: 5.w,
      height: 5.w,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Text(
          '$stepNumber',
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            color: isActive ? AppColors.textPrimary : color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
