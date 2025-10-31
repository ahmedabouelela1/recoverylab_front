import 'dart:async';
import 'package:flutter/material.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  void _navigateToNextScreen() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(Routes.onboardingScreen);
  }

  @override
  void initState() {
    super.initState();

    // ✅ Automatically navigate after 3 seconds
    _timer = Timer(const Duration(seconds: 3), _navigateToNextScreen);
  }

  @override
  void dispose() {
    // ✅ Cancel timer to prevent leaks
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('lib/assets/images/logo1.png', width: 200, height: 200),
          ],
        ),
      ),
    );
  }
}
