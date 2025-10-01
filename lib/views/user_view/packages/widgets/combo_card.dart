// Content for combo_card.dart, membership_card.dart, and package_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recoverylab_front/components/app_button.dart';
import 'package:sizer/sizer.dart';
// Adjust imports based on the card's location relative to configurations/colors.dart
import 'package:recoverylab_front/configurations/colors.dart';

class ComboCard extends StatelessWidget {
  final String title;
  final String subtitle; // The smaller text line below the title
  final String durationOrDetail; // The time/discount/freeze period line
  final String detailLine; // The small text detail line (e.g., 'Free towel')
  final String price;
  final String imagePath;
  final VoidCallback onBookNow;

  const ComboCard({
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
        color: AppColors.cardBackground, // Dark background from your config
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Package Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
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
          ),
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

                // Duration/Main Detail Line
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

                // Secondary Detail Line (like Free towel)
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

                // Price and Book Now Button Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                    // Book Now Button
                    AppButton(
                      label: "Book now",
                      onPressed: onBookNow,
                      size: AppButtonSize.medium,
                      borderRadius: 8,
                      width: 30.w, // let the button itself control width
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
