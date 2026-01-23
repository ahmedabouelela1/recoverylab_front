import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/providers/api/api_provider.dart';
import 'package:recoverylab_front/providers/exception/exception_handling.dart';
import 'package:recoverylab_front/providers/exception/snack_bar.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:recoverylab_front/providers/session/branch_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:solar_icons/solar_icons.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  bool obscurePassword = true;
  bool isLoading = false;

  String? emailError;
  String? passwordError;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();

    // Add focus listeners
    emailFocusNode.addListener(() => setState(() {}));
    passwordFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _animationController.dispose();
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo and welcome text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'lib/assets/images/blueLogo.png',
                              width: 22.w,
                              height: 9.h,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              "Welcome Back",
                              style: GoogleFonts.inter(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                height: 1.1,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 1.h),
                        Text(
                          "Continue your recovery journey",
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 3.h),

                    // Email field
                    _buildTextField(
                      controller: emailController,
                      focusNode: emailFocusNode,
                      label: "Email Address",
                      hintText: "you@example.com",
                      prefixIcon: SolarIconsBold.letter,
                      keyboardType: TextInputType.emailAddress,
                      errorText: emailError,
                      onChanged: (value) {
                        if (emailError != null) {
                          setState(() {
                            emailError = validateEmail(value);
                          });
                        }
                      },
                    ),

                    SizedBox(height: 1.h),

                    // Password field
                    _buildTextField(
                      controller: passwordController,
                      focusNode: passwordFocusNode,
                      label: "Password",
                      hintText: "Enter your password",
                      prefixIcon: SolarIconsBold.lock,
                      obscureText: obscurePassword,
                      errorText: passwordError,
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                        child: Icon(
                          obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      onChanged: (value) {
                        if (passwordError != null) {
                          setState(() {
                            passwordError = validatePassword(value);
                          });
                        }
                      },
                    ),

                    SizedBox(height: 1.5.h),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          // Navigate to forgot password
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 0.5.h,
                            horizontal: 1.w,
                          ),
                          child: Text(
                            "Forgot password?",
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.info,
                              color: AppColors.info,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 1.h),

                    // Login button
                    _buildPrimaryButton(
                      label: isLoading ? "Signing in..." : "Sign In",
                      onPressed: isLoading
                          ? null
                          : () async {
                              setState(() {
                                emailError = validateEmail(
                                  emailController.text,
                                );
                                passwordError = validatePassword(
                                  passwordController.text,
                                );
                              });

                              if (emailError != null || passwordError != null)
                                return;

                              setState(() => isLoading = true);

                              try {
                                final loginResponse = await ref
                                    .read(apiProvider)
                                    .login(
                                      emailController.text,
                                      passwordController.text,
                                    );

                                if (!mounted) return;
                                Navigator.pushReplacementNamed(
                                  context,
                                  Routes.mainScreen,
                                );
                              } catch (e) {
                                if (e is ApiException) {
                                  AppSnackBar.show(context, e.message);
                                } else {
                                  AppSnackBar.show(
                                    context,
                                    'Something went wrong',
                                  );
                                }
                              } finally {
                                if (mounted) {
                                  setState(() => isLoading = false);
                                }
                              }
                            },
                    ),

                    SizedBox(height: 3.5.h),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.secondary,
                                  AppColors.textTertiary,
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Text(
                            'or continue with',
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.textTertiary,
                                  AppColors.secondary,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 3.5.h),

                    // Social buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildSocialButton(
                            icon: FontAwesomeIcons.google,
                            label: "Google",
                            onPressed: () {
                              print("Google login");
                            },
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: _buildSocialButton(
                            icon: FontAwesomeIcons.apple,
                            label: "Apple",
                            onPressed: () {
                              print("Apple login");
                            },
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 2.h),

                    // Footer
                    _buildFooter(),

                    SizedBox(height: 3.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? errorText,
    Widget? suffixIcon,
    Function(String)? onChanged,
  }) {
    final bool isFocused = focusNode.hasFocus;
    final bool hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: EdgeInsets.only(bottom: 1.h, left: 1.w),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        // Text field
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppColors.textFieldBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasError
                  ? AppColors.error
                  : isFocused
                  ? AppColors.focusedBorder
                  : AppColors.textFieldBorder,
              width: hasError ? 1.5 : 1,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: AppColors.focusedBorder.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            obscureText: obscureText,
            onChanged: onChanged,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: Icon(
                  prefixIcon,
                  size: 20.sp,
                  color: isFocused
                      ? AppColors.focusedBorder
                      : AppColors.textSecondary,
                ),
              ),
              suffixIcon: suffixIcon != null
                  ? Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      child: suffixIcon,
                    )
                  : null,
              prefixIconConstraints: BoxConstraints(minWidth: 12.w),
              suffixIconConstraints: BoxConstraints(minWidth: 12.w),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                vertical: 2.2.h,
                horizontal: 4.w,
              ),
            ),
          ),
        ),

        // Error message
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: 0.8.h, left: 1.w),
            child: Row(
              children: [
                Icon(Icons.error_outline, size: 14.sp, color: AppColors.error),
                SizedBox(width: 1.w),
                Text(
                  errorText,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    IconData? icon,
    VoidCallback? onPressed,
  }) {
    final bool isDisabled = onPressed == null;

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 2.2.h),
        decoration: BoxDecoration(
          color: isDisabled
              ? AppColors.primary.withOpacity(0.5)
              : AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDisabled
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18.sp, color: Colors.white),
              SizedBox(width: 2.w),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.dividerColor, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icon, size: 16.sp, color: AppColors.textPrimary),
            SizedBox(width: 2.w),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, Routes.signupPage);
              },
              child: Text(
                "Sign up",
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.info,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.info,
                  decorationThickness: 2,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 3.h),

        // Terms
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Text.rich(
            TextSpan(
              text: "By continuing, you agree to our ",
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                color: AppColors.textSecondary.withOpacity(0.8),
                height: 1.5,
              ),
              children: [
                TextSpan(
                  text: "Terms of Service",
                  style: TextStyle(
                    color: AppColors.info,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: " and "),
                TextSpan(
                  text: "Privacy Policy",
                  style: TextStyle(
                    color: AppColors.info,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
