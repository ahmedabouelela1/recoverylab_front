import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:sizer/sizer.dart';
import 'package:recoverylab_front/components/app_button.dart';
import 'package:recoverylab_front/components/app_textfield.dart';
import 'package:recoverylab_front/configurations/colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo + Welcome Back (left stacked)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'lib/assets/images/blueLogo.png',
                  width: 25.w,
                  height: 10.h,
                ),
                SizedBox(height: 1.5.h),
                Text(
                  "Welcome Back!",
                  style: GoogleFonts.inter(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5.h),

            AppTextField(
              label: "Email",
              hintText: "Enter your email",
              size: AppTextFieldSize.large,
              borderColor: AppColors.textFieldBorder,
              textColor: AppColors.textPrimary,
              fillColor: AppColors.textFieldBackground,
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
            ),

            SizedBox(height: 3.h),

            // Phone Number Field
            AppTextField(
              label: "Phone Number",
              hintText: "(454) 726-0592",
              size: AppTextFieldSize.large,
              controller: phoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: Padding(
                padding: EdgeInsets.all(2.w),
                child: Text("🇮🇩", style: TextStyle(fontSize: 16.sp)),
              ),
            ),

            SizedBox(height: 3.h),

            // Password Field
            AppTextField(
              label: "Password",
              hintText: "Enter your password",
              size: AppTextFieldSize.large,
              controller: passwordController,
              obscureText: obscurePassword,
              textColor: AppColors.textPrimary,
              borderColor: AppColors.textFieldBorder,
              fillColor: AppColors.textFieldBackground,
              suffixIcon: Icon(
                obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textSecondary,
              ),
              onSuffixTap: () {
                setState(() {
                  obscurePassword = !obscurePassword;
                });
              },
              debounceDuration: Duration(
                milliseconds: 500,
              ), // 👈 prevents spam-tapping
            ),

            // Forgot Password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: Text(
                  "Forgot your password?",
                  style: GoogleFonts.inter(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            SizedBox(height: 3.h),

            // Log In Button
            AppButton(
              label: "Log In",
              variant: AppButtonVariant.solid,
              width: 100.w,
              borderRadius: 30,
              padding: EdgeInsets.symmetric(vertical: 2.h),
              fontSize: 16.sp,
              onPressed: () {
                Navigator.pushNamed(context, Routes.otp);
              },
            ),
            SizedBox(height: 1.5.h),

            // Create account
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "New to Recovery Lab? ",
                  style: GoogleFonts.inter(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    print("Create account tapped");
                    Navigator.pushNamed(context, Routes.createAccount);
                  },
                  child: Text(
                    "Create account",
                    style: GoogleFonts.inter(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Continue as Guest
            GestureDetector(
              onTap: () {
                print("Continue as Guest tapped");
              },
              child: Center(
                child: Text(
                  "Continue as Guest",
                  style: GoogleFonts.inter(
                    fontSize: 14.5.sp,
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.textSecondary,
                  ),
                ),
              ),
            ),

            SizedBox(height: 4.h),

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
    );
  }
}
