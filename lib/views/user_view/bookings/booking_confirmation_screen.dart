import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/providers/api/api_provider.dart';
import 'package:recoverylab_front/providers/exception/exception_handling.dart';
import 'package:recoverylab_front/providers/exception/snack_bar.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:recoverylab_front/providers/session/active_offer_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:solar_icons/solar_icons.dart';

class BookingConfirmationScreen extends ConsumerStatefulWidget {
  final int userId;
  final int branchId;
  final String branchName;
  final int serviceId;
  final String serviceName;
  final String formattedDateTime;
  final int durationMinutes;
  final int participantCount;
  final int? staffId;
  final String? staffName;
  final String? notes;
  final String paymentMethod;
  final int? usePackageId;
  final String? packageName;
  final bool redeemPoints;
  final int? offerId;
  final String displayDate;
  final String displayTime;
  final String basePrice;
  final String finalPrice;
  final String? discountLabel;

  const BookingConfirmationScreen({
    super.key,
    required this.userId,
    required this.branchId,
    required this.branchName,
    required this.serviceId,
    required this.serviceName,
    required this.formattedDateTime,
    required this.durationMinutes,
    required this.participantCount,
    this.staffId,
    this.staffName,
    this.notes,
    required this.paymentMethod,
    this.usePackageId,
    this.packageName,
    this.redeemPoints = false,
    this.offerId,
    required this.displayDate,
    required this.displayTime,
    required this.basePrice,
    required this.finalPrice,
    this.discountLabel,
  });

