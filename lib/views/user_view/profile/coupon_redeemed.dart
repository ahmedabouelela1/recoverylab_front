import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:sizer/sizer.dart';

class CoupomRedeemPage extends StatefulWidget {
  const CoupomRedeemPage({super.key});

  @override
  State<CoupomRedeemPage> createState() => _CoupomRedeemPageState();
}

class _CoupomRedeemPageState extends State<CoupomRedeemPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 10), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(Routes.mainScreen);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        // Wrap the Column in a Sizedbox to force it to take 100% of the screen width
        child: SizedBox(
          width: 100.w, // Ensures the container uses the full width
          child: Column(
            // Now that the Column's parent has full width, this centers the content
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(), // 👈 Spacer 1: Pushes content down
              Column(
                children: [
                  Image.asset(
                    "lib/assets/images/blue.png",
                    width: 50.w,
                    height: 50.w,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "Coupon\nRedeemed Successfully!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 19.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const Spacer(), // 👈 Spacer 2: Pushes content up, centering it vertically
            ],
          ),
        ),
      ),
    );
  }
}
