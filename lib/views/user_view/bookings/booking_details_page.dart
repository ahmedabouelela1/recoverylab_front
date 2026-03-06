import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/models/Bookings/api_booking.dart';
import 'package:recoverylab_front/models/Bookings/api_appointment.dart';
import 'package:recoverylab_front/models/Branch/services/service.dart';
import 'package:recoverylab_front/models/Branch/services/service_category.dart';
import 'package:recoverylab_front/providers/api/api_provider.dart';
import 'package:recoverylab_front/providers/exception/snack_bar.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';

class BookingDetailsPage extends ConsumerStatefulWidget {
  final ApiBooking booking;

  const BookingDetailsPage({super.key, required this.booking});

  @override
  ConsumerState<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends ConsumerState<BookingDetailsPage> {
  bool _isBookingAgain = false;
  bool _isRefreshing = false;
  late ApiBooking _booking;

  @override
  void initState() {
    super.initState();
    _booking = widget.booking;
  }

  ApiBooking get booking => _booking;

  Future<void> _refresh() async {
    setState(() => _isRefreshing = true);
    try {
      final updated = await ref.read(apiProvider).getBooking(_booking.id);
      if (mounted) setState(() => _booking = updated);
    } catch (e) {
      if (mounted) AppSnackBar.show(context, e.toString());
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  Color get _statusColor {
    if (booking.isUpcoming) return AppColors.info;
    if (booking.isCompleted) return AppColors.success;
    return AppColors.error;
  }

  IconData get _statusIcon {
    if (booking.isUpcoming) return SolarIconsOutline.clockCircle;
    if (booking.isCompleted) return SolarIconsOutline.checkCircle;
    return SolarIconsOutline.closeCircle;
  }

  String get _statusDescription {
    if (booking.isUpcoming) return 'Your session is confirmed and scheduled';
    if (booking.isCompleted) return 'Session completed successfully';
    return 'This booking has been cancelled';
  }

  Future<void> _bookAgain() async {
    final first = booking.firstAppointment;
    if (first?.serviceId == null) return;

    setState(() => _isBookingAgain = true);
    try {
      final service = Service(
        id: first!.serviceId!,
        name: first.serviceName ?? 'Recovery Session',
        description: '',
        image: first.serviceImage ?? '',
        category: ServiceCategory(id: first.serviceId!, name: '', description: '', image: ''),
      );
      if (!mounted) return;
      Navigator.pushNamed(
        context,
        Routes.serviceDetails,
        arguments: {'service': service},
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.warning,
          margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text(
            'Could not start re-booking. Please try again.',
            style: TextStyle(color: Colors.white, fontSize: 13.sp),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isBookingAgain = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2.5.h),
                      _buildStatusBanner(),
                      SizedBox(height: 1.5.h),
                      _buildMetaRow(context),
                      SizedBox(height: 3.h),

                      // ── Location ────────────────────────────────────────
                      _sectionLabel('LOCATION'),
                      SizedBox(height: 1.2.h),
                      _buildBranchCard(),
                      SizedBox(height: 3.h),

                      // ── Appointments ────────────────────────────────────
                      _sectionLabel(
                        booking.appointments.length == 1
                            ? 'APPOINTMENT'
                            : 'APPOINTMENTS (${booking.appointments.length})',
                      ),
                      SizedBox(height: 1.2.h),
                      ...booking.appointments.asMap().entries.map(
                        (e) => _buildAppointmentCard(e.value, e.key + 1),
                      ),
                      SizedBox(height: 3.h),

                      // ── Payment ─────────────────────────────────────────
                      _sectionLabel('PAYMENT SUMMARY'),
                      SizedBox(height: 1.2.h),
                      _buildPriceSummary(),

                      // ── Notes ───────────────────────────────────────────
                      if (booking.notes?.isNotEmpty == true) ...[
                        SizedBox(height: 3.h),
                        _sectionLabel('NOTES / SPECIAL REQUESTS'),
                        SizedBox(height: 1.2.h),
                        _buildNotesCard(),
                      ],

                      SizedBox(height: 3.h),
                      if (booking.isCompleted) _buildBookAgainButton(),
                      SizedBox(height: 10.h),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Loading overlay
          if (_isBookingAgain)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(height: 2.h),
                      Text(
                        'Setting up booking...',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Section label — matches service details ALL-CAPS style ────────────────

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12.sp,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    );
  }

  // ── Sliver App Bar ────────────────────────────────────────────────────────

  Widget _buildSliverAppBar() {
    final imageUrl = booking.displayImage ?? booking.branchImage;
    return SliverAppBar(
      expandedHeight: imageUrl != null ? 30.h : 0,
      pinned: true,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.cardBackground.withOpacity(0.92),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 16,
          ),
        ),
      ),
      title: Text(
        'Booking Details',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16.sp,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
      actions: [
        _isRefreshing
            ? Padding(
                padding: EdgeInsets.only(right: 4.w),
                child: const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textPrimary,
                  ),
                ),
              )
            : IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
                onPressed: _refresh,
              ),
      ],
      flexibleSpace: imageUrl != null
          ? FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: AppColors.cardBackground),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.background.withOpacity(0.95),
                        ],
                        stops: const [0.4, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  // ── Status banner ─────────────────────────────────────────────────────────

  Widget _buildStatusBanner() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: _statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _statusColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(_statusIcon, color: _statusColor, size: 18.sp),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.statusLabel,
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 0.3.h),
                Text(
                  _statusDescription,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          _paymentBadge(),
        ],
      ),
    );
  }

  // ── Meta row ─────────────────────────────────────────────────────────────

  Widget _buildMetaRow(BuildContext context) {
    return Row(
      children: [
        // Tappable booking ID chip
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: '#BK${booking.id}'));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.cardBackground,
                margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                content: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, color: AppColors.success, size: 14.sp),
                    SizedBox(width: 2.w),
                    Text(
                      'Booking ID copied',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.info, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.tag, color: AppColors.info, size: 13.sp),
                SizedBox(width: 1.w),
                Text(
                  '#BK${booking.id}',
                  style: TextStyle(
                    color: AppColors.info,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 1.5.w),
                Icon(
                  SolarIconsOutline.copy,
                  color: AppColors.info.withOpacity(0.6),
                  size: 12.sp,
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        // Booking date
        Row(
          children: [
            Icon(
              SolarIconsOutline.calendarDate,
              color: AppColors.textTertiary,
              size: 12.sp,
            ),
            SizedBox(width: 1.5.w),
            Text(
              _formatDate(booking.bookingDate),
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Payment badge ─────────────────────────────────────────────────────────

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  Widget _paymentBadge() {
    Color color;
    switch (booking.paymentStatus) {
      case 'PAID':
        color = AppColors.success;
        break;
      case 'PENDING':
        color = AppColors.warning;
        break;
      case 'PARTIAL':
        color = AppColors.warning;
        break;
      case 'DEFERRED':
        color = AppColors.textSecondary;
        break;
      case 'REFUNDED':
        color = AppColors.info;
        break;
      default:
        color = AppColors.textTertiary;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.7.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 0.8),
      ),
      child: Column(
        children: [
          Icon(Icons.payment, color: color, size: 12.sp),
          SizedBox(height: 0.3.h),
          Text(
            booking.paymentStatus,
            style: TextStyle(
              color: color,
              fontSize: 9.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ── Branch card ───────────────────────────────────────────────────────────

  Widget _buildBranchCard() {
    if (booking.branchName == null) return const SizedBox.shrink();
    final branchImage = booking.branchImage;

    return GestureDetector(
      onTap: () {}, // navigate to branch / maps
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.info, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: branchImage != null
                    ? Image.network(
                        branchImage,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          SolarIconsOutline.mapPoint,
                          color: AppColors.info,
                          size: 16.sp,
                        ),
                      )
                    : Icon(
                        SolarIconsOutline.mapPoint,
                        color: AppColors.info,
                        size: 16.sp,
                      ),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.branchName!,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (booking.branchAddress != null) ...[
                    SizedBox(height: 0.4.h),
                    Text(
                      booking.branchAddress!,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.expand_more, color: AppColors.strokeBorder, size: 20.sp),
          ],
        ),
      ),
    );
  }

  // ── Appointment card ──────────────────────────────────────────────────────

  Widget _buildAppointmentCard(ApiAppointment apt, int index) {
    final Color statusColor;
    if (apt.isActive) {
      statusColor = AppColors.info;
    } else if (apt.isDone) {
      statusColor = AppColors.success;
    } else {
      statusColor = AppColors.error;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerColor, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header strip
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              border: Border(
                bottom: BorderSide(
                  color: statusColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 16,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        apt.serviceName ?? 'Recovery Session',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (booking.appointments.length > 1) ...[
                        SizedBox(height: 0.2.h),
                        Text(
                          'Session $index of ${booking.appointments.length}',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    apt.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info chips — same style as service details
                Wrap(
                  spacing: 2.w,
                  runSpacing: 1.h,
                  children: [
                    _detailChip(
                      SolarIconsOutline.calendarDate,
                      apt.scheduledDateLabel,
                    ),
                    _detailChip(
                      SolarIconsOutline.clockCircle,
                      apt.scheduledTimeLabel,
                    ),
                    _detailChip(SolarIconsOutline.hourglass, apt.durationLabel),
                    _detailChip(
                      SolarIconsOutline.usersGroupTwoRounded,
                      '${apt.participantCount} guest${apt.participantCount > 1 ? 's' : ''}',
                    ),
                  ],
                ),

                // Staff
                if (apt.staffId != null) ...[
                  SizedBox(height: 2.h),
                  Container(height: 0.5, color: AppColors.dividerColor),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primary.withOpacity(0.15),
                        backgroundImage: apt.staffProfilePicture != null
                            ? NetworkImage(apt.staffProfilePicture!)
                            : null,
                        child: apt.staffProfilePicture == null
                            ? Icon(
                                SolarIconsOutline.user,
                                color: AppColors.primary,
                                size: 18,
                              )
                            : null,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'YOUR THERAPIST',
                              style: TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            SizedBox(height: 0.3.h),
                            Text(
                              apt.staffFullName,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 0.8.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          SolarIconsOutline.user,
                          color: AppColors.primary,
                          size: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ],

                SizedBox(height: 2.h),
                Container(height: 0.5, color: AppColors.dividerColor),
                SizedBox(height: 1.5.h),

                // Session price row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Session price',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13.sp,
                      ),
                    ),
                    Text(
                      'EGP ${(apt.finalPrice * apt.participantCount).toStringAsFixed(0)}',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _detailChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.9.h),
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
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Price Summary ─────────────────────────────────────────────────────────

  Widget _buildPriceSummary() {
    final hasDiscount =
        booking.discountSource != 'NONE' &&
        booking.finalTotal < booking.originalTotal;
    final discount = booking.originalTotal - booking.finalTotal;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerColor, width: 0.8),
      ),
      child: Column(
        children: [
          _priceRow(
            icon: SolarIconsOutline.wallet,
            label: 'Subtotal',
            value: 'EGP ${booking.originalTotal.toStringAsFixed(0)}',
          ),
          if (hasDiscount) ...[
            SizedBox(height: 1.2.h),
            _priceRow(
              icon: SolarIconsOutline.tagPrice,
              label: _discountLabel(booking.discountSource),
              value: '− EGP ${discount.toStringAsFixed(0)}',
              valueColor: AppColors.success,
            ),
          ],
          SizedBox(height: 1.5.h),
          Container(height: 0.5, color: AppColors.dividerColor),
          SizedBox(height: 1.5.h),

          // Total
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL CHARGED',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    if (hasDiscount) ...[
                      SizedBox(height: 0.3.h),
                      Text(
                        'You saved EGP ${discount.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  'EGP ${booking.finalTotal.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _discountLabel(String source) {
    switch (source) {
      case 'MEMBERSHIP':
        return 'Membership discount';
      case 'PACKAGE':
        return 'Package redemption';
      case 'PROMOTION':
        return 'Promo discount';
      case 'MANUAL':
        return 'Manual discount';
      default:
        return 'Discount';
    }
  }

  Widget _priceRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.textTertiary, size: 14.sp),
            SizedBox(width: 2.w),
            Text(
              label,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.textPrimary,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ── Notes card ────────────────────────────────────────────────────────────

  Widget _buildNotesCard() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerColor, width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              SolarIconsOutline.notes,
              color: AppColors.info,
              size: 16.sp,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Special Requests',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  booking.notes!,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13.sp,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Book Again button ─────────────────────────────────────────────────────

  Widget _buildBookAgainButton() {
    return GestureDetector(
      onTap: _bookAgain,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 2.h),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              SolarIconsOutline.restart,
              color: AppColors.secondary,
              size: 16.sp,
            ),
            SizedBox(width: 2.w),
            Text(
              'Book Again',
              style: TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
