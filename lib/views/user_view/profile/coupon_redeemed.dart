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
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            children: [
              SizedBox(height: 25.h), // 👈 pushes content down
              Column(
                children: [
                  Image.asset(
                    'lib/assets/images/blue.png',
                    width: 50.w,
                    height: 30.h,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Your Coupon\nis Successfully Redeemed!",
                    textAlign:
                        TextAlign.center, // 👈 ensures both lines are centered
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
