import 'package:flutter/material.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void _navigateToNextScreen() {
    Navigator.of(context).pushReplacementNamed(Routes.onboardingScreen);
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    Future.delayed(const Duration(seconds: 2), () {
      _navigateToNextScreen();
    });
    // bool hasInternet = await _hasInternetConnection();

    // if (!hasInternet) {
    //   _showNoInternetDialog();
    //   return;
    // }

    // final token = await _storage.read(key: 'auth_token');
    // final authUser = await _storage.read(key: 'auth_response');

    // AuthResponse? authResponse;

    // if (authUser != null) {
    //   try {
    //     authResponse = AuthResponse.fromJson(jsonDecode(authUser));
    //   } catch (e) {
    //   }
    // }

    // // Wait for the splash screen animation (3 seconds)
    // await Future.delayed(const Duration(seconds: 2));

    // if (token != null && token.isNotEmpty && authResponse != null) {
    //   final response = await ref.read(apiProvider).validateToken(token);
    //   if (response['success'] == false) {
    //     Navigator.pushReplacementNamed(context, Routes.login);
    //     return;
    //   }
    //   final authResponseNew = AuthResponse.fromJson(response);
    //   ref.read(userSessionProvider).login(authResponseNew);
    //   Navigator.pushReplacementNamed(context, Routes.homeScreen);
    // } else {
    //   Navigator.pushReplacementNamed(context, Routes.login);
    // }
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
