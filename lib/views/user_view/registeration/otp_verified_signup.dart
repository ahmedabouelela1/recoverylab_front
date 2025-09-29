import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:sizer/sizer.dart';

class OtpVerifiedPageSignup extends StatefulWidget {
  const OtpVerifiedPageSignup({super.key});

  @override
  State<OtpVerifiedPageSignup> createState() => _OtpVerifiedPageSignupState();
}

class _OtpVerifiedPageSignupState extends State<OtpVerifiedPageSignup> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // ✅ Navigate after short delay (2s) to Question 1
    _timer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(Routes.questionnaireStepOne);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Column(
              children: [
                Image.asset(
                  'lib/assets/images/otp.png',
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 16),
                Text(
                  "Your Code\nis Successfully Verified!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              child: Text.rich(
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
            ),
          ],
        ),
      ),
    );
  }
}
