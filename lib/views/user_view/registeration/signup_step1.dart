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
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  // State variable for the profile image path (or File object)
  String? _profileImagePath;

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

              // --- PROFILE PICTURE PICKER START ---
              Center(child: _buildProfilePicturePicker()),
              SizedBox(height: 4.h),
              // --- PROFILE PICTURE PICKER END ---

              // First Name
              AppTextField(
                label: "First Name",
                hintText: "Enter your first name",
                controller: firstNameController,
                size: AppTextFieldSize.large,
                borderColor: AppColors.textFieldBorder,
                fillColor: AppColors.textFieldBackground,
                textColor: AppColors.textPrimary,
              ),
              SizedBox(height: 2.5.h),
              // Last Name
              AppTextField(
                label: "Last Name",
                hintText: "Enter your last name",
                controller: lastNameController,
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

  // Helper function to show the modal bottom sheet
  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement logic to pick image from gallery
                  print('Pick image from Gallery');
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement logic to take photo with camera
                  print('Take photo with Camera');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfilePicturePicker() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 10.w, // Adjust size as needed
          backgroundColor: AppColors.textSecondary.withOpacity(0.5),
          // Use a placeholder if no image is selected, otherwise use the image
          child: _profileImagePath == null
              ? Icon(Icons.person, size: 10.w, color: AppColors.background)
              : null, // Replace null with Image.file(_profileImagePath!)
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            // CALL THE POP-UP METHOD HERE
            onTap: _showImageSourceOptions,
            child: Container(
              padding: EdgeInsets.all(1.w),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 2),
              ),
              child: Icon(Icons.add_a_photo, size: 4.w, color: Colors.white),
            ),
          ),
        ),
      ],
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
