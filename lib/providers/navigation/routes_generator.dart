// routes generator

import 'package:flutter/material.dart';
// 🔑 NEW IMPORT: The Booking model is required to accept the argument type
import 'package:recoverylab_front/models/booking_model.dart';
import 'package:recoverylab_front/views/user_view/bookings/booking_details_page.dart';
import 'package:recoverylab_front/views/user_view/bookings/booking_page_one.dart';
import 'package:recoverylab_front/views/user_view/bookings/booking_page_three.dart';
import 'package:recoverylab_front/views/user_view/bookings/booking_page_two.dart';
import 'package:recoverylab_front/views/user_view/bookings/booking_screen.dart';
import 'package:recoverylab_front/views/user_view/bookings/booking_success_page.dart';
import 'package:recoverylab_front/views/user_view/bookings/staff_details_page.dart';
import 'package:recoverylab_front/views/user_view/home/categories.dart';
import 'package:recoverylab_front/views/user_view/home/category_details.dart';
import 'package:recoverylab_front/views/user_view/home/main_screen.dart';
import 'package:recoverylab_front/views/user_view/login/login_page.dart';
import 'package:recoverylab_front/views/user_view/login/otp_verified_page.dart';
import 'package:recoverylab_front/views/user_view/login/verification_page.dart';
import 'package:recoverylab_front/views/user_view/onboarding/onboarding.dart';
import 'package:recoverylab_front/views/user_view/onboarding/splash_screen.dart';
import 'package:recoverylab_front/views/user_view/login/welcome_page.dart';
import 'package:recoverylab_front/views/user_view/packages/packages_details_page.dart';
import 'package:recoverylab_front/views/user_view/packages/packages_page.dart';
import 'package:recoverylab_front/views/user_view/profile/coupon_redeemed.dart';
import 'package:recoverylab_front/views/user_view/profile/coupons.dart';
import 'package:recoverylab_front/views/user_view/profile/edit_health_survey.dart';
import 'package:recoverylab_front/views/user_view/profile/help.dart';
import 'package:recoverylab_front/views/user_view/profile/reset_password.dart';
import 'package:recoverylab_front/views/user_view/profile/settings.dart';
import 'package:recoverylab_front/views/user_view/profile/terms.dart';
import 'package:recoverylab_front/views/user_view/profile/upgrade_membership.dart';
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
  static const String packageDetails = '/packageDetails';
  static const String settings = '/settings';
  static const String helpAndSupport = '/helpAndSupport';
  static const String termsAndPolicies = '/termsAndPolicies';
  static const String resetPassword = '/resetPassword';
  static const String coupons = '/coupons';
  static const String editHealthSurvey = '/editHealthSurvey';
  static const String upgradeMembership = '/upgradeMembership';
  static const String couponRedeemed = '/couponRedeemed';
  static const String bookings = '/bookings';
  static const String bookingsOne = '/bookingsOne';
  static const String staffDetails = '/staffDetails';
  static const String bookingsTwo = '/bookingsTwo';
  static const String bookingsThree = '/bookingsThree';
  static const String bookingSuccessPage = '/bookingSuccessPage';
  static const String bookingDetailsPage = '/bookingDetailsPage';
  static const String splashScreen = '/splashScreen';
}

class RoutesGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case Routes.root:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case Routes.onboardingScreen:
        return MaterialPageRoute(builder: (_) => OnboardingScreen());
      case Routes.welcomePage:
        return MaterialPageRoute(builder: (_) => WelcomePage());
      case Routes.loginPage:
        return MaterialPageRoute(builder: (_) => LoginPage());
      case Routes.otp:
        // Assuming your Otp class is actually named VerificationPage from your imports
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
      case Routes.bookingSuccessPage:
        return MaterialPageRoute(builder: (_) => const BookingSuccessPage());

      // Handle the BookingDetailsPage argument which expects a Booking object
      case Routes.bookingDetailsPage:
        if (args is Map<String, dynamic> &&
            args.containsKey('booking') &&
            args['booking'] is Booking) {
          return MaterialPageRoute(
            builder: (_) =>
                BookingDetailsPage(booking: args['booking'] as Booking),
          );
        }
        return _errorRoute();

      case Routes.questionnaireStepTwo:
        return MaterialPageRoute(
          builder: (_) => const WellnessQuestionPageTwo(),
        );
      case Routes.otpSignup:
        // Assuming your SignupOtp class is correct
        return MaterialPageRoute(builder: (_) => SignupOtp());

      case Routes.packageDetails:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => PackageDetailsPage(
              title: args['title'] as String,
              description: args['description'] as String,
              imagePath: args['imagePath'] as String,
              totalDuration: args['totalDuration'] as String,
              price: args['price'] as String,
              // Correctly map the List<dynamic> arguments
              inclusions: (args['inclusions'] as List<dynamic>)
                  .map((e) => Map<String, String>.from(e))
                  .toList(),
            ),
          );
        }
        return _errorRoute();
      case Routes.packagesPage:
        return MaterialPageRoute(builder: (_) => const PackagesPage());

      case Routes.bookingsThree:
        if (args is Map<String, dynamic>) {
          // Note: args['booking'] should be cast to Booking if BookingPageThree expects it.
          // Since you didn't provide its constructor, I'll trust your current args usage.
          return MaterialPageRoute(
            builder: (_) => BookingPageThree(
              booking: args['booking'],
              basePrice: args['basePrice'],
              totalPrice: args['totalPrice'],
              selectedAddons: args['selectedAddons'],
              addonPrices: args['addonPrices'],
              selectedTherapist: args['selectedTherapist'],
              selectedDate: args['selectedDate'],
              startTimeHour: args['startTimeHour'],
              timePeriod: args['timePeriod'],
              durationHour: args['durationHour'],
              durationMinute: args['durationMinute'],
              personCount: args['personCount'],
            ),
          );
        }
        return _errorRoute();
      case Routes.otpVerifiedSignup:
        return MaterialPageRoute(builder: (_) => OtpVerifiedPageSignup());
      case Routes.style:
        // Assuming ServicesSelectionPage is the correct class from your imports
        return MaterialPageRoute(builder: (_) => const ServicesSelectionPage());
      case Routes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case Routes.helpAndSupport:
        return MaterialPageRoute(builder: (_) => const HelpAndSupportPage());
      case Routes.termsAndPolicies:
        return MaterialPageRoute(builder: (_) => const TermsAndPoliciesPage());
      case Routes.resetPassword:
        // Assuming ChangePasswordPage is the correct class
        return MaterialPageRoute(builder: (_) => const ChangePasswordPage());
      case Routes.coupons:
        return MaterialPageRoute(builder: (_) => const CouponsPage());
      case Routes.couponRedeemed:
        // Assuming CoupomRedeemPage is the correct class
        return MaterialPageRoute(builder: (_) => const CoupomRedeemPage());
      case Routes.editHealthSurvey:
        // Assuming HealthSurveyPage is the correct class
        return MaterialPageRoute(builder: (_) => const HealthSurveyPage());
      case Routes.upgradeMembership:
        return MaterialPageRoute(builder: (_) => const UpgradeMembershipPage());
      case Routes.bookings:
        return MaterialPageRoute(builder: (_) => const BookingScreen());

      case Routes.bookingsTwo:
        if (args is Map<String, dynamic> &&
            args.containsKey('booking') &&
            args.containsKey('allStaffMembers')) {
          return MaterialPageRoute(
            builder: (_) => BookingPageTwo(
              booking: args['booking'], // Should be a Booking object
              allStaffMembers: args['allStaffMembers'],
              selectedTherapist: args['selectedTherapist'],
              onTherapistSelected: args['onTherapistSelected'],
              selectedDate: args['selectedDate'],
              onDateSelected: args['onDateSelected'],
              startTimeHour: args['startTimeHour'],
              onStartTimeHourChanged: args['onStartTimeHourChanged'],
              durationHour: args['durationHour'],
              durationMinute: args['durationMinute'],
              onDurationChanged: args['onDurationChanged'],
              timePeriod: args['timePeriod'],
              onTimePeriodChanged: args['onTimePeriodChanged'],
            ),
          );
        }
        return _errorRoute();

      case Routes.staffDetails:
        if (args is Map<String, dynamic>) {
          // Assuming StaffDetailsScreen constructor takes a 'staff' argument
          return MaterialPageRoute(
            builder: (_) => StaffDetailsScreen(staff: args['staff']),
          );
        }
        return _errorRoute();

      case Routes.mainScreen:
        return MaterialPageRoute(builder: (_) => const MainScreen());

      // 🔑 CRITICAL FIX: Handle the Booking object passed directly from ServiceDetailsPage
      case Routes.bookingsOne:
        // Case 1: Argument is a raw Booking object (from detail page)
        if (args is Booking) {
          return MaterialPageRoute(
            builder: (_) => BookingPageOne(booking: args),
          );
        }
        // Case 2: Argument is a Map containing the Booking object (from booking flow)
        if (args is Map<String, dynamic> &&
            args.containsKey('booking') &&
            args['booking'] is Booking) {
          return MaterialPageRoute(
            builder: (_) => BookingPageOne(booking: args['booking'] as Booking),
          );
        }
        return _errorRoute();

      case Routes.categories:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => CategoryDetailsPage(category: args),
          );
        }
        return _errorRoute();

      case Routes.serviceDetails:
        if (args is Map<String, dynamic>) {
          // Note: ServiceDetailsPage import was missing, added for completeness
          return MaterialPageRoute(
            builder: (_) => ServiceDetailsPage(
              title: args['title'] as String,
              location: args['location'] as String,
              rating: args['rating'] as String,
              image: args['image'] as String,
              price: args['price'] as String,
              duration: args['duration'] as String,
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
