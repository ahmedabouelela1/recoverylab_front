import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recoverylab_front/providers/api/api_provider.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:sizer/sizer.dart';
import 'package:recoverylab_front/configurations/colors.dart';

class BookingSuccessArgs {
  final String serviceName;
  final String? dateTimeLabel;
  final String? staffName;

  const BookingSuccessArgs({
    required this.serviceName,
    this.dateTimeLabel,
    this.staffName,
  });
}

class BookingSuccessPage extends ConsumerStatefulWidget {
  final BookingSuccessArgs? args;

  const BookingSuccessPage({super.key, this.args});

  @override
  ConsumerState<BookingSuccessPage> createState() => _BookingSuccessPageState();
}

class _BookingSuccessPageState extends ConsumerState<BookingSuccessPage> {
  @override
  void initState() {
    super.initState();
    ref.read(bookingNeedsRefreshProvider.notifier).set(true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.navbar,
          (route) => false,
        );
      }
    });
  }

  String _buildMessage(BookingSuccessArgs? args) {
    if (args == null) {
      return 'Your appointment has been successfully booked. You will receive a confirmation shortly.';
    }

    final buffer = StringBuffer('Your appointment for ${args.serviceName}');

    if (args.dateTimeLabel != null && args.dateTimeLabel!.isNotEmpty) {
      buffer.write(' on ${args.dateTimeLabel}');
    }

    final staff = args.staffName?.trim();
    if (staff != null && staff.isNotEmpty) {
      buffer.write(' with $staff');
    }

    buffer.write(' has been successfully booked.');
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;
    final message = _buildMessage(args);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'lib/assets/images/blue.png',
              width: 50.w,
              height: 30.h,
            ),
            SizedBox(height: 2.h),

            Text(
              'Booking Confirmed!',
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 22.sp,
              ),
            ),
            SizedBox(height: 2.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                ),
              ),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}
