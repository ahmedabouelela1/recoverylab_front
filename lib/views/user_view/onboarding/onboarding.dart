import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recoverylab_front/components/app_button.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:sizer/sizer.dart';

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
      // TODO: Navigate to Home/Login
    }
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
              return _buildPage(_pages[index]);
            },
          ),

          // Skip button → AppButton stroke variant
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(2.h),
                child: AppButton(
                  label: "Skip",
                  onPressed: () {
                    // TODO: Navigate to Home/Login
                    Navigator.of(context).pushNamed(Routes.welcomePage);
                  },
                  variant: AppButtonVariant.stroke,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ), // 👈 compact size
                  borderRadius: 28, // 👈 rounded edges
                  fontSize: 14, // 👈 smaller text
                ),
              ),
            ),
          ),

          // Bottom content (dots + button)
          Positioned(
            bottom: 10.h,
            left: 5.w,
            right: 5.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 2.h),

                // Next / Get Started → AppButton solid variant
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => _buildDot(index == _currentPage),
                ),
              ),
              SizedBox(height: 6.h),
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
              SizedBox(height: 18.h),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDot(bool isActive) {
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
