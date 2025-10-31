import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/models/booking_model.dart';
// NOTE: AppButton import is no longer strictly needed but kept as it might be used elsewhere.
import 'package:recoverylab_front/components/app_button.dart';

class BookingDetailsPage extends StatelessWidget {
  final Booking booking;

  const BookingDetailsPage({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    // The button logic is completely removed from this page.

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          "Booking Details",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(4.w),
        children: [
          // 1. Image with Gradient Overlay
          _buildImageSection(booking.imageUrl, context),
          SizedBox(height: 2.h),

          // 2. Title and Status
          _buildTitleAndStatusSection(booking),
          SizedBox(height: 3.h),

          // 3. Description (Bio)
          Text(
            booking.description,
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: 3.h),

          // 4. Core Booking Information
          Text(
            "Appointment Details",
            style: GoogleFonts.inter(
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 1.h),

          // Detail Rows
          _buildDetailRow(
            "Location",
            booking.location,
            icon: Icons.location_on,
          ),
          _buildDetailRow(
            "Date",
            booking.date,
            icon: Icons.calendar_today_outlined,
          ),
          _buildDetailRow("Time", booking.time, icon: Icons.schedule),
          _buildDetailRow(
            "Duration",
            booking.duration,
            icon: Icons.access_time,
          ),

          // // The rating row is good for a completed booking
          // if (booking.status == BookingStatus.completed)
          //   _buildDetailRow(
          //     // "Rating",
          //     // '${booking.rating}/5.0',
          //     // icon: Icons.star,
          //     // valueColor: AppColors.warning,
          //   ),
          SizedBox(height: 3.h),
        ],
      ),

      // 5. Bottom Button: Removed entirely.
      bottomNavigationBar: null,
    );
  }

  // Helper method to build the image section
  Widget _buildImageSection(String imagePath, BuildContext context) {
    return ClipRRect(
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
                'Service Image',
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 13.sp,
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
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  stops: const [0.0, 0.5],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build the title and status section
  Widget _buildTitleAndStatusSection(Booking booking) {
    String statusText;
    Color statusColor;

    switch (booking.status) {
      case BookingStatus.upcoming:
        statusText = 'UPCOMING';
        statusColor = AppColors.primary;
        break;
      case BookingStatus.completed:
        statusText = 'COMPLETED';
        statusColor = AppColors.success;
        break;
      case BookingStatus.cancelled:
        statusText = 'CANCELLED';
        statusColor = AppColors.error;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                booking.title,
                style: GoogleFonts.inter(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusText,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper method to build a detail row
  Widget _buildDetailRow(
    String label,
    String value, {
    IconData? icon,
    Color valueColor = AppColors.textSecondary,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) Icon(icon, size: 18, color: AppColors.primary),
          if (icon != null) SizedBox(width: 2.w),

          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
