// pages/support/terms_and_policies_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:recoverylab_front/configurations/colors.dart';

class TermsAndPoliciesPage extends StatelessWidget {
  const TermsAndPoliciesPage({super.key});

  Widget _buildPolicySection({required String title, required Widget content}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 3.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 17.sp,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 1.h),
          content,
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 3.w, bottom: 0.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "•  ",
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              color: AppColors.textPrimary,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Terms & Policies",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
        children: [
          Text(
            "Effective Date: March 20, 2024",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            "Welcome to Sheikh Zayed Wellness & Rejuvenation Spa! Please review our terms to ensure a smooth and relaxing experience",
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 3.h),

          // Appointments & Cancellations
          _buildPolicySection(
            title: "Appointments & Cancellations",
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBulletPoint(
                  "You may reschedule or cancel up to 4 hours before your appointment.",
                ),
                _buildBulletPoint(
                  "Late cancellations or no-shows may be charged 50% of the service fee.",
                ),
              ],
            ),
          ),

          // Payments
          _buildPolicySection(
            title: "Payments",
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBulletPoint(
                  "We accept cash, debit/credit cards, and mobile payments.",
                ),
                _buildBulletPoint(
                  "Full payment must be made before or immediately after your session.",
                ),
              ],
            ),
          ),

          // Late Arrivals
          _buildPolicySection(
            title: "Late Arrivals",
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBulletPoint(
                  "If you arrive more than 10 minutes late, your session may be shortened to avoid delays for others.",
                ),
                _buildBulletPoint(
                  "After 15 minutes, your appointment may be marked as missed.",
                ),
              ],
            ),
          ),

          // Health & Safety
          _buildPolicySection(
            title: "Health & Safety",
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBulletPoint(
                  "If you have any medical conditions (e.g. allergies, pregnancy, skin issues), please inform our staff before your session.",
                ),
                _buildBulletPoint(
                  "We reserve the right to refuse service if we believe it may affect your health.",
                ),
              ],
            ),
          ),

          // Privacy Policy
          _buildPolicySection(
            title: "Privacy Policy",
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBulletPoint(
                  "Your personal details are safe with us. We never share your data with third parties.",
                ),
                _buildBulletPoint(
                  "Health-related info is used only to customize your care and ensure your safety.",
                ),
              ],
            ),
          ),

          // Location Use
          _buildPolicySection(
            title: "Location Use",
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBulletPoint(
                  "Services are offered only at our Sheikh Zayed branch. Home visits are not available unless specified.",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
