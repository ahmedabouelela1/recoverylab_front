import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recoverylab_front/components/app_button.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:sizer/sizer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          "Log into account",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true, // 👈 this centers it properly
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          child: SizedBox(
            width: double.infinity, // 👈 this fixes the left shift
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 2.h),
                Text(
                  "Welcome Back !",
                  style: GoogleFonts.inter(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  "Let’s continue recovery journey. ",
                  style: GoogleFonts.inter(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 6.h),

                // Next / Get Started → AppButton solid variant
                AppButton(
                  label: "Continue with Email",
                  variant: AppButtonVariant.solid,
                  color: AppColors.primary,
                  textColor: AppColors.secondary,
                  borderRadius: 28,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  fontSize:
                      16, // normal double, inside AppButton it becomes 16.sp
                  width: double.infinity, // 👈 full width, same as 100.w
                  onPressed: () {
                    // Navigate to LoginPage
                    Navigator.pushNamed(context, Routes.loginPage);
                  },
                ),

                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppColors.textSecondary.withValues(alpha: 0.3),
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      child: Text(
                        'or',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppColors.textSecondary.withValues(alpha: 0.3),
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                AppButton(
                  label: "Continue with Apple",
                  variant: AppButtonVariant.stroke,
                  color: AppColors.primary,
                  textColor: AppColors.secondary,
                  borderRadius: 19,
                  fontSize:
                      16, // keep in "normal double", inside the button it’s converted to sp
                  borderColor: AppColors.secondary,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  icon: FontAwesomeIcons.apple, // 👈 from package
                  width: double.infinity, // full width, same as 100.w
                  onPressed: () {},
                ),

                SizedBox(height: 1.5.h),

                AppButton(
                  label: "Continue with Google",
                  variant: AppButtonVariant.stroke,
                  color: AppColors.primary,
                  textColor: AppColors.secondary,
                  borderRadius: 19,
                  icon: FontAwesomeIcons.google, // 👈 from package
                  fontSize:
                      16, // keep in "normal double", inside the button it’s converted to sp
                  borderColor: AppColors.secondary,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  width: double.infinity, // full width, same as 100.w
                  onPressed: () {},
                ),
                SizedBox(height: 1.5.h),
                AppButton(
                  label: "Continue with Facebook",
                  variant: AppButtonVariant.stroke,
                  color: AppColors.primary,
                  textColor: AppColors.secondary,
                  borderRadius: 19,
                  fontSize:
                      16, // keep in "normal double", inside the button it’s converted to sp
                  borderColor: AppColors.secondary,
                  icon: FontAwesomeIcons.facebook, // 👈 from package
                  padding: EdgeInsets.symmetric(vertical: 16),
                  width: double.infinity, // full width, same as 100.w
                  onPressed: () {},
                ),

                const Spacer(),

                // Terms and Privacy
                Text.rich(
                  TextSpan(
                    text: "By using Recovery Lab, you agree to the ",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      TextSpan(
                        text: "Terms ",
                        style: TextStyle(color: AppColors.primary),
                      ),
                      const TextSpan(text: "and "),
                      TextSpan(
                        text: "Privacy Policy.",
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
