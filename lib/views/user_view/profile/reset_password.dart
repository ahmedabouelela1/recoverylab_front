import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/components/app_button.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // Simple strength checker
  int _strength(String pw) {
    int score = 0;
    if (pw.length >= 8) score++;
    if (pw.contains(RegExp(r'[A-Z]'))) score++;
    if (pw.contains(RegExp(r'[0-9]'))) score++;
    if (pw.contains(RegExp(r'[!@#\$%^&*]'))) score++;
    return score;
  }

  Color _strengthColor(int s) {
    if (s <= 1) return AppColors.error;
    if (s == 2) return AppColors.warning;
    if (s == 3) return AppColors.info;
    return AppColors.success;
  }

  String _strengthLabel(int s) {
    if (s <= 1) return 'Weak';
    if (s == 2) return 'Fair';
    if (s == 3) return 'Good';
    return 'Strong';
  }

  Future<void> _save() async {
    if (_newCtrl.text != _confirmCtrl.text) {
      _snack('Passwords do not match', AppColors.error);
      return;
    }
    if (_strength(_newCtrl.text) < 2) {
      _snack('Please choose a stronger password', AppColors.warning);
      return;
    }
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 800)); // TODO: API
    if (!mounted) return;
    setState(() => _isSaving = false);
    _snack('Password updated successfully', AppColors.success);
    Navigator.pop(context);
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          msg,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pw = _newCtrl.text;
    final strength = _strength(pw);
    final sColor = _strengthColor(strength);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
              size: 16,
            ),
          ),
        ),
        title: Text(
          'Change Password',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17.sp,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        children: [
          // Lock icon hero
          Center(
            child: Container(
              width: 18.w,
              height: 18.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Icon(
                SolarIconsOutline.lockPassword,
                color: AppColors.primary,
                size: 26.sp,
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Center(
            child: Text(
              'Keep your account secure',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 13.sp),
            ),
          ),
          SizedBox(height: 3.h),

          _sectionLabel('CURRENT PASSWORD'),
          SizedBox(height: 1.2.h),
          _passField(
            controller: _currentCtrl,
            hint: 'Enter current password',
            show: _showCurrent,
            toggle: () => setState(() => _showCurrent = !_showCurrent),
          ),
          SizedBox(height: 3.h),

          _sectionLabel('NEW PASSWORD'),
          SizedBox(height: 1.2.h),
          _passField(
            controller: _newCtrl,
            hint: 'Enter new password',
            show: _showNew,
            toggle: () => setState(() {
              _showNew = !_showNew;
            }),
            onChanged: (_) => setState(() {}),
          ),
          if (pw.isNotEmpty) ...[
            SizedBox(height: 1.5.h),
            // Strength bar
            Row(
              children: List.generate(
                4,
                (i) => Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 4,
                    margin: EdgeInsets.only(right: i < 3 ? 1.w : 0),
                    decoration: BoxDecoration(
                      color: i < strength ? sColor : AppColors.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 0.7.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _strengthLabel(strength),
                  style: TextStyle(
                    color: sColor,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 3.h),

          _sectionLabel('CONFIRM NEW PASSWORD'),
          SizedBox(height: 1.2.h),
          _passField(
            controller: _confirmCtrl,
            hint: 'Re-enter new password',
            show: _showConfirm,
            toggle: () => setState(() => _showConfirm = !_showConfirm),
          ),

          // Match indicator
          if (_confirmCtrl.text.isNotEmpty && pw.isNotEmpty) ...[
            SizedBox(height: 1.h),
            Row(
              children: [
                Icon(
                  _newCtrl.text == _confirmCtrl.text
                      ? SolarIconsOutline.checkCircle
                      : SolarIconsOutline.closeCircle,
                  color: _newCtrl.text == _confirmCtrl.text
                      ? AppColors.success
                      : AppColors.error,
                  size: 14.sp,
                ),
                SizedBox(width: 1.5.w),
                Text(
                  _newCtrl.text == _confirmCtrl.text
                      ? 'Passwords match'
                      : 'Passwords do not match',
                  style: TextStyle(
                    color: _newCtrl.text == _confirmCtrl.text
                        ? AppColors.success
                        : AppColors.error,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 4.h),

          AppButton(
            label: _isSaving ? 'Updating...' : 'Update Password',
            onPressed: _isSaving ? null : _save,
            size: AppButtonSize.large,
            width: double.infinity,
            borderRadius: 16,
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: TextStyle(
      color: AppColors.textSecondary,
      fontSize: 12.sp,
      fontWeight: FontWeight.bold,
      letterSpacing: 2,
    ),
  );

  Widget _passField({
    required TextEditingController controller,
    required String hint,
    required bool show,
    required VoidCallback toggle,
    void Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerColor, width: 0.8),
      ),
      child: TextField(
        controller: controller,
        obscureText: !show,
        onChanged: onChanged,
        style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 13.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          suffixIcon: GestureDetector(
            onTap: toggle,
            child: Icon(
              show ? SolarIconsOutline.eye : SolarIconsOutline.eyeClosed,
              color: AppColors.textTertiary,
              size: 16.sp,
            ),
          ),
        ),
      ),
    );
  }
}
