import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:recoverylab_front/configurations/colors.dart';
// 🔑 Imports for data model and navigation target
import 'package:recoverylab_front/models/booking_model.dart';
import 'package:recoverylab_front/views/user_view/bookings/booking_details_page.dart'; // The new details page

class BookingCard extends StatelessWidget {
  final Booking booking;
  final BookingStatus viewStatus;
  final VoidCallback onPrimaryActionPressed;

  const BookingCard({
    super.key,
    required this.booking,
    required this.viewStatus,
    required this.onPrimaryActionPressed,
  });

  Widget _getStatusIcon() {
    switch (viewStatus) {
      case BookingStatus.upcoming:
        return Icon(
          Icons.notifications_none,
          color: AppColors.textPrimary.withOpacity(0.7),
          size: 24,
        );
      case BookingStatus.completed:
        return const Icon(
          Icons.check_circle,
          color: AppColors.success,
          size: 24,
        );
      case BookingStatus.cancelled:
        return const Icon(
          Icons.cancel_outlined,
          color: AppColors.error,
          size: 24,
        );
    }
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    final TextStyle labelStyle = GoogleFonts.inter(
      color: AppColors.textSecondary,
      fontSize: 12.sp,
    );
    final TextStyle valueStyle = GoogleFonts.inter(
      color: AppColors.textPrimary,
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
    );

    List<Widget> textWidgets;
    if (label.isEmpty) {
      // If no label, just display the value
      textWidgets = [Text(value, style: valueStyle)];
    } else {
      // Display 'Label: Value'
      textWidgets = [
        Text('$label: ', style: labelStyle),
        Text(value, style: valueStyle),
      ];
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 0.5.h),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 14.sp),
          SizedBox(width: 1.w),
          ...textWidgets,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Logic to ensure the 'Manage' button is displayed for Upcoming status
    final String primaryActionText = booking.status == BookingStatus.upcoming
        ? 'Manage'
        : 'Book Again';

    // Note: Assuming AppColors.strokeBorder is defined as a Color type.
    final Color strokeBorderColor = AppColors.strokeBorder;

    return Container(
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.only(bottom: 3.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  booking.imageUrl,
                  fit: BoxFit.cover,
                  width: 25.w,
                  height: 25.w,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 25.w,
                    height: 25.w,
                    color: AppColors.textFieldBackground,
                    child: const Center(
                      child: Icon(Icons.image, color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              // Text Details Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            booking.title,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.sp,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _getStatusIcon(),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: AppColors.warning,
                          size: 14,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          '${booking.rating}',
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondary,
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.5.h),
                    _buildDetailRow(Icons.location_on, '', booking.location),
                    _buildDetailRow(
                      Icons.calendar_today,
                      '',
                      '${booking.date}, ${booking.time}',
                    ),
                    _buildDetailRow(
                      Icons.access_time,
                      'Duration',
                      booking.duration,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          // Buttons Row
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Navigate to the details page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BookingDetailsPage(booking: booking),
                      ),
                    );
                  }, // This is the 'Details' button (Secondary Action)
                  style: OutlinedButton.styleFrom(
                    // Use the custom stroke color or fallback
                    side: BorderSide(color: strokeBorderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.sp),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    backgroundColor: Colors.transparent,
                  ),
                  child: Text(
                    'Details',
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: onPrimaryActionPressed, // 'Manage' or 'Book Again'
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.sp),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  ),
                  child: Text(
                    primaryActionText,
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
