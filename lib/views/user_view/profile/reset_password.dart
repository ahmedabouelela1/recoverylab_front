import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/components/app_button.dart';
import 'package:recoverylab_front/components/app_textfield.dart';
// Assuming AppTextFieldSize is an enum defined somewhere accessible
// enum AppTextFieldSize { small, large }

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _currentPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;

  Widget _buildPasswordField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 3.h,
      ), // Increased bottom margin for separation between fields
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Increased Label Font Size
          // Text(
          //   label,
          //   style: GoogleFonts.inter(
          //     fontSize: 15.sp, // Increased from 14.sp to 16.sp
          //     color: AppColors.textPrimary,
          //     fontWeight: FontWeight.w500,
          //   ),
          // ),

          // 2. REMOVED SizedBox(height: X.h) to minimize gap

          // AppTextField matching the visual style of the screenshot
          AppTextField(
            label: label,
            hintText: hintText,
            controller: controller,
            obscureText: !isVisible,

            // Applying styling and size from the LoginPage pattern
            size: AppTextFieldSize.large,
            borderColor: AppColors.textFieldBorder,
            textColor: AppColors.textPrimary,
            fillColor: AppColors.textFieldBackground,

            // Applying suffix icon pattern for visibility toggle
            suffixIcon: Icon(
              isVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.textSecondary,
            ),
            onSuffixTap: onToggle,
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (_currentPasswordController.text.isEmpty) {
      _showError("Please enter your current password");
      return;
    }
    if (_newPasswordController.text.length < 6) {
      _showError("New password must be at least 6 characters long");
      return;
    }
    if (_confirmPasswordController.text != _newPasswordController.text) {
      _showError("Passwords do not match");
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Password reset successful!")));
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Reset Password",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
        child: Column(
          children: [
            _buildPasswordField(
              label: "Current Password",
              hintText: "Enter current password",
              controller: _currentPasswordController,
              isVisible: _currentPasswordVisible,
              onToggle: () {
                setState(() {
                  _currentPasswordVisible = !_currentPasswordVisible;
                });
              },
            ),
            _buildPasswordField(
              label: "New Password",
              hintText: "Enter new password",
              controller: _newPasswordController,
              isVisible: _newPasswordVisible,
              onToggle: () {
                setState(() {
                  _newPasswordVisible = !_newPasswordVisible;
                });
              },
            ),
            _buildPasswordField(
              label: "Confirm Password",
              hintText: "Re-enter new password",
              controller: _confirmPasswordController,
              isVisible: _confirmPasswordVisible,
              onToggle: () {
                setState(() {
                  _confirmPasswordVisible = !_confirmPasswordVisible;
                });
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: "Submit",
                onPressed: _submit,
                size: AppButtonSize.large,
                color: AppColors.primary,
                borderRadius: 12,
              ),
            ),
            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }
}
