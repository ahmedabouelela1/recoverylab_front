import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recoverylab_front/components/app_button.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:sizer/sizer.dart';

// Enhanced Color extension with more utilities
extension ColorAlpha on Color {
  Color withAlpha(double alpha) {
    return this.withOpacity(alpha);
  }

  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );
    return hslLight.toColor();
  }
}

class OnboardingPage {
  final String imagePath;
  final String title;
  final String description;
  final Color? gradientStartColor;
  final Color? gradientEndColor;

  OnboardingPage({
    required this.imagePath,
    required this.title,
    required this.description,
    this.gradientStartColor,
    this.gradientEndColor,
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
  double _pageOffset = 0.0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      imagePath: 'lib/assets/images/splash_main.jpg',
      title: "Welcome to Recovery Lab",
      description:
          "Your personal wellness companion. Discover a new way to relax, recover, and recharge right at your fingertips.",
      // gradientStartColor: Colors.black.withAlpha((0.7 * 255).toInt()),
      // gradientEndColor: Colors.black.withAlpha((0.1 * 255).toInt()),
    ),
    OnboardingPage(
      imagePath: 'lib/assets/images/splash2.jpg',
      title: "Book, Manage, Enjoy",
      description:
          "Choose your service, location, and specialist, then book for yourself or with others quick and easy.",
      gradientStartColor: Colors.black.withAlpha((0.3 * 255).toInt()),
      gradientEndColor: Colors.black.withAlpha((0.7 * 255).toInt()),
    ),
    OnboardingPage(
      imagePath: 'lib/assets/images/splash_3.jpg',
      title: "Wellness, Made Simple",
      description:
          "Share your health info, pay securely, and manage all your bookings simple and safe.",
      gradientStartColor: Colors.black.withAlpha((0.5 * 255).toInt()),
      gradientEndColor: Colors.black.withAlpha((0.9 * 255).toInt()),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _pageOffset = _pageController.page ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutQuart,
      );
    } else {
      _navigateToWelcomePage();
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _navigateToWelcomePage() {
    Navigator.of(context).pushNamed(Routes.loginPage);
  }

  Widget _buildAnimatedDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (index) {
        final double activeValue = _pageOffset - index;
        final double dotSize = (1 - activeValue.abs().clamp(0, 1)) * 1.5 + 1.5;
        final double dotOpacity =
            (1 - activeValue.abs().clamp(0, 1)) * 0.5 + 0.5;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(horizontal: 0.8.w),
          width: dotSize.w,
          height: dotSize.w,
          decoration: BoxDecoration(
            color: AppColors.textPrimary.withOpacity(
              index == _currentPage ? dotOpacity : dotOpacity * 0.5,
            ),
            shape: BoxShape.circle,
            border: index == _currentPage
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
          ),
        );
      }),
    );
  }

  Widget _buildSkipButton() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _currentPage == _pages.length - 1 ? 0 : 1,
      child: AppButton(
        label: "Skip",
        onPressed: _navigateToWelcomePage,
        variant: AppButtonVariant.stroke,
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        borderRadius: 28,
        borderColor: AppColors.textPrimary,
        fontSize: 12.sp,
        textColor: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildBottomContent() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.only(bottom: 5.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated dots
          _buildAnimatedDots(),
          SizedBox(height: 4.h),

          // Next/Get Started button
          SizedBox(
            width: 80.w,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 6.h,
              child: AppButton(
                label: _currentPage == _pages.length - 1
                    ? "Get Started"
                    : "Next",
                onPressed: _nextPage,
                variant: AppButtonVariant.solid,
                borderColor: AppColors.primary,
                textColor: AppColors.textPrimary,
                borderRadius: 28,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page, int index) {
    final double pageOffset = index - _pageOffset;
    final double opacity = (1 - pageOffset.abs().clamp(0, 1));
    final double scale = 1 - pageOffset.abs() * 0.1;

    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity.clamp(0.5, 1.0),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image with parallax effect
            Positioned.fill(
              child: Image.asset(
                page.imagePath,
                fit: BoxFit.cover,
                alignment: Alignment(0, pageOffset * 0.3),
              ),
            ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.4, 0.8, 1.0],
                  colors: [
                    page.gradientStartColor?.withAlpha((0.1 * 255).toInt()) ??
                        Colors.transparent,
                    page.gradientStartColor ??
                        Colors.black.withAlpha((0.2 * 255).toInt()),
                    page.gradientEndColor ??
                        Colors.black.withAlpha((0.5 * 255).toInt()),
                    (page.gradientEndColor ?? Colors.black).withAlpha(
                      (0.9 * 255).toInt(),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title with animation
                  Transform.translate(
                    offset: Offset(0, 50 * (1 - opacity)),
                    child: Opacity(
                      opacity: opacity,
                      child: Text(
                        page.title,
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // Description with animation
                  Transform.translate(
                    offset: Offset(0, 30 * (1 - opacity)),
                    child: Opacity(
                      opacity: opacity,
                      child: Text(
                        page.description,
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary.withAlpha(
                            (0.9 * 255).toInt(),
                          ),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  // Spacer for bottom content
                  SizedBox(height: 15.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // PageView with enhanced transitions
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: _onPageChanged,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return _buildPage(_pages[index], index);
            },
          ),

          // Skip button at top right
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(3.w),
                child: _buildSkipButton(),
              ),
            ),
          ),

          // Bottom content with animations
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomContent(),
          ),

          // Swipe indicator (optional)
        ],
      ),
    );
  }
}
