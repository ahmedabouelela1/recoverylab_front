// pages/details/package_details_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:recoverylab_front/providers/navigation/routes_generator.dart'; // Removed: not needed for navigation
import 'package:sizer/sizer.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/components/app_button.dart';
// import 'package:recoverylab_front/models/booking_model.dart'; // Removed: not needed for navigation

class PackageDetailsPage extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final String totalDuration;
  final String price;
  final List<Map<String, String>> inclusions;

  const PackageDetailsPage({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.totalDuration,
    required this.price,
    required this.inclusions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Package Details",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp, // Original size
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(4.w),
        children: [
          // Image with Gradient Overlay
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
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
                      'Image Not Found at: $imagePath',
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 13.sp, // Original size
                      ),
                      textAlign: TextAlign.center,
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
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),

          // Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 17.sp, // Original size
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 15.sp, // Original size
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: 3.h),

          // What's Included Section
          Text(
            "What's Included",
            style: GoogleFonts.inter(
              fontSize: 17.sp, // Original size
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 1.h),
          ...inclusions.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 1.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _getIconData(item['icon']!),
                    size: 18,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      item['name']!,
                      style: GoogleFonts.inter(
                        fontSize: 15.sp, // Original size
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 3.h),

          _buildDetailRow(
            "Total Duration",
            totalDuration,
            isBold: true,
            isTime: true,
          ),
          _buildDetailRow("Price", "\$$price", isBold: true, isPrice: true),

          SizedBox(height: 3.h),
        ],
      ),

      // Bottom Button
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(4.w),
        child: AppButton(
          label: "Book Now",
          width: double.infinity,
          borderRadius: 40.sp,
          size: AppButtonSize.large,
          onPressed: () {
            // Reverted to having NO navigation
            print("Book Now button pressed, no navigation defined.");
          },
        ),
      ),
    );
  }

  IconData _getIconData(String iconKey) {
    switch (iconKey) {
      case 'icon_deep_tissue':
      case 'icon_massage':
        return Icons.self_improvement;
      case 'icon_steam_room':
        return Icons.hot_tub;
      case 'icon_iv_drip':
      case 'icon_drip':
        return Icons.local_hospital;
      case 'icon_ice_bath':
        return Icons.ac_unit;
      case 'icon_sauna':
        return Icons.filter_drama_outlined;
      case 'icon_bath':
        return Icons.bathtub;
      default:
        return Icons.spa;
    }
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isBold = false,
    bool isPrice = false,
    bool isTime = false,
  }) {
    final double valueFontSize = 14.sp; // Original size

    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Label (Small and muted)
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 15.sp, // Original size
              color: AppColors.textSecondary,
            ),
          ),
          // Value (Smaller, but still bold)
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: valueFontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
