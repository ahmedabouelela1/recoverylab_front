// pages/packages/widgets/membership_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recoverylab_front/components/app_button.dart';
import 'package:sizer/sizer.dart';
import 'package:recoverylab_front/configurations/colors.dart';

class MembershipCard extends StatelessWidget {
  final String title;
  final String subtitle; // smaller text line under title
  final String durationOrDetail; // e.g. freeze period, discount, etc.
  final String detailLine; // e.g. "Free towel"
  final String price;
  final String imagePath;
  final VoidCallback onBookNow;

  const MembershipCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.durationOrDetail,
    required this.detailLine,
    required this.price,
    required this.imagePath,
    required this.onBookNow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 4.w),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Membership Image with Gradient Overlay
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
              bottom: Radius.circular(12),
            ),
            child: Stack(
              // Added Stack to layer the image and gradient
              children: [
                Image.asset(
                  imagePath,
                  height: 20.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 20.h,
                    color: AppColors.textSecondary.withOpacity(0.1),
                    alignment: Alignment.center,
                    child: Text(
                      'Image Missing',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(
                            0.8,
                          ), // Start with opaque black
                          Colors.transparent, // Fade to transparent
                        ],
                        stops: const [0.0, 0.5],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 0.5.h),

                // Subtitle
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 1.5.h),

                // Duration / Main detail (using Icons.access_time based on context)
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      durationOrDetail,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),

                // Extra detail (using Icons.card_giftcard_outlined based on context)
                Row(
                  children: [
                    Icon(
                      Icons.card_giftcard_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 1.w),
                      child: Text(
                        detailLine,
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),

                // Price + Book button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "from",
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          price,
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    AppButton(
                      label: "Book now",
                      onPressed: onBookNow,
                      size: AppButtonSize.medium,
                      borderRadius: 8,
                      width: 30.w,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
