import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recoverylab_front/components/app_button.dart';
import 'package:recoverylab_front/components/app_textfield.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:sizer/sizer.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo + Page Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'lib/assets/images/blueLogo.png',
                    width: 20.w,
                    height: 10.h,
                  ),
                  Row(
                    children: [
                      _dot(true),
                      SizedBox(width: 1.w),
                      _dot(false),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              Text(
                "Let's Get Started!",
                style: GoogleFonts.inter(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4.h),

              // Name
              AppTextField(
                label: "Name",
                hintText: "Enter your full name",
                controller: nameController,
                size: AppTextFieldSize.large,
                borderColor: AppColors.textFieldBorder,
                fillColor: AppColors.textFieldBackground,
                textColor: AppColors.textPrimary,
              ),
              SizedBox(height: 2.5.h),

              // Email
              AppTextField(
                label: "Email",
                hintText: "Enter your email",
                controller: emailController,
                size: AppTextFieldSize.large,
                borderColor: AppColors.textFieldBorder,
                fillColor: AppColors.textFieldBackground,
                textColor: AppColors.textPrimary,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 2.5.h),

              // Phone Number
              AppTextField(
                label: "Phone Number",
                hintText: "(454) 726-0592",
                controller: phoneController,
                size: AppTextFieldSize.large,
                keyboardType: TextInputType.phone,
                prefixIcon: Padding(
                  padding: EdgeInsets.all(2.w),
                  child: Text("🇮🇩", style: TextStyle(fontSize: 16.sp)),
                ),
              ),
              SizedBox(height: 2.5.h),

              // Password
              AppTextField(
                label: "Password",
                hintText: "Enter your password",
                controller: passwordController,
                obscureText: obscurePassword,
                size: AppTextFieldSize.large,
                borderColor: AppColors.textFieldBorder,
                fillColor: AppColors.textFieldBackground,
                textColor: AppColors.textPrimary,
                suffixIcon: Icon(
                  obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textSecondary,
                ),
                onSuffixTap: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    "Forgot your password?",
                    style: GoogleFonts.inter(
                      fontSize: 12.5.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 2.5.h),

              // Continue Button
              AppButton(
                label: "Continue",
                variant: AppButtonVariant.solid,
                width: 100.w,
                borderRadius: 30,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                fontSize: 16.sp,
                onPressed: () {
                  Navigator.pushNamed(context, Routes.signupStepTwo);
                },
              ),
              SizedBox(height: 2.h),

              // Already have account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already part of the Recovery Lab family? ",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      "Log In",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.5.h),

              // Continue as Guest
              GestureDetector(
                onTap: () {},
                child: Center(
                  child: Text(
                    "Continue as Guest",
                    style: GoogleFonts.inter(
                      fontSize: 14.5.sp,
                      color: AppColors.textSecondary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 6.h),

              // Footer
              _footerText(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(bool active) => Container(
    width: 3.w,
    height: 3.h,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: active ? AppColors.primary : AppColors.textSecondary,
    ),
  );

  Widget _footerText() {
    return // Terms and Privacy
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
    );
  }
}
