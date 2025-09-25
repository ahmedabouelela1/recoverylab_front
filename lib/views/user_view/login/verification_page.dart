import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:sizer/sizer.dart';
import 'package:recoverylab_front/components/app_button.dart';
import 'package:recoverylab_front/configurations/colors.dart';

class Otp extends StatefulWidget {
  const Otp({super.key});

  @override
  State<Otp> createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  final List<TextEditingController> _otpControllers = List.generate(
    5,
    (index) => TextEditingController(),
  );

  bool get isOtpComplete =>
      _otpControllers.every((controller) => controller.text.isNotEmpty);

  @override
  void dispose() {
    for (var c in _otpControllers) {
      c.dispose();
    }
    super.dispose();
  }

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
          "Enter Verification Code",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtitle
              SizedBox(
                width: double.infinity,
                child: Text(
                  "We just sent a 5-digit code to\n+20-10-xxxx-xxxx, enter it below:",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height:
                        1.4, // 👈 increases line spacing (1.0 = tight, higher = looser)
                  ),
                ),
              ),

              SizedBox(height: 4.h),

              // OTP input fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  return SizedBox(
                    width: 14.w,
                    height: 8.h,
                    child: TextField(
                      controller: _otpControllers[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      onChanged: (val) {
                        setState(() {}); // refresh button state
                        if (val.isNotEmpty && index < 4) {
                          FocusScope.of(context).nextFocus();
                        }
                      },
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        filled: true,
                        fillColor: AppColors.textSecondary.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),

              SizedBox(height: 4.h),

              // Verify button using AppButton
              AppButton(
                label: "Verify code",
                variant: AppButtonVariant.solid,
                width: 100.w,
                borderRadius: 30,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                fontSize: 16.sp,
                onPressed: isOtpComplete
                    ? () {
                        final code = _otpControllers.map((c) => c.text).join();
                        print("Entered OTP: $code");
                        Navigator.pushNamed(context, Routes.otpVerified);
                      }
                    : null, // disables when not complete
              ),

              SizedBox(height: 2.h),

              // Wrong number link
              Center(
                child: GestureDetector(
                  onTap: () {
                    // resend to different number
                  },
                  child: RichText(
                    textAlign: TextAlign.center, // 👈 keep centered if needed
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        color: AppColors
                            .textSecondary, // 👈 base style for the first part
                      ),
                      children: [
                        const TextSpan(text: "Wrong number? "), // normal
                        TextSpan(
                          text: "Send to different number", // styled part
                          style: TextStyle(
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // 👈 handle tap here
                              print("Send to different number tapped");
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Footer
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
    );
  }
}
