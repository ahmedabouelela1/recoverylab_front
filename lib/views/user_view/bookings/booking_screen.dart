import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/components/app_button.dart';
import 'package:recoverylab_front/models/Bookings/api_booking.dart';
import 'package:recoverylab_front/providers/api/api_provider.dart';
import 'package:recoverylab_front/providers/exception/snack_bar.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:recoverylab_front/views/user_view/bookings/widget/booking_card.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen>
    with SingleTickerProviderStateMixin {
  String _selectedTab = 'Upcoming';
  List<ApiBooking> _bookings = [];
  bool _isLoading = true;
  bool _hasError = false;
  bool _isCancelling = false;

  AnimationController? _shimmerController;
  Animation<double>? _shimmerAnim;

  final List<String> _tabs = ['Upcoming', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _shimmerAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shimmerController!, curve: Curves.easeInOut),
    );
    _fetchBookings();
  }

  @override
  void dispose() {
    _shimmerController?.dispose();
    super.dispose();
  }

  Future<void> _fetchBookings() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final bookings = await ref.read(apiProvider).getBookings();
      if (!mounted) return;
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  List<ApiBooking> _filteredBookings(String tab) {
    return _bookings.where((b) {
      if (tab == 'Upcoming') return b.isUpcoming;
      if (tab == 'Completed') return b.isCompleted;
      return b.isCancelled;
    }).toList();
  }

  Future<void> _cancelBooking(ApiBooking booking) async {
    Navigator.pop(context);
    setState(() => _isCancelling = true);
    try {
      final active = booking.appointments.where((a) => a.isActive).toList();
      final errors = <String>[];
      for (final apt in active) {
        try {
          await ref.read(apiProvider).cancelAppointment(apt.id);
        } catch (e) {
          errors.add(e.toString());
        }
      }
      if (errors.isNotEmpty) throw Exception(errors.first);
      await _fetchBookings();
      if (!mounted) return;
      setState(() => _selectedTab = 'Cancelled');
      AppSnackBar.show(context, 'Booking cancelled successfully');
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(context, 'Failed to cancel. Please try again.');
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  void _showCancelDialog(ApiBooking booking) {
    final first = booking.firstAppointment;
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with animated ring
              Container(
                width: 16.w,
                height: 16.w,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppColors.error.withOpacity(0.18),
                      AppColors.error.withOpacity(0.06),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.error.withOpacity(0.25),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  SolarIconsOutline.closeCircle,
                  color: AppColors.error,
                  size: 28.sp,
                ),
              ),
              SizedBox(height: 2.5.h),
              Text(
                'Cancel Booking?',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 18.sp,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 1.2.h),
              Text(
                'Are you sure you want to cancel\n${booking.displayTitle}'
                '${first != null ? '\non ${first.scheduledDateLabel} at ${first.scheduledTimeLabel}' : ''}?',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 13.5.sp,
                  height: 1.6,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 1.h),
              // Cancellation policy note
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      SolarIconsOutline.infoCircle,
                      color: AppColors.error.withOpacity(0.8),
                      size: 14.sp,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        'This action cannot be undone.',
                        style: GoogleFonts.dmSans(
                          fontSize: 11.5.sp,
                          color: AppColors.error.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 3.h),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Keep It',
                      variant: AppButtonVariant.stroke,
                      size: AppButtonSize.large,
                      color: AppColors.surfaceLight,
                      textColor: AppColors.textPrimary,
                      borderColor: AppColors.dividerColor,
                      borderRadius: 18,
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: AppButton(
                      label: 'Yes, Cancel',
                      variant: AppButtonVariant.solid,
                      size: AppButtonSize.large,
                      color: AppColors.error,
                      textColor: Colors.white,
                      borderRadius: 18,
                      onPressed: () => _cancelBooking(booking),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final upcomingCount = _bookings.where((b) => b.isUpcoming).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ─────────────────────────────────────────────
                _buildHeader(upcomingCount),

                SizedBox(height: 2.5.h),

                // ── Summary Pills (only when not loading) ───────────────
                if (!_isLoading && !_hasError && _bookings.isNotEmpty)
                  _buildSummaryPills(),

                if (!_isLoading && !_hasError && _bookings.isNotEmpty)
                  SizedBox(height: 2.h),

                // ── Tab Selector ────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: _buildTabSelector(),
                ),

                SizedBox(height: 2.h),

                // ── Content ─────────────────────────────────────────────
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.03),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: _buildContent(),
                  ),
                ),
              ],
            ),
          ),

          // ── Cancelling overlay ──────────────────────────────────────
          if (_isCancelling)
            Container(
              color: Colors.black.withOpacity(0.55),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 10.w,
                        height: 10.w,
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2.5,
                        ),
                      ),
                      SizedBox(height: 2.5.h),
                      Text(
                        'Cancelling booking...',
                        style: GoogleFonts.dmSans(
                          color: AppColors.textPrimary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Please wait a moment',
                        style: GoogleFonts.dmSans(
                          color: AppColors.textSecondary,
                          fontSize: 12.sp,
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

  Widget _buildHeader(int upcomingCount) {
    return Padding(
      padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'My Bookings',
                  style: GoogleFonts.dmSans(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.6,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 0.5.h),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    !_isLoading && upcomingCount > 0
                        ? '$upcomingCount upcoming session${upcomingCount > 1 ? 's' : ''}'
                        : 'Manage your sessions',
                    key: ValueKey(!_isLoading && upcomingCount > 0),
                    style: GoogleFonts.dmSans(
                      fontSize: 13.5.sp,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Refresh button
          GestureDetector(
            onTap: _isLoading ? null : _fetchBookings,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 11.w,
              height: 11.w,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.dividerColor, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      SolarIconsOutline.restart,
                      color: AppColors.textSecondary,
                      size: 16.sp,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryPills() {
    final totalBookings = _bookings.length;
    final upcomingCount = _bookings.where((b) => b.isUpcoming).length;
    final completedCount = _bookings.where((b) => b.isCompleted).length;
    final cancelledCount = _bookings.where((b) => b.isCancelled).length;

    return SizedBox(
      height: 5.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        physics: const BouncingScrollPhysics(),
        children: [
          _summaryPill(
            label: 'Upcoming',
            value: '$upcomingCount',
            color: AppColors.info,
            icon: SolarIconsOutline.clockCircle,
          ),
          SizedBox(width: 2.w),
          _summaryPill(
            label: 'Done',
            value: '$completedCount',
            color: AppColors.success,
            icon: SolarIconsOutline.checkCircle,
          ),
          SizedBox(width: 2.w),
          _summaryPill(
            label: 'Cancelled',
            value: '$cancelledCount',
            color: AppColors.error,
            icon: SolarIconsOutline.closeCircle,
          ),
          SizedBox(width: 2.w),
          _summaryPill(
            label: 'Total',
            value: '$totalBookings',
            color: AppColors.textSecondary,
            icon: SolarIconsOutline.calendar,
          ),
        ],
      ),
    );
  }

  Widget _summaryPill({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13.sp),
          SizedBox(width: 1.5.w),
          Text(
            '$value $label',
            style: GoogleFonts.dmSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      height: 6.2.h,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.dividerColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: _tabs.map((tab) {
          final isSelected = _selectedTab == tab;
          final count = _isLoading ? null : _filteredBookings(tab).length;

          Color tabColor = AppColors.info;
          if (tab == 'Completed') tabColor = AppColors.success;
          if (tab == 'Cancelled') tabColor = AppColors.error;

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _selectedTab = tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                margin: EdgeInsets.all(0.7.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? tabColor.withOpacity(0.14)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: isSelected
                      ? Border.all(color: tabColor.withOpacity(0.35), width: 1)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Text(
                            tab,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(
                              fontSize: 13.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? tabColor
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                        if (count != null && count > 0) ...[
                          SizedBox(width: 2.5.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? tabColor.withOpacity(0.25)
                                  : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$count',
                              style: GoogleFonts.dmSans(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? tabColor
                                    : AppColors.textTertiary,
                              ),
                            ),
                          ),
                          SizedBox(width: 2.w),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) return _buildSkeletonList();
    if (_hasError) return _buildErrorState();
    return _buildBookingList(_selectedTab);
  }

  Widget _buildErrorState() {
    return Center(
      key: const ValueKey('error'),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.dividerColor, width: 1.5),
              ),
              child: Icon(
                SolarIconsOutline.wifiRouterMinimalistic,
                color: AppColors.textTertiary,
                size: 30.sp,
              ),
            ),
            SizedBox(height: 2.5.h),
            Text(
              'Failed to load bookings',
              style: GoogleFonts.dmSans(
                color: AppColors.textPrimary,
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 0.8.h),
            Text(
              'Check your connection and try again',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                color: AppColors.textSecondary,
                fontSize: 13.sp,
                height: 1.5,
              ),
            ),
            SizedBox(height: 3.5.h),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'Try Again',
                variant: AppButtonVariant.solid,
                size: AppButtonSize.medium,
                icon: SolarIconsOutline.restart,
                borderRadius: 20,
                onPressed: _fetchBookings,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      key: const ValueKey('skeleton'),
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
      itemCount: 3,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, __) => _skeletonCard(),
    );
  }

  Widget _skeletonCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 3.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.dividerColor, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _shimmerBox(
              child: Container(
                height: 19.h,
                width: double.infinity,
                color: AppColors.surfaceLight,
              ),
            ),
            _shimmerBox(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.3.h),
                color: AppColors.surfaceLight.withOpacity(0.4),
                child: Row(
                  children: [
                    _skeletonBar(width: 18.w, height: 1.1.h),
                    SizedBox(width: 3.w),
                    _skeletonBar(width: 14.w, height: 1.1.h),
                    SizedBox(width: 3.w),
                    _skeletonBar(width: 12.w, height: 1.1.h),
                  ],
                ),
              ),
            ),
            Container(height: 0.5, color: AppColors.dividerColor),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.6.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _shimmerBox(child: _skeletonBar(width: 24.w, height: 1.h)),
                      SizedBox(height: 0.6.h),
                      _shimmerBox(child: _skeletonBar(width: 32.w, height: 2.2.h)),
                    ],
                  ),
                  _shimmerBox(child: _skeletonBar(width: 26.w, height: 4.h, radius: 20)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox({required Widget child}) {
    final anim = _shimmerAnim;
    if (anim == null) return child;
    return AnimatedBuilder(
      animation: anim,
      builder: (context, _) {
        final value = anim.value;
        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            child,
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(value * 2 - 1.0, 0),
                      end: Alignment(value * 2 - 0.5, 0),
                      colors: [
                        Colors.white.withOpacity(0),
                        Colors.white.withOpacity(0.12),
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.12),
                        Colors.white.withOpacity(0),
                      ],
                      stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _skeletonBar({
    required double width,
    required double height,
    double radius = 6,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _buildBookingList(String tab) {
    final filtered = _filteredBookings(tab);

    if (filtered.isEmpty) return _buildEmptyState(tab);

    return RefreshIndicator(
      onRefresh: _fetchBookings,
      color: AppColors.primary,
      backgroundColor: AppColors.cardBackground,
      displacement: 20,
      child: ListView.builder(
        key: ValueKey('list_$tab'),
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final booking = filtered[index];
          return BookingCard(
            booking: booking,
            onCancelPressed: booking.isUpcoming
                ? () => _showCancelDialog(booking)
                : null,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String tab) {
    final IconData icon;
    final String title;
    final String subtitle;

    if (tab == 'Upcoming') {
      icon = SolarIconsOutline.calendarDate;
      title = 'No upcoming sessions';
      subtitle = 'Book a recovery session\nto get started';
    } else if (tab == 'Completed') {
      icon = SolarIconsOutline.checkCircle;
      title = 'No completed sessions';
      subtitle = 'Your completed sessions\nwill appear here';
    } else {
      icon = SolarIconsOutline.closeCircle;
      title = 'No cancelled bookings';
      subtitle = 'Cancelled sessions\nwill appear here';
    }

    Color accentColor = AppColors.info;
    if (tab == 'Completed') accentColor = AppColors.success;
    if (tab == 'Cancelled') accentColor = AppColors.error;

    return Center(
      key: ValueKey('empty_$tab'),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: accentColor.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Icon(icon, color: accentColor, size: 32.sp),
            ),
            SizedBox(height: 2.8.h),
            Text(
              title,
              style: GoogleFonts.dmSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 13.5.sp,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            if (tab == 'Upcoming') ...[
              SizedBox(height: 4.h),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: 'Browse Services',
                  variant: AppButtonVariant.solid,
                  size: AppButtonSize.medium,
                  icon: SolarIconsOutline.calendarAdd,
                  iconPosition: AppButtonIconPosition.left,
                  borderRadius: 30,
                  onPressed: () => Navigator.pushNamed(context, Routes.navbar),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