  @override
  ConsumerState<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState
    extends ConsumerState<BookingConfirmationScreen> {
  bool _isLoading = false;

  String _friendlyBookingError(String raw) {
    var msg = raw;
    const prefixes = [
      'Failed to create booking: ',
      'Appointment validation failed: ',
      'Failed to create combo booking: ',
    ];
    for (final prefix in prefixes) {
      if (msg.startsWith(prefix)) {
        msg = msg.substring(prefix.length);
      }
    }
    return msg.trim();
  }

  Future<void> _confirmAndPay() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final response = await ref.read(apiProvider).storeBooking(
            userId: widget.userId,
            branchId: widget.branchId,
            serviceId: widget.serviceId,
            formattedDateTime: widget.formattedDateTime,
            durationMinutes: widget.durationMinutes,
            participantCount: widget.participantCount,
            staffId: widget.staffId,
            notes: widget.notes?.isEmpty ?? true ? null : widget.notes,
            paymentMethod: widget.paymentMethod,
            usePackageId: widget.usePackageId,
            redeemPoints: widget.redeemPoints,
            offerId: widget.offerId,
          );

      ref.read(activeOfferProvider.notifier).clear();

      final data = response['data'] as Map<String, dynamic>?;
      final bookingId = data?['booking_id'];
      final bookingObj = data?['booking'];
      final rawId = bookingId ?? bookingObj?['id'];

      if (!mounted) return;

      final isOnlinePayment = widget.paymentMethod == 'ONLINE';
      if (isOnlinePayment && rawId != null) {
        setState(() => _isLoading = true);
        try {
          final payResult = await ref.read(apiProvider).initiatePayment(
                rawId is int ? rawId : int.parse(rawId.toString()),
              );
          if (!mounted) return;
          final payData = payResult['data'] as Map<String, dynamic>?;
          final bookingIdInt =
              rawId is int ? rawId : int.parse(rawId.toString());
          if (payData?['already_paid'] == true) {
            Navigator.pushReplacementNamed(
              context,
              Routes.paymentStatus,
              arguments: {'isSuccess': true, 'bookingId': bookingIdInt},
            );
            return;
          }
          final checkoutUrl = payData?['checkout_url'] as String?;
          if (checkoutUrl == null || checkoutUrl.isEmpty) {
            Navigator.pushReplacementNamed(context, Routes.bookingSuccessPage);
            return;
          }
          Navigator.pushReplacementNamed(
            context,
            Routes.paymentScreen,
            arguments: {
              'checkoutUrl': checkoutUrl,
              'bookingId': bookingIdInt,
            },
          );
        } catch (e) {
          if (!mounted) return;
          AppSnackBar.show(
            context,
            'Payment initiation failed. Your booking is saved — you can pay at the branch.',
          );
          Navigator.pushReplacementNamed(context, Routes.bookingSuccessPage);
        }
      } else {
        Navigator.pushReplacementNamed(context, Routes.bookingSuccessPage);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final raw = e is ApiException
          ? e.message
          : e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      AppSnackBar.show(context, _friendlyBookingError(raw));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2.h),
                      _buildServiceCard(),
                      SizedBox(height: 2.h),
                      _buildDetailsCard(),
                      SizedBox(height: 2.h),
                      _buildPriceCard(),
                      SizedBox(height: 14.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildBottomActions(),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.cardBackground,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: AppColors.textPrimary,
                    size: 16.sp,
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                'Booking Summary',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              SolarIconsOutline.windowFrame,
              color: AppColors.info,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.serviceName,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  widget.branchName,
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BOOKING DETAILS',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 2.h),
          _buildDetailRow(
            icon: SolarIconsOutline.calendar,
            label: 'Date',
            value: widget.displayDate,
          ),
          _buildDivider(),
          _buildDetailRow(
            icon: SolarIconsOutline.clockCircle,
            label: 'Time',
            value: widget.displayTime,
          ),
          _buildDivider(),
          _buildDetailRow(
            icon: Icons.schedule,
            label: 'Duration',
            value: '${widget.durationMinutes} minutes',
          ),
          _buildDivider(),
          _buildDetailRow(
            icon: Icons.people,
            label: 'People',
            value:
                '${widget.participantCount} ${widget.participantCount == 1 ? 'person' : 'people'}',
          ),
          if (widget.staffName != null) ...[
            _buildDivider(),
            _buildDetailRow(
              icon: Icons.person,
              label: 'Staff Member',
              value: widget.staffName!,
            ),
          ],
          if (widget.paymentMethod.isNotEmpty) ...[
            _buildDivider(),
            _buildDetailRow(
              icon: widget.paymentMethod == 'ONLINE'
                  ? Icons.credit_card
                  : Icons.store_outlined,
              label: 'Payment',
              value: widget.paymentMethod == 'ONLINE'
                  ? 'Pay Online'
                  : 'Pay at Branch',
            ),
          ],
          if (widget.packageName != null) ...[
            _buildDivider(),
            _buildDetailRow(
              icon: Icons.card_giftcard,
              label: 'Package Credit',
              value: widget.packageName!,
            ),
          ],
          if (widget.redeemPoints) ...[
            _buildDivider(),
            _buildDetailRow(
              icon: SolarIconsBold.star,
              label: 'Points',
              value: 'Redeemed',
              valueColor: AppColors.success,
            ),
          ],
          if (widget.notes != null && widget.notes!.isNotEmpty) ...[
            _buildDivider(),
            _buildDetailRow(
              icon: Icons.note,
              label: 'Notes',
              value: widget.notes!.length > 40
                  ? '${widget.notes!.substring(0, 40)}...'
                  : widget.notes!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.5.h),
      child: Container(height: 0.5, color: AppColors.dividerColor),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textTertiary, size: 16.sp),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.sp,
            ),
          ),
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

  Widget _buildPriceCard() {
    final hasDiscount = widget.discountLabel != null ||
        widget.basePrice != widget.finalPrice;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PRICE BREAKDOWN',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Base price',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13.sp,
                ),
              ),
              Text(
                widget.basePrice,
                style: TextStyle(
                  color: hasDiscount
                      ? AppColors.textTertiary
                      : AppColors.textPrimary,
                  fontSize: 13.sp,
                  decoration:
                      hasDiscount ? TextDecoration.lineThrough : null,
                ),
              ),
            ],
          ),
          if (widget.discountLabel != null) ...[
            SizedBox(height: 1.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.discountLabel!,
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Applied',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 1.5.h),
          Container(height: 0.5, color: AppColors.dividerColor),
          SizedBox(height: 1.5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.finalPrice,
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
    );
  }

  Widget _buildBottomActions() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 4.h),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          border: Border(
            top: BorderSide(color: AppColors.dividerColor),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceLight,
                  foregroundColor: AppColors.textPrimary,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: AppColors.dividerColor),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmAndPay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.secondary,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: AppColors.primary.withOpacity(0.3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Confirm & Pay',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Icon(Icons.arrow_forward, size: 16.sp),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.6),
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
              SizedBox(height: 3.h),
              Text(
                'Processing...',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Please wait while we confirm your booking.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
