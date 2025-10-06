import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recoverylab_front/components/app_button.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:sizer/sizer.dart';

// Assuming withValues is an extension method for Color
extension ColorAlpha on Color {
  Color withValues({double? alpha}) {
    if (alpha != null) {
      return this.withOpacity(alpha);
    }
    return this;
  }
}

class OnboardingPage {
  final String imagePath;
  final String title;
  final String description;

  OnboardingPage({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      imagePath: 'lib/assets/images/splash1.png',
      title: "Welcome to Recovery Lab",
      description:
          "Your personal wellness companion. Discover a new way to relax, recover, and recharge right at your fingertips.",
    ),
    OnboardingPage(
      imagePath: 'lib/assets/images/splash2.png',
      title: "Book, Manage, Enjoy",
      description:
          "Choose your service, location, and specialist, then book for yourself or with others quick and easy.",
    ),
    OnboardingPage(
      imagePath: 'lib/assets/images/splash3.png',
      title: "Wellness, Made Simple",
      description:
          "Share your health info, pay securely, and manage all your bookings simple and safe.",
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToWelcomePage();
    }
  }

  void _navigateToWelcomePage() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      Routes.welcomePage,
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView for swiping
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              // The dots are now built inside _buildPage
              return _buildPage(_pages[index]);
            },
          ),

          // Skip button
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(2.h),
                child: AppButton(
                  label: "Skip",
                  onPressed: _navigateToWelcomePage,
                  variant: AppButtonVariant.stroke,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  borderRadius: 28,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          // Bottom content (ONLY THE BUTTON REMAINS HERE)
          Positioned(
            bottom: 10.h,
            left: 5.w,
            right: 5.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // REMOVED: Dots indicator is now inside _buildPage
                SizedBox(height: 2.h),

                // Next / Get Started button
                SizedBox(
                  width: 100.w,
                  child: AppButton(
                    label: _currentPage == _pages.length - 1
                        ? "Get Started"
                        : "Next",
                    onPressed: _nextPage,
                    variant: AppButtonVariant.solid,
                    color: AppColors.primary,
                    textColor: AppColors.secondary,
                    borderRadius: 28,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(page.imagePath, fit: BoxFit.cover),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.3, 0.5, 0.7],
              colors: [
                Colors.white.withValues(alpha: 0.5),
                const Color(0xFF1A1B1F).withValues(alpha: 0.6),
                const Color(0xFF1A1B1F),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // 1. ADDED: Dots indicator here, above the title
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => _buildDot(index == _currentPage),
                ),
              ),

              // 2. SPACE between dots and title (increased as requested previously)
              SizedBox(height: 2.h),

              Text(
                page.title,
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.h),
              Text(
                page.description,
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 16.sp,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              // 3. Adjusted padding to account for the button fixed at the bottom
              SizedBox(height: 18.h),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDot(bool isActive) {
    // ... _buildDot remains the same ...
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 1.w),
      width: isActive ? 3.w : 2.w,
      height: isActive ? 3.w : 2.w,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white54,
        shape: BoxShape.circle,
      ),
    );
  }
}
