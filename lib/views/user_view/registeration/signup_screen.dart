import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/models/Branch/branch/branch.dart';
import 'package:recoverylab_front/models/User/country.dart';
import 'package:recoverylab_front/providers/api/api_provider.dart';
import 'package:recoverylab_front/providers/exception/exception_handling.dart';
import 'package:recoverylab_front/providers/exception/snack_bar.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:recoverylab_front/providers/session/branch_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:solar_icons/solar_icons.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController dobController = TextEditingController();
  String? gender;
  Branch? selectedBranch;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool acceptTerms = false;
  bool isLoading = false;
  String selectedCountryCode = '+20';
  DateTime? selectedDob;

  final FocusNode firstNameFocusNode = FocusNode();
  final FocusNode lastNameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode phoneFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();
  final FocusNode dobFocusNode = FocusNode();

  String? firstNameError;
  String? lastNameError;
  String? emailError;
  String? phoneError;
  String? passwordError;
  String? confirmPasswordError;
  String? dobError;
  String? genderError;
  String? locationError;

  final List<String> genders = ["Male", "Female"];
  List<Branch> branches = [];

  // Validation methods
  String? validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'First name is required';
    }
    // if (value.length < 2) {
    //   return 'First name must be at least 2 characters';
    // }
    return null;
  }

  String? validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Last name is required';
    }
    // if (value.length < 2) {
    //   return 'Last name must be at least 2 characters';
    // }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number (10-15 digits)';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? validateDateOfBirth(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date of birth is required';
    }
    return null;
  }

  String? validateGender(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select your gender';
    }
    return null;
  }

  String? validateLocation(Branch? value) {
    if (value == null) {
      return 'Please select your location';
    }
    return null;
  }

  bool validatePage1() {
    setState(() {
      firstNameError = validateFirstName(firstNameController.text);
      lastNameError = validateLastName(lastNameController.text);
      emailError = validateEmail(emailController.text);
    });

    return firstNameError == null &&
        lastNameError == null &&
        emailError == null;
  }

  bool validatePage2() {
    setState(() {
      phoneError = validatePhone(phoneController.text);
      passwordError = validatePassword(passwordController.text);
      confirmPasswordError = validateConfirmPassword(
        confirmPasswordController.text,
      );
    });

    return phoneError == null &&
        passwordError == null &&
        confirmPasswordError == null;
  }

  bool validatePage3() {
    setState(() {
      dobError = validateDateOfBirth(dobController.text);
      genderError = validateGender(gender);
      locationError = validateLocation(selectedBranch);
    });

    return dobError == null && genderError == null && locationError == null;
  }

  void _nextPage() {
    bool isValid = false;

    switch (_currentPage) {
      case 0:
        isValid = validatePage1();
        break;
      case 1:
        isValid = validatePage2();
        break;
      case 2:
        isValid = validatePage3();
        break;
    }

    if (isValid && _currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeSignup() async {
    if (!acceptTerms) {
      AppSnackBar.show(context, 'Please accept terms and conditions');
      return;
    }

    if (!validatePage3()) {
      return;
    }

    setState(() => isLoading = true);

    try {
      final fullPhoneNumber = '$selectedCountryCode${phoneController.text}';
      final dobForApi =
          "${selectedDob!.year}-${selectedDob!.month.toString().padLeft(2, '0')}-${selectedDob!.day.toString().padLeft(2, '0')}";

      final registerResponse = await ref
          .read(apiProvider)
          .register(
            firstNameController.text,
            lastNameController.text,
            emailController.text,
            fullPhoneNumber,
            gender?.toLowerCase() ?? 'male',
            passwordController.text,
            confirmPasswordController.text,
            dobForApi,
            selectedBranch!.id, // ✅ branch ID
          );

      if (!mounted) return;
      // AppSnackBar.show(context, 'Account created successfully!');
      Navigator.pushReplacementNamed(context, Routes.mainScreen);
    } catch (e) {
      if (e is ApiException) {
        AppSnackBar.show(context, e.message);
      } else {
        AppSnackBar.show(context, 'Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Widget _buildPhoneField() {
    final bool isFocused = phoneFocusNode.hasFocus;
    final bool hasError = phoneError != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 1.h, left: 1.w),
          child: Text(
            "Phone Number",
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),

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
          ),
          child: Row(
            children: [
              /// 🌍 Country Code Dropdown
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCountryCode,
                  dropdownColor: AppColors.cardBackground,
                  items: countryCodes.map((country) {
                    return DropdownMenuItem<String>(
                      value: country.code,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: Row(
                          children: [
                            Text(
                              country.flag,
                              style: TextStyle(fontSize: 16.sp),
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              country.code,
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
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCountryCode = value!;
                    });
                  },
                ),
              ),

              Container(width: 1, height: 24, color: AppColors.textFieldBorder),

              /// 📱 Phone Input
              Expanded(
                child: TextField(
                  controller: phoneController,
                  focusNode: phoneFocusNode,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: "1234567890",
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 2.2.h,
                      horizontal: 4.w,
                    ),
                  ),
                  onChanged: (value) {
                    if (phoneError != null) {
                      setState(() {
                        phoneError = validatePhone(value);
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),

        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: 0.8.h, left: 1.w),
            child: Row(
              children: [
                Icon(Icons.error_outline, size: 14.sp, color: AppColors.error),
                SizedBox(width: 1.w),
                Text(
                  phoneError!,
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

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 1.w),
          width: _currentPage == index ? 24.sp : 8.sp,
          height: 8.sp,
          decoration: BoxDecoration(
            color: _currentPage >= index
                ? AppColors.primary
                : AppColors.textTertiary,
            borderRadius: BorderRadius.circular(4.sp),
          ),
        );
      }),
    );
  }

  Widget _buildSocialLoginButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.secondary, AppColors.textTertiary],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                "or continue with",
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
                    colors: [AppColors.textTertiary, AppColors.secondary],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 3.h),
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
        Text(
          "Sign up with Google or Apple",
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
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
    VoidCallback? onTap,
  }) {
    final bool isFocused = focusNode.hasFocus;
    final bool hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            onTap: onTap,
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
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: 0.8.h, left: 1.w),
            child: Row(
              children: [
                Icon(Icons.error_outline, size: 14.sp, color: AppColors.error),
                SizedBox(width: 1.w),
                Text(
                  errorText!,
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

  Widget _buildGenderDropdown() {
    final bool hasError = genderError != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 1.h, left: 1.w),
          child: Text(
            "Gender",
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasError ? AppColors.error : AppColors.textFieldBorder,
              width: hasError ? 1.5 : 1,
            ),
            color: AppColors.textFieldBackground,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: gender,
              icon: Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: Icon(
                  SolarIconsBold.altArrowDown,
                  size: 20.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              dropdownColor: AppColors.cardBackground,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              hint: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  "Select your gender",
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                ),
              ),
              items: genders.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Text(
                      value,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  gender = newValue;
                  if (newValue != null) {
                    genderError = null;
                  }
                });
              },
            ),
          ),
        ),
        if (genderError != null)
          Padding(
            padding: EdgeInsets.only(top: 0.8.h, left: 1.w),
            child: Row(
              children: [
                Icon(Icons.error_outline, size: 14.sp, color: AppColors.error),
                SizedBox(width: 1.w),
                Text(
                  genderError!,
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

  Widget _buildLocationGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 1.h, left: 1.w),
          child: Text(
            "Select Your Location",
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 3.w,
            mainAxisSpacing: 2.h,
            childAspectRatio: 1.5,
          ),
          itemCount: branches.length,
          itemBuilder: (context, index) {
            final loc = branches[index];
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedBranch = loc;
                  locationError = null;
                });
              },

              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selectedBranch?.name == loc.name
                        ? AppColors.primary
                        : AppColors.textFieldBorder,
                    width: selectedBranch?.name == loc.name ? 2 : 1,
                  ),
                  image: DecorationImage(
                    image: NetworkImage(loc.image),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.3),
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        loc.name,
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (selectedBranch?.id == loc.id)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 24.sp,
                          height: 24.sp,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            size: 16.sp,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        if (locationError != null)
          Padding(
            padding: EdgeInsets.only(top: 0.8.h, left: 1.w),
            child: Row(
              children: [
                Icon(Icons.error_outline, size: 14.sp, color: AppColors.error),
                SizedBox(width: 1.w),
                Text(
                  locationError!,
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
    bool isDisabled = false,
  }) {
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

  Widget _buildOutlinedButton({
    required String label,
    IconData? icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 2.2.h),
        decoration: BoxDecoration(
          color: AppColors.textFieldBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.textFieldBorder, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18.sp, color: AppColors.textPrimary),
              SizedBox(width: 2.w),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final branchprovider = ref.read(branchesProvider);
        setState(() {
          branches = branchprovider;
        });
      } catch (e) {
        AppSnackBar.show(context, 'Failed to load branches');
      }
    });

    // Add focus listeners
    firstNameFocusNode.addListener(() => setState(() {}));
    lastNameFocusNode.addListener(() => setState(() {}));
    emailFocusNode.addListener(() => setState(() {}));
    phoneFocusNode.addListener(() => setState(() {}));
    passwordFocusNode.addListener(() => setState(() {}));
    confirmPasswordFocusNode.addListener(() => setState(() {}));
    dobFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    firstNameFocusNode.dispose();
    lastNameFocusNode.dispose();
    emailFocusNode.dispose();
    phoneFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    dobFocusNode.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Background decoration
            Positioned(
              top: -10.h,
              left: -10.w,
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo
                      Image.asset(
                        'lib/assets/images/blueLogo.png',
                        width: 16.w,
                        height: 6.h,
                        fit: BoxFit.contain,
                      ),
                      // Progress indicator
                      _buildProgressIndicator(),
                    ],
                  ),
                ),

                // Page content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    physics: const ClampingScrollPhysics(),
                    children: [
                      // Page 1: Personal Info
                      _buildPage1(),
                      // Page 2: Account Info
                      _buildPage2(),
                      // Page 3: Additional Info
                      _buildPage3(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage1() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            "Let's Get Started",
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            "Create your Recovery Lab account in a few steps",
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: AppColors.textSecondary.withOpacity(0.8),
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: firstNameController,
                  focusNode: firstNameFocusNode,
                  label: "First Name",
                  hintText: "John",
                  prefixIcon: SolarIconsOutline.user,
                  errorText: firstNameError,
                  onChanged: (value) {
                    if (firstNameError != null) {
                      setState(() {
                        firstNameError = validateFirstName(value);
                      });
                    }
                  },
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildTextField(
                  controller: lastNameController,
                  focusNode: lastNameFocusNode,
                  label: "Last Name",
                  hintText: "Doe",
                  prefixIcon: SolarIconsOutline.user,
                  errorText: lastNameError,
                  onChanged: (value) {
                    if (lastNameError != null) {
                      setState(() {
                        lastNameError = validateLastName(value);
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 2.5.h),
          _buildTextField(
            controller: emailController,
            focusNode: emailFocusNode,
            label: "Email Address",
            hintText: "john.doe@example.com",
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

          SizedBox(height: 4.h),
          _buildSocialLoginButtons(),
          SizedBox(height: 4.h),

          // Next button
          _buildPrimaryButton(label: "Continue", onPressed: _nextPage),
          SizedBox(height: 2.h),

          // Already have account
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Already have an account? ",
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Sign In",
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.info,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPage2() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            "Account Security",
            style: GoogleFonts.inter(
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            "Set up your password for secure access",
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: AppColors.textSecondary.withOpacity(0.8),
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 4.h),

          _buildPhoneField(),

          SizedBox(height: 2.5.h),

          // Password field
          _buildTextField(
            controller: passwordController,
            focusNode: passwordFocusNode,
            label: "Password",
            hintText: "Create a strong password (min 8 characters)",
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
              // Also clear confirm password error if passwords now match
              if (confirmPasswordError == 'Passwords do not match' &&
                  value == confirmPasswordController.text) {
                setState(() {
                  confirmPasswordError = null;
                });
              }
            },
          ),
          SizedBox(height: 2.5.h),

          // Confirm password field
          _buildTextField(
            controller: confirmPasswordController,
            focusNode: confirmPasswordFocusNode,
            label: "Confirm Password",
            hintText: "Re-enter your password",
            prefixIcon: SolarIconsBold.lock,
            obscureText: obscureConfirmPassword,
            errorText: confirmPasswordError,
            suffixIcon: GestureDetector(
              onTap: () {
                setState(() {
                  obscureConfirmPassword = !obscureConfirmPassword;
                });
              },
              child: Icon(
                obscureConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20.sp,
                color: AppColors.textSecondary,
              ),
            ),
            onChanged: (value) {
              if (confirmPasswordError != null) {
                setState(() {
                  confirmPasswordError = validateConfirmPassword(value);
                });
              }
            },
          ),
          SizedBox(height: 4.h),

          // Navigation buttons
          Row(
            children: [
              Expanded(
                child: _buildOutlinedButton(
                  label: "Back",
                  onPressed: _previousPage,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildPrimaryButton(
                  label: "Continue",
                  onPressed: _nextPage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPage3() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            "Additional Information",
            style: GoogleFonts.inter(
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            "Tell us more about yourself for a personalized experience",
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: AppColors.textSecondary.withOpacity(0.8),
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 4.h),

          // Date of Birth
          _buildTextField(
            controller: dobController,
            focusNode: dobFocusNode,
            label: "Date of Birth",
            hintText: "DD/MM/YYYY",
            prefixIcon: SolarIconsBold.calendar,
            errorText: dobError,
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now().subtract(
                  const Duration(days: 365 * 18),
                ),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  selectedDob = picked;
                  dobController.text =
                      "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                  dobError = null;

                  dobError = null;
                });
              }
            },
          ),
          SizedBox(height: 2.5.h),

          // Gender Dropdown
          _buildGenderDropdown(),
          SizedBox(height: 2.5.h),

          // Location Selection
          _buildLocationGrid(),
          SizedBox(height: 3.h),

          // Terms and Conditions
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() => acceptTerms = !acceptTerms);
                },
                child: Container(
                  width: 20.sp,
                  height: 20.sp,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: acceptTerms
                          ? AppColors.primary
                          : AppColors.textFieldBorder,
                      width: 2,
                    ),
                    color: acceptTerms ? AppColors.primary : Colors.transparent,
                  ),
                  child: acceptTerms
                      ? Icon(
                          Icons.check_rounded,
                          size: 14.sp,
                          color: AppColors.secondary,
                        )
                      : null,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => acceptTerms = !acceptTerms);
                  },
                  child: Text.rich(
                    TextSpan(
                      text: "I agree to the ",
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        TextSpan(
                          text: "Terms & Conditions ",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(text: "and "),
                        TextSpan(
                          text: "Privacy Policy",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),

          // Navigation buttons
          Row(
            children: [
              Expanded(
                child: _buildOutlinedButton(
                  label: "Back",
                  onPressed: _previousPage,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildPrimaryButton(
                  label: isLoading ? "Creating Account..." : "Complete Signup",
                  onPressed: acceptTerms ? _completeSignup : null,
                  isDisabled: !acceptTerms || isLoading,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}
