// pages/packages/widgets/package_card.dart
// Single unified card used by CombosTab, MembershipTab, and PackagesTab.
// Replaces combo_card.dart, membership_card.dart, and the old package_card.dart.

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/components/app_button.dart';

class PackageCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String durationOrDetail;
  final String detailLine;

  /// Already formatted price string — pass WITHOUT currency symbol.
  /// The card will prepend "EGP".
  final String price;
  final String imagePath;
  final VoidCallback onBookNow;

  /// Optional badge shown top-left on the image (e.g. "COMBO", "MEMBERSHIP").
  final String? badge;

  const PackageCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.durationOrDetail,
    required this.detailLine,
    required this.price,
    required this.imagePath,
    required this.onBookNow,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 4.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Hero image ─────────────────────────────────────────────
            SizedBox(
              height: 20.h,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.surfaceLight,
                      alignment: Alignment.center,
                      child: Icon(
                        SolarIconsOutline.health,
                        color: AppColors.textTertiary,
                        size: 40.sp,
                      ),
                    ),
                  ),
                  // Gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.75),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.55],
                      ),
                    ),
                  ),
                  // Badge
                  if (badge != null)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.info.withOpacity(0.5),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          badge!,
                          style: TextStyle(
                            color: AppColors.info,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Content ────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 0.5.h),

                  // Subtitle
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 1.5.h),

                  // Detail chips row
                  Wrap(
                    spacing: 2.w,
                    runSpacing: 1.h,
                    children: [
                      if (durationOrDetail.isNotEmpty)
                        _chip(SolarIconsOutline.clockCircle, durationOrDetail),
                      if (detailLine.isNotEmpty)
                        _chip(SolarIconsOutline.gift, detailLine),
                    ],
                  ),
                  SizedBox(height: 2.h),

                  // Divider
                  Container(height: 0.5, color: AppColors.dividerColor),
                  SizedBox(height: 1.8.h),

                  // Price + button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FROM',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(height: 0.3.h),
                          Text(
                            'EGP $price',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      AppButton(
                        label: 'Book Now',
                        onPressed: onBookNow,
                        size: AppButtonSize.medium,
                        borderRadius: 100,
                        width: 32.w,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerColor, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textTertiary, size: 12.sp),
          SizedBox(width: 1.5.w),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
