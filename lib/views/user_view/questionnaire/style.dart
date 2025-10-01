import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recoverylab_front/components/app_button.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:sizer/sizer.dart';

class ServicesSelectionPage extends StatefulWidget {
  const ServicesSelectionPage({super.key});

  @override
  State<ServicesSelectionPage> createState() => _ServicesSelectionPageState();
}

class _ServicesSelectionPageState extends State<ServicesSelectionPage> {
  // Options
  final List<String> options = [
    "Sports Massage",
    "Deep Tissue Massage",
    "Prenatal Massage",
    "Sauna / Steam Room",
    "Cupping Therapy",
    "IV Drips",
    "Moroccan Bath",
  ];

  // Track selected ones
  final Set<String> selectedOptions = {};

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
          "Style",
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
            // Question (Centered)
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Which services are you most\ninterested in?",
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    "You can choose more than one.",
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: 4.h),

            // Options
            Expanded(
              child: ListView.separated(
                itemCount: options.length,
                separatorBuilder: (_, __) => SizedBox(height: 1.5.h),
                itemBuilder: (context, index) {
                  final option = options[index];
                  final isSelected = selectedOptions.contains(option);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedOptions.remove(option);
                        } else {
                          selectedOptions.add(option);
                        }
                      });
                    },
                    child: Container(
                      height: 8.h,
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary.withOpacity(0.4),
                        ),
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.1)
                            : AppColors.background,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              option,
                              style: GoogleFonts.inter(
                                fontSize: 15.sp,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Checkbox(
                            value: isSelected,
                            activeColor: AppColors.primary,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  selectedOptions.add(option);
                                } else {
                                  selectedOptions.remove(option);
                                }
                              });
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
                if (selectedOptions.isNotEmpty) {
                  // ✅ Move forward, e.g., to main screen
                  Navigator.pushReplacementNamed(context, Routes.mainScreen);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
