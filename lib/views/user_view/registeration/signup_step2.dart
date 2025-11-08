import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recoverylab_front/components/app_button.dart';
import 'package:recoverylab_front/components/app_textfield.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:sizer/sizer.dart';

class SignupStepTwo extends StatefulWidget {
  const SignupStepTwo({super.key});

  @override
  State<SignupStepTwo> createState() => _SignupStepTwoState();
}

class _SignupStepTwoState extends State<SignupStepTwo> {
  final TextEditingController dobController = TextEditingController();
  String? gender;
  bool athlete = false;
  String? location;

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
                      _dot(false),
                      SizedBox(width: 1.w),
                      _dot(true),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              Text(
                "Almost Complete",
                style: GoogleFonts.inter(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4.h),

              // Date of Birth
              AppTextField(
                label: "Date of birth",
                hintText: "Enter your date of birth",
                controller: dobController,
                size: AppTextFieldSize.large,
                borderColor: AppColors.textFieldBorder,
                fillColor: AppColors.textFieldBackground,
                suffixIcon: Icon(
                  Icons.calendar_today,
                  color: AppColors.textSecondary,
                ),
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      dobController.text =
                          "${picked.day}/${picked.month}/${picked.year}";
                    });
                  }
                },
              ),
              SizedBox(height: 2.5.h),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Gender",
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6), // spacing between label & field
                  DropdownButtonFormField<String>(
                    dropdownColor: AppColors.background,
                    style: GoogleFonts.inter(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.textFieldBackground,
                      hintText: "Select your gender",
                      hintStyle: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: ["Male", "Female"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => gender = val),
                  ),
                ],
              ),

              SizedBox(height: 2.5.h),

              // Location Options
              Text(
                "Choose your location",
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 1.h),
              Row(
                children: [
                  _locationCard("Sheikh Zayed", 'lib/assets/images/zayed.png'),
                  SizedBox(width: 3.w),
                  _locationCard("New Cairo", 'lib/assets/images/newCairo.png'),
                ],
              ),
              SizedBox(height: 4.h),

              // Continue Button
              AppButton(
                label: "Continue",
                variant: AppButtonVariant.solid,
                width: 100.w,
                borderRadius: 30,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                fontSize: 16.sp,
                onPressed: () {
                  // Next action
                  Navigator.pushNamed(context, Routes.otpSignup);
                },
              ),
              SizedBox(height: 4.h),

              // Footer
              _footerText(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(bool active) => Container(
    width: 12,
    height: 12,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: active ? AppColors.primary : AppColors.textSecondary,
    ),
  );

  Widget _locationCard(String title, String imagePath) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => location = title),
        child: Container(
          height: 12.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: location == title
                  ? AppColors.primary
                  : AppColors.textSecondary.withOpacity(0.3),
            ),
            image: DecorationImage(
              image: AssetImage(imagePath), // 👈 dynamic image now
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _footerText() {
    return Text.rich(
      TextSpan(
        text: "By using Recovery Lab, you agree to the ",
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          color: AppColors.textSecondary,
        ),
        children: [
          TextSpan(
            text: "Terms ",
            style: TextStyle(color: AppColors.secondary),
          ),
          const TextSpan(text: "and "),
          TextSpan(
            text: "Privacy Policy.",
            style: TextStyle(color: AppColors.secondary),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
