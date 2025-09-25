import 'package:flutter/material.dart';
import 'package:recoverylab_front/views/user_view/login/login_page.dart';
import 'package:recoverylab_front/views/user_view/login/otp_verified_page.dart';
import 'package:recoverylab_front/views/user_view/login/verification_page.dart';
import 'package:recoverylab_front/views/user_view/onboarding/onboarding.dart';
import 'package:recoverylab_front/views/user_view/onboarding/splash_screen.dart';
import 'package:recoverylab_front/views/user_view/login/welcome_page.dart';

class Routes {
  static const String root = '/';
  static const String home = '/home';
  static const String welcomePage = '/welcome';
  static const String onboardingScreen = '/onboarding';
  static const String loginPage = '/login';
  static const String otp = '/otp';
  static const String otpVerified = '/otpVerified';
}

class RoutesGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case Routes.root:
        return MaterialPageRoute(builder: (_) => WelcomeScreen());
      case Routes.home:
      // return MaterialPageRoute(builder: (_) => HomeScreen());
      case Routes.onboardingScreen:
        return MaterialPageRoute(builder: (_) => OnboardingScreen());
      case Routes.welcomePage:
        return MaterialPageRoute(builder: (_) => WelcomePage());
      case Routes.loginPage:
        return MaterialPageRoute(builder: (_) => LoginPage());
      case Routes.otp:
        return MaterialPageRoute(builder: (_) => Otp());
      case Routes.otpVerified:
        return MaterialPageRoute(builder: (_) => OtpVerifiedPage());

      default:
        return _errorRoute();
    }
  }
}

Route<dynamic> _errorRoute() {
  return MaterialPageRoute(
    builder: (_) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error 404')),
        body: const Center(child: Text('Page not found')),
      );
    },
  );
}
