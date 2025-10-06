import 'package:flutter/material.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // ❌ Removed: Timer is no longer needed

  // Function to handle navigation
  void _navigateToNextScreen() {
    // We use pushReplacementNamed so the user can't come back to the splash screen
    Navigator.of(context).pushReplacementNamed(Routes.onboardingScreen);
  }

  @override
  void initState() {
    super.initState();
    // ❌ Removed: No timer logic here anymore
  }

  @override
  void dispose() {
    // ❌ Removed: No need to cancel a timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      // ✅ ADDED: GestureDetector to capture the tap event anywhere on the screen
      body: GestureDetector(
        onTap: _navigateToNextScreen, // Call the navigation function on tap
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'lib/assets/images/logo1.png',
                width: 200,
                height: 200,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
