import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recoverylab_front/components/app_button.dart';
// import 'package:recoverylab_front/components/app_textfield.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:sizer/sizer.dart';

class WellnessQuestionPageTwo extends StatefulWidget {
  const WellnessQuestionPageTwo({super.key});

  @override
  State<WellnessQuestionPageTwo> createState() =>
      _WellnessQuestionPageTwoState();
}

class _WellnessQuestionPageTwoState extends State<WellnessQuestionPageTwo> {
  String? selectedOption;

  final List<String> options = [
    "Yes, I'm a regular",
    "Yes, occasionally",
    "I've tried once or twice",
    "No, this is my first time",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          "Question 2/2",
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question
            Text(
              "Have you visited a recovery spa before?",
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),

            // Options
            Expanded(
              child: ListView.separated(
                itemCount: options.length,
                separatorBuilder: (_, __) => SizedBox(height: 1.5.h),
                itemBuilder: (context, index) {
                  final option = options[index];
                  return GestureDetector(
                    onTap: () => setState(() => selectedOption = option),
                    child: Container(
                      height: 8.h, // 👈 Fixed uniform height
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectedOption == option
                              ? AppColors.primary
                              : AppColors.textSecondary.withOpacity(0.4),
                        ),
                        color: AppColors.background,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              option,
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Radio<String>(
                            value: option,
                            groupValue: selectedOption,
                            activeColor: AppColors.primary,
                            onChanged: (val) {
                              setState(() => selectedOption = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Continue Button
            AppButton(
              label: "Continue",
              variant: AppButtonVariant.solid,
              width: 100.w,
              borderRadius: 30,
              padding: EdgeInsets.symmetric(vertical: 2.h),
              fontSize: 16.sp,
              onPressed: () {
                if (selectedOption != null) {
                  // ✅ after Q2 -> go to dashboard or main app flow
                  Navigator.pushReplacementNamed(context, Routes.style);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
