// pages/support/help_and_support_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:recoverylab_front/configurations/colors.dart';

class HelpAndSupportPage extends StatelessWidget {
  const HelpAndSupportPage({super.key});

  Widget _buildSection({required String title, required Widget content}) {
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
          "Help and Support",
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
            "Need assistance?",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            "We're here to help you feel relaxed",
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),

          // Contact Us Section
          _buildSection(
            title: "Contact Us",
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Have questions or need help with a booking?",
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  "Call or WhatsApp us at +20 100 123 4567",
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  "(Available daily from 10 AM – 10 PM)",
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Booking Issues Section
          _buildSection(
            title: "Booking Issues",
            content: Text(
              "Go to My Appointments → Select your booking → Choose “Reschedule” or “Cancel”.",
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          // Payment Questions Section
          _buildSection(
            title: "Payment Questions",
            content: Text(
              "For billing or payment concerns, please visit the Payments section or reach out via chat.",
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          // Feedback or Complaints Section
          _buildSection(
            title: "Feedback or Complaints",
            content: Text(
              "Tell us about your experience — good or bad. We take your feedback seriously to serve you better.",
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
