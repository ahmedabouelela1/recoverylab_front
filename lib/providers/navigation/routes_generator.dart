// routes generator

import 'package:flutter/material.dart';
import 'package:recoverylab_front/models/Bookings/api_booking.dart';
import 'package:recoverylab_front/views/user_view/bookings/booking_details_page.dart';
import 'package:recoverylab_front/views/user_view/bookings/booking_screen.dart';
import 'package:recoverylab_front/views/user_view/bookings/booking_success_page.dart';
import 'package:recoverylab_front/views/user_view/home/Service/service_categories.dart';
import 'package:recoverylab_front/views/user_view/home/Service/services_screen.dart';
import 'package:recoverylab_front/views/user_view/home/Service/service_details.dart';
import 'package:recoverylab_front/views/user_view/home/special_offer_detail_page.dart';
import 'package:recoverylab_front/views/user_view/home/special_offers_page.dart';
import 'package:recoverylab_front/views/user_view/navbar/navbar.dart';
import 'package:recoverylab_front/views/user_view/onboarding/login/login_page.dart';
import 'package:recoverylab_front/views/user_view/onboarding/login/otp_verified_page.dart';
import 'package:recoverylab_front/views/user_view/onboarding/login/verification_page.dart';
import 'package:recoverylab_front/views/user_view/onboarding/onboarding.dart';
import 'package:recoverylab_front/views/user_view/onboarding/splash_screen.dart';
import 'package:recoverylab_front/views/user_view/packages/combo_booking_screen.dart';
import 'package:recoverylab_front/views/user_view/profile/my_wallet_page.dart';
import 'package:recoverylab_front/views/user_view/packages/packages_details_page.dart';
import 'package:recoverylab_front/views/user_view/packages/packages_page.dart';
import 'package:recoverylab_front/views/user_view/profile/voucher_request_page.dart';
import 'package:recoverylab_front/views/user_view/profile/vouchers_page.dart';
import 'package:recoverylab_front/views/user_view/profile/edit_health_survey.dart';
import 'package:recoverylab_front/views/user_view/profile/help.dart';
import 'package:recoverylab_front/views/user_view/profile/reset_password.dart';
import 'package:recoverylab_front/views/user_view/profile/branches_page.dart';
import 'package:recoverylab_front/views/user_view/profile/settings.dart';
import 'package:recoverylab_front/views/user_view/profile/terms.dart';
import 'package:recoverylab_front/views/user_view/profile/upgrade_membership.dart';
import 'package:recoverylab_front/views/user_view/questionnaire/questionnaire.dart';
import 'package:recoverylab_front/views/user_view/questionnaire/questions_step2.dart';
import 'package:recoverylab_front/views/user_view/questionnaire/style.dart';
import 'package:recoverylab_front/views/user_view/profile/my_points_page.dart';
import 'package:recoverylab_front/views/user_view/bookings/booking_confirmation_screen.dart';
import 'package:recoverylab_front/views/user_view/bookings/payment_screen.dart';
import 'package:recoverylab_front/views/user_view/bookings/payment_status_page.dart';
import 'package:recoverylab_front/views/user_view/registeration/create_account.dart';
import 'package:recoverylab_front/views/user_view/registeration/otp_signup.dart';
import 'package:recoverylab_front/views/user_view/registeration/signup_screen.dart';
import 'package:recoverylab_front/views/user_view/onboarding/login/forgot_password_page.dart';

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
  static const String questionnaire = '/questionnaire';
  static const String style = '/style';
  static const String navbar = '/navbar';
  static const String categories = '/categories';
  static const String serviceDetails = '/serviceDetails';
  static const String packagesPage = '/packagesPage';
  static const String packageDetails = '/packageDetails';
  static const String settings = '/settings';
  static const String helpAndSupport = '/helpAndSupport';
  static const String termsAndPolicies = '/termsAndPolicies';
  static const String resetPassword = '/resetPassword';
  static const String forgotPassword = '/forgotPassword';
  static const String vouchers = '/vouchers';
  static const String voucherRequest = '/voucherRequest';
  static const String editHealthSurvey = '/editHealthSurvey';
  static const String upgradeMembership = '/upgradeMembership';
  static const String bookings = '/bookings';
  static const String bookingSuccessPage = '/bookingSuccessPage';
  static const String bookingDetailsPage = '/bookingDetailsPage';
  static const String splashScreen = '/splashScreen';
  static const String serviceCats = '/serviceCats';
  static const String comboBookingScreen = '/comboBookingScreen';
  static const String myWallet = '/myWallet';
  static const String specialOffersPage = '/specialOffersPage';
  static const String specialOfferDetail = '/specialOfferDetail';
  static const String branches = '/branches';
  static const String myPoints = '/myPoints';
  static const String paymentScreen = '/paymentScreen';
  static const String paymentStatus = '/paymentStatus';
  static const String bookingConfirmation = '/bookingConfirmation';
}

class RoutesGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case Routes.root:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case Routes.onboardingScreen:
        return MaterialPageRoute(builder: (_) => OnboardingScreen());
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
      case Routes.questionnaire:
        var mandatoryPostSignup = false;
        if (args is Map && args['mandatoryPostSignup'] == true) {
          mandatoryPostSignup = true;
        }
        return MaterialPageRoute(
          builder: (_) => QuestionnairePage(
            mandatoryPostSignup: mandatoryPostSignup,
          ),
        );
      case Routes.bookingSuccessPage:
        if (args is BookingSuccessArgs) {
          return MaterialPageRoute(
            builder: (_) => BookingSuccessPage(args: args),
          );
        }
        return MaterialPageRoute(builder: (_) => const BookingSuccessPage());
      case Routes.serviceCats:
        if (args != null && args is Map) {
          return MaterialPageRoute(
            builder: (_) => AllCategoriesPage(categories: args['categories']),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const AllCategoriesPage(),
        );
      case Routes.bookingDetailsPage:
        if (args is ApiBooking) {
          return MaterialPageRoute(
            builder: (_) => BookingDetailsPage(booking: args),
          );
        }
        if (args is Map<String, dynamic> &&
            args.containsKey('booking') &&
            args['booking'] is ApiBooking) {
          return MaterialPageRoute(
            builder: (_) =>
                BookingDetailsPage(booking: args['booking'] as ApiBooking),
          );
        }
        return _errorRoute();

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

      case Routes.specialOffersPage:
        return MaterialPageRoute(builder: (_) => const SpecialOffersPage());

      case Routes.specialOfferDetail:
        if (args is Map<String, dynamic> && args['id'] is int) {
          return MaterialPageRoute(
            builder: (_) =>
                SpecialOfferDetailPage(offerId: args['id'] as int),
          );
        }
        return _errorRoute();

      case Routes.otpVerifiedSignup:
        return MaterialPageRoute(builder: (_) => OtpVerifiedPage());
      case Routes.style:
        // Assuming ServicesSelectionPage is the correct class from your imports
        return MaterialPageRoute(builder: (_) => const ServicesSelectionPage());
      case Routes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case Routes.branches:
        return MaterialPageRoute(builder: (_) => const BranchesPage());
      case Routes.helpAndSupport:
        return MaterialPageRoute(builder: (_) => const HelpSupportPage());
      case Routes.termsAndPolicies:
        return MaterialPageRoute(builder: (_) => const TermsPoliciesPage());
      case Routes.resetPassword:
        return MaterialPageRoute(builder: (_) => const ChangePasswordPage());
      case Routes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());
      case Routes.vouchers:
        return MaterialPageRoute(builder: (_) => const VouchersPage());
      case Routes.voucherRequest:
        return MaterialPageRoute(builder: (_) => const VoucherRequestPage());
      case Routes.editHealthSurvey:
        return MaterialPageRoute(builder: (_) => const EditHealthSurveyPage());
      case Routes.upgradeMembership:
        return MaterialPageRoute(builder: (_) => const UpgradeMembershipPage());
      case Routes.bookings:
        return MaterialPageRoute(builder: (_) => const BookingScreen());
      case Routes.navbar:
        return MaterialPageRoute(builder: (_) => const Navbar());

      case Routes.categories:
        if (args != null && args is Map) {
          return MaterialPageRoute(
            builder: (_) => ServicesPage(category: args['category']),
          );
        }
        return _errorRoute();

      case Routes.serviceDetails:
        // return MaterialPageRoute(builder: (_) => const MassageBookingScreen());
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => ServiceDetailsPage(service: args['service']),
          );
        }
        return _errorRoute();

      case Routes.myWallet:
        return MaterialPageRoute(builder: (_) => const MyWalletPage());

      case Routes.myPoints:
        return MaterialPageRoute(builder: (_) => const MyPointsPage());

      case Routes.paymentScreen:
        if (args is Map<String, dynamic> &&
            args['checkoutUrl'] is String &&
            args['bookingId'] is int) {
          return MaterialPageRoute(
            builder: (_) => PaymentScreen(
              checkoutUrl: args['checkoutUrl'] as String,
              bookingId: args['bookingId'] as int,
            ),
          );
        }
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => PaymentScreen(checkoutUrl: args, bookingId: 0),
          );
        }
        return _errorRoute();

      case Routes.paymentStatus:
        if (args is Map<String, dynamic> && args.containsKey('isSuccess')) {
          return MaterialPageRoute(
            builder: (_) =>
                PaymentStatusPage(isSuccess: args['isSuccess'] as bool),
          );
        }
        return _errorRoute();

      case Routes.bookingConfirmation:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => BookingConfirmationScreen(
              userId: args['userId'] as int,
              branchId: args['branchId'] as int,
              branchName: args['branchName'] as String,
              serviceId: args['serviceId'] as int,
              serviceName: args['serviceName'] as String,
              formattedDateTime: args['formattedDateTime'] as String,
              durationMinutes: args['durationMinutes'] as int,
              participantCount: args['participantCount'] as int,
              staffId: args['staffId'] as int?,
              staffName: args['staffName'] as String?,
              notes: args['notes'] as String?,
              paymentMethod: args['paymentMethod'] as String,
              usePackageId: args['usePackageId'] as int?,
              packageName: args['packageName'] as String?,
              redeemPoints: args['redeemPoints'] as bool? ?? false,
              offerId: args['offerId'] as int?,
              displayDate: args['displayDate'] as String,
              displayTime: args['displayTime'] as String,
              basePrice: args['basePrice'] as String,
              finalPrice: args['finalPrice'] as String,
              discountLabel: args['discountLabel'] as String?,
            ),
          );
        }
        return _errorRoute();

      case Routes.comboBookingScreen:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => ComboBookingScreen(
              comboId: args['comboId'] as int,
              comboName: args['comboName'] as String,
              price: args['price'] as String,
              totalDuration: args['totalDuration'] as String,
              inclusions: (args['inclusions'] as List<dynamic>)
                  .map((e) => Map<String, String>.from(e))
                  .toList(),
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
