import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/models/Bookings/api_booking.dart';
import 'package:recoverylab_front/views/user_view/bookings/booking_details_page.dart';

class BookingCard extends StatelessWidget {
  final ApiBooking booking;
  final VoidCallback? onCancelPressed;

  const BookingCard({super.key, required this.booking, this.onCancelPressed});

  Color get _statusColor {
    if (booking.isUpcoming) return AppColors.info;
    if (booking.isCompleted) return AppColors.success;
    return AppColors.error;
  }

  Color get _paymentColor {
    switch (booking.paymentStatus) {
      case 'PAID':
        return AppColors.success;
      case 'PENDING':
        return AppColors.warning;
      case 'REFUNDED':
        return AppColors.info;
      default:
        return AppColors.textTertiary;
    }
  }

  IconData get _statusIcon {
    if (booking.isUpcoming) return SolarIconsOutline.clockCircle;
    if (booking.isCompleted) return SolarIconsOutline.checkCircle;
    return SolarIconsOutline.closeCircle;
  }

  Widget _imageFallback() {
    return Container(
      width: double.infinity,
      height: 22.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.55),
            AppColors.cardBackground,
          ],
        ),
      ),
      child: Icon(
        SolarIconsOutline.health,
        color: AppColors.textPrimary.withOpacity(0.25),
        size: 52.sp,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final first = booking.firstAppointment;
    final hasDiscount =
        booking.discountSource != 'NONE' &&
        booking.finalTotal < booking.originalTotal;
    final imageUrl = booking.displayImage ?? booking.branchImage;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BookingDetailsPage(booking: booking)),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 4.w),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.16),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Hero image ──────────────────────────────────────────────
              SizedBox(
                height: 22.h,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _imageFallback(),
                          )
                        : _imageFallback(),

                    // Gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.06),
                            Colors.black.withOpacity(0.82),
                          ],
                          stops: const [0.25, 1.0],
                        ),
                      ),
                    ),

                    // Top: Booking ID + status + payment
                    Positioned(
                      top: 12,
                      left: 14,
                      right: 14,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _glassChip('#BK${booking.id}', AppColors.info),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _statusPill(),
                              SizedBox(width: 1.5.w),
                              _paymentPill(),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Bottom: title + location
                    Positioned(
                      bottom: 14,
                      left: 14,
                      right: 14,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            booking.displayTitle,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19.sp,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.55),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.5.h),
                          Row(
                            children: [
                              Icon(
                                SolarIconsOutline.mapPoint,
                                color: Colors.white.withOpacity(0.8),
                                size: 13.sp,
                              ),
                              SizedBox(width: 1.w),
                              Flexible(
                                child: Text(
                                  booking.displayLocation,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Date / Time strip ───────────────────────────────────────
              if (first != null) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 1.6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    border: Border(
                      top: BorderSide(
                        color: AppColors.dividerColor,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoItem(
                        icon: SolarIconsOutline.calendarDate,
                        label: first.scheduledDateLabel,
                      ),
                      _dot(),
                      _infoItem(
                        icon: SolarIconsOutline.clockCircle,
                        label: first.scheduledTimeLabel,
                      ),
                      _dot(),
                      _infoItem(
                        icon: SolarIconsOutline.hourglass,
                        label: first.durationLabel,
                      ),
                      _dot(),
                      _infoItem(
                        icon: SolarIconsOutline.usersGroupTwoRounded,
                        label: '${first.participantCount}',
                      ),
                    ],
                  ),
                ),
                Container(height: 0.5, color: AppColors.dividerColor),
              ],

              // ── Price + actions ─────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Price
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'TOTAL PRICE',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(height: 0.4.h),
                          if (hasDiscount)
                            Text(
                              'EGP ${booking.originalTotal.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 11.sp,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  'EGP ${booking.finalTotal.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 21.sp,
                                    fontWeight: FontWeight.bold,
                                    height: 1,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (hasDiscount) ...[
                                SizedBox(width: 2.w),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'SAVED',
                                    style: TextStyle(
                                      color: AppColors.success,
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 3.w),

                    // Buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onCancelPressed != null) ...[
                          _cancelBtn(),
                          SizedBox(width: 2.w),
                        ],
                        _detailsBtn(context),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Widget _glassChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _statusPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: _statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _statusColor.withOpacity(0.5), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon, color: _statusColor, size: 10.sp),
          SizedBox(width: 1.w),
          Text(
            booking.statusLabel,
            style: TextStyle(
              color: _statusColor,
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: _paymentColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _paymentColor.withOpacity(0.4), width: 0.8),
      ),
      child: Text(
        booking.paymentStatus,
        style: TextStyle(
          color: _paymentColor,
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoItem({required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.textTertiary, size: 13.sp),
        SizedBox(width: 1.w),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _dot() {
    return Container(
      width: 3,
      height: 3,
      decoration: BoxDecoration(
        color: AppColors.textTertiary.withOpacity(0.4),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _detailsBtn(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BookingDetailsPage(booking: booking)),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.4.h),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Details',
              style: TextStyle(
                color: AppColors.secondary,
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 1.5.w),
            Icon(Icons.arrow_forward, color: AppColors.secondary, size: 14.sp),
          ],
        ),
      ),
    );
  }

  Widget _cancelBtn() {
    return GestureDetector(
      onTap: onCancelPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withOpacity(0.5), width: 1),
        ),
        child: Text(
          'Cancel',
          style: TextStyle(
            color: AppColors.error,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
