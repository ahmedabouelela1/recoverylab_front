import 'package:flutter/material.dart';
import 'package:recoverylab_front/views/user_view/home/categories.dart';
import 'package:recoverylab_front/views/user_view/home/category_details.dart';
import 'package:recoverylab_front/views/user_view/home/main_screen.dart';
import 'package:recoverylab_front/views/user_view/login/login_page.dart';
import 'package:recoverylab_front/views/user_view/login/otp_verified_page.dart';
import 'package:recoverylab_front/views/user_view/login/verification_page.dart';
import 'package:recoverylab_front/views/user_view/onboarding/onboarding.dart';
import 'package:recoverylab_front/views/user_view/onboarding/splash_screen.dart';
import 'package:recoverylab_front/views/user_view/login/welcome_page.dart';
import 'package:recoverylab_front/views/user_view/packages/packages_page.dart';
import 'package:recoverylab_front/views/user_view/questionnaire/questions_step1.dart';
import 'package:recoverylab_front/views/user_view/questionnaire/questions_step2.dart';
import 'package:recoverylab_front/views/user_view/questionnaire/style.dart';
import 'package:recoverylab_front/views/user_view/registeration/create_account.dart';
import 'package:recoverylab_front/views/user_view/registeration/otp_verified_signup.dart';
import 'package:recoverylab_front/views/user_view/registeration/signup_step1.dart';
import 'package:recoverylab_front/views/user_view/registeration/signup_step2.dart';
import 'package:recoverylab_front/views/user_view/registeration/otp_signup.dart';

class Routes {
  static const String root = '/';
  static const String home = '/home';
  static const String welcomePage = '/welcome';
  static const String onboardingScreen = '/onboarding';
  static const String loginPage = '/login';
  static const String otp = '/otp';
  static const String otpSignup = '/otpSignup';
  static const String otpVerified = '/otpVerified';
  static const String otpVerifiedSignup = '/otpVerifiedSignup';
  static const String createAccount = '/createAccount';
  static const String signupPage = '/signupPage';
  static const String signupStepTwo = '/signupStepTwo';
  static const String questionnaireStepOne = '/questionnaireStepOne';
  static const String questionnaireStepTwo = '/questionnaireStepTwo';
  static const String style = '/style';
  static const String mainScreen = '/mainScreen';
  static const String categories = '/categories';
  static const String serviceDetails = '/serviceDetails';
  static const String packagesPage = '/packagesPage';
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
      case Routes.createAccount:
        return MaterialPageRoute(builder: (_) => CreateAccountPage());
      case Routes.signupPage:
        return MaterialPageRoute(builder: (_) => const SignupPage());
      case Routes.signupStepTwo:
        return MaterialPageRoute(builder: (_) => const SignupStepTwo());
      case Routes.questionnaireStepOne:
        return MaterialPageRoute(builder: (_) => const WellnessQuestionPage());
      case Routes.questionnaireStepTwo:
        return MaterialPageRoute(
          builder: (_) => const WellnessQuestionPageTwo(),
        );
      case Routes.otpSignup:
        return MaterialPageRoute(builder: (_) => SignupOtp());
      case Routes.packagesPage:
        return MaterialPageRoute(builder: (_) => const PackagesPage());
      case Routes.otpVerifiedSignup:
        return MaterialPageRoute(builder: (_) => OtpVerifiedPageSignup());
      case Routes.style:
        return MaterialPageRoute(builder: (_) => const ServicesSelectionPage());
      case Routes.mainScreen:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case Routes.categories:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => CategoryDetailsPage(category: args),
          );
        }
        return _errorRoute();
      case Routes.serviceDetails:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => ServiceDetailsPage(
              title: args['title']!,
              location: args['location']!,
              rating: args['rating']!,
              image: args['image']!,
              price: args['price']!,
              duration: args['duration']!,
              availableFeatures: List<String>.from(
                args['availableFeatures'] ?? [],
              ),
              reviews: List<Map<String, String>>.from(args['reviews'] ?? []),
            ),
          );
        }
        return _errorRoute();
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
