import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/providers/api/api_provider.dart';
import 'package:recoverylab_front/providers/exception/exception_handling.dart';
import 'package:recoverylab_front/providers/exception/snack_bar.dart';
import 'package:sizer/sizer.dart';
import 'package:solar_icons/solar_icons.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  int _step = 1; // 1 = email, 2 = OTP, 3 = new password
  int? _storedOtp;
  bool _loading = false;
  bool _showNew = false;
  bool _showConfirm = false;
  String? _otpError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  // ── Step 1: Send OTP ────────────────────────────────────────────────────────

  Future<void> _sendOtp() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      AppSnackBar.show(context, 'Please enter a valid email address');
      return;
    }
    setState(() => _loading = true);
    try {
      final data = await ref.read(apiProvider).forgotPassword(email);
      if (!mounted) return;
      final code = data['code'];
      _storedOtp = code is int ? code : int.tryParse(code.toString());
      setState(() => _step = 2);
    } on ApiException catch (e) {
      if (mounted) AppSnackBar.show(context, e.message);
    } catch (_) {
      if (mounted) AppSnackBar.show(context, 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Step 2: Verify OTP ──────────────────────────────────────────────────────

  void _verifyOtp() {
    final entered = int.tryParse(_otpCtrl.text.trim());
    if (_otpCtrl.text.trim().length != 6 || entered == null) {
      setState(() => _otpError = 'Please enter the 6-digit code');
      return;
    }
    if (entered != _storedOtp) {
      setState(() => _otpError = 'Incorrect code. Please try again.');
      return;
    }
    setState(() {
      _otpError = null;
      _step = 3;
    });
  }

  // ── Step 3: Reset password ──────────────────────────────────────────────────

  int _strength(String pw) {
    int s = 0;
    if (pw.length >= 8) s++;
    if (pw.contains(RegExp(r'[A-Z]'))) s++;
    if (pw.contains(RegExp(r'[0-9]'))) s++;
    if (pw.contains(RegExp(r'[!@#\$%^&*]'))) s++;
    return s;
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

  Future<void> _resetPassword() async {
    final pw = _newPassCtrl.text;
    final confirm = _confirmPassCtrl.text;
    if (pw.isEmpty || confirm.isEmpty) {
      AppSnackBar.show(context, 'Please fill in both password fields');
      return;
    }
    if (pw != confirm) {
      AppSnackBar.show(context, 'Passwords do not match');
      return;
    }
    if (pw.length < 8) {
      AppSnackBar.show(context, 'Password must be at least 8 characters');
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(apiProvider).resetPassword(
            _emailCtrl.text.trim(),
            pw,
            confirm,
          );
      if (!mounted) return;
      AppSnackBar.show(context, 'Password reset successfully');
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (mounted) AppSnackBar.show(context, e.message);
    } catch (_) {
      if (mounted) AppSnackBar.show(context, 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 18),
          onPressed: () {
            if (_step > 1) {
              setState(() {
                _step--;
                _otpError = null;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'Reset Password',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 2.h),
              _buildStepIndicator(),
              SizedBox(height: 4.h),
              if (_step == 1) _buildStep1(),
              if (_step == 2) _buildStep2(),
              if (_step == 3) _buildStep3(),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(3, (i) {
        final active = i + 1 == _step;
        final done = i + 1 < _step;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 4,
                  decoration: BoxDecoration(
                    color: done || active
                        ? AppColors.primary
                        : AppColors.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (i < 2) SizedBox(width: 1.w),
            ],
          ),
        );
      }),
    );
  }

  // ── Step 1 UI ───────────────────────────────────────────────────────────────

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionIcon(SolarIconsBold.letter),
        SizedBox(height: 2.h),
        Text(
          'Enter your email',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 0.8.h),
        Text(
          "We'll send a 6-digit code to reset your password.",
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        SizedBox(height: 3.h),
        _label('EMAIL ADDRESS'),
        SizedBox(height: 1.h),
        _textField(
          controller: _emailCtrl,
          hint: 'you@example.com',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: SolarIconsBold.letter,
        ),
        SizedBox(height: 3.h),
        _primaryButton(
          label: _loading ? 'Sending...' : 'Send Code',
          onPressed: _loading ? null : _sendOtp,
        ),
      ],
    );
  }

  // ── Step 2 UI ───────────────────────────────────────────────────────────────

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionIcon(SolarIconsBold.shield),
        SizedBox(height: 2.h),
        Text(
          'Enter the code',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 0.8.h),
        Text(
          'A 6-digit code was sent to ${_emailCtrl.text.trim()}.',
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        SizedBox(height: 3.h),
        _label('VERIFICATION CODE'),
        SizedBox(height: 1.h),
        _textField(
          controller: _otpCtrl,
          hint: '6-digit code',
          keyboardType: TextInputType.number,
          maxLength: 6,
          prefixIcon: SolarIconsBold.shieldKeyhole,
          onChanged: (_) {
            if (_otpError != null) setState(() => _otpError = null);
          },
          errorText: _otpError,
        ),
        SizedBox(height: 2.h),
        GestureDetector(
          onTap: () => setState(() {
            _step = 1;
            _otpCtrl.clear();
            _otpError = null;
          }),
          child: Text(
            'Change email address',
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              color: AppColors.info,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.info,
            ),
          ),
        ),
        SizedBox(height: 3.h),
        _primaryButton(
          label: 'Verify Code',
          onPressed: _verifyOtp,
        ),
      ],
    );
  }

  // ── Step 3 UI ───────────────────────────────────────────────────────────────

  Widget _buildStep3() {
    final pw = _newPassCtrl.text;
    final strength = _strength(pw);
    final sColor = _strengthColor(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionIcon(SolarIconsBold.lockPassword),
        SizedBox(height: 2.h),
        Text(
          'New password',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 0.8.h),
        Text(
          'Choose a strong password for your account.',
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        SizedBox(height: 3.h),
        _label('NEW PASSWORD'),
        SizedBox(height: 1.h),
        _passField(
          controller: _newPassCtrl,
          hint: 'Enter new password',
          show: _showNew,
          toggle: () => setState(() => _showNew = !_showNew),
          onChanged: (_) => setState(() {}),
        ),
        if (pw.isNotEmpty) ...[
          SizedBox(height: 1.2.h),
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
          SizedBox(height: 0.5.h),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              _strengthLabel(strength),
              style: TextStyle(
                color: sColor,
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
        SizedBox(height: 2.5.h),
        _label('CONFIRM PASSWORD'),
        SizedBox(height: 1.h),
        _passField(
          controller: _confirmPassCtrl,
          hint: 'Re-enter new password',
          show: _showConfirm,
          toggle: () => setState(() => _showConfirm = !_showConfirm),
          onChanged: (_) => setState(() {}),
        ),
        if (_confirmPassCtrl.text.isNotEmpty && pw.isNotEmpty) ...[
          SizedBox(height: 1.h),
          Row(
            children: [
              Icon(
                _newPassCtrl.text == _confirmPassCtrl.text
                    ? SolarIconsOutline.checkCircle
                    : SolarIconsOutline.closeCircle,
                color: _newPassCtrl.text == _confirmPassCtrl.text
                    ? AppColors.success
                    : AppColors.error,
                size: 14.sp,
              ),
              SizedBox(width: 1.5.w),
              Text(
                _newPassCtrl.text == _confirmPassCtrl.text
                    ? 'Passwords match'
                    : 'Passwords do not match',
                style: TextStyle(
                  color: _newPassCtrl.text == _confirmPassCtrl.text
                      ? AppColors.success
                      : AppColors.error,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
        SizedBox(height: 3.5.h),
        _primaryButton(
          label: _loading ? 'Resetting...' : 'Reset Password',
          onPressed: _loading ? null : _resetPassword,
        ),
      ],
    );
  }

  // ── Shared widgets ──────────────────────────────────────────────────────────

  Widget _sectionIcon(IconData icon) {
    return Container(
      width: 14.w,
      height: 14.w,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Icon(icon, color: AppColors.primary, size: 20.sp),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 11.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    int? maxLength,
    String? errorText,
    void Function(String)? onChanged,
  }) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasError ? AppColors.error : AppColors.dividerColor,
              width: hasError ? 1.5 : 0.8,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLength: maxLength,
            onChanged: onChanged,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                fontSize: 13.sp,
                color: AppColors.textTertiary,
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: Icon(prefixIcon, size: 18.sp, color: AppColors.textSecondary),
              ),
              prefixIconConstraints: BoxConstraints(minWidth: 11.w),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                vertical: 2.h,
                horizontal: 4.w,
              ),
              counterText: '',
            ),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: 0.6.h),
          Row(
            children: [
              Icon(Icons.error_outline, size: 13.sp, color: AppColors.error),
              SizedBox(width: 1.w),
              Text(
                errorText,
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dividerColor, width: 0.8),
      ),
      child: TextField(
        controller: controller,
        obscureText: !show,
        onChanged: onChanged,
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
            fontSize: 13.sp,
            color: AppColors.textTertiary,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            child: Icon(SolarIconsBold.lockPassword,
                size: 18.sp, color: AppColors.textSecondary),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 11.w),
          suffixIcon: GestureDetector(
            onTap: toggle,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: Icon(
                show ? SolarIconsOutline.eye : SolarIconsOutline.eyeClosed,
                size: 18.sp,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          suffixIconConstraints: BoxConstraints(minWidth: 11.w),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: 2.h,
            horizontal: 4.w,
          ),
        ),
      ),
    );
  }

  Widget _primaryButton({required String label, VoidCallback? onPressed}) {
    final disabled = onPressed == null;
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 2.2.h),
        decoration: BoxDecoration(
          color: disabled
              ? AppColors.primary.withOpacity(0.5)
              : AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: disabled
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
