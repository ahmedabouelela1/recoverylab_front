// pages/details/package_details_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/components/app_button.dart';
import 'package:recoverylab_front/providers/api/api_provider.dart';
import 'package:recoverylab_front/providers/exception/snack_bar.dart';
import 'package:recoverylab_front/providers/session/user_session_provider.dart';
import 'package:recoverylab_front/providers/session/active_membership_provider.dart';
import 'package:recoverylab_front/views/user_view/packages/combo_booking_screen.dart';

enum PackageType { combo, membership, package }

class PackageDetailsPage extends ConsumerStatefulWidget {
  final String title;
  final String description;
  final String imagePath;
  final String totalDuration;
  final String price;
  final List<Map<String, String>> inclusions;

  /// Drives the badge label + accent color. Defaults to combo.
  final PackageType type;

  /// Backend ID — used when calling purchase/membership APIs.
  final int? itemId;

  const PackageDetailsPage({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.totalDuration,
    required this.price,
    required this.inclusions,
    this.type = PackageType.combo,
    this.itemId,
  });

  @override
  ConsumerState<PackageDetailsPage> createState() => _PackageDetailsPageState();
}

class _PackageDetailsPageState extends ConsumerState<PackageDetailsPage> {
  bool _showFull = false;
  bool _actionLoading = false;

  Future<void> _handleAction() async {
    final id = widget.itemId;
    if (id == null) return;

    final session = ref.read(userSessionProvider);
    final userId = session.user?.id;
    if (userId == null) {
      AppSnackBar.show(context, 'Please log in to continue.');
      return;
    }

    switch (widget.type) {
      case PackageType.combo:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ComboBookingScreen(
              comboId: id,
              comboName: widget.title,
              price: widget.price,
              totalDuration: widget.totalDuration,
              inclusions: widget.inclusions,
            ),
          ),
        );
        break;

      case PackageType.package:
        setState(() => _actionLoading = true);
        try {
          await ref.read(apiProvider).purchasePackage(
                userId: userId,
                packageId: id,
              );
          if (mounted) {
            AppSnackBar.show(context, 'Package purchased successfully!');
            Navigator.pop(context);
          }
        } catch (e) {
          if (mounted) AppSnackBar.show(context, e.toString());
        } finally {
          if (mounted) setState(() => _actionLoading = false);
        }
        break;

      case PackageType.membership:
        setState(() => _actionLoading = true);
        try {
          final now = DateTime.now();
          final today =
              '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
          await ref.read(apiProvider).purchaseMembership(
                userId: userId,
                membershipPlanId: id,
                startDate: today,
              );
          if (mounted) {
            ref.invalidate(activeMembershipProvider);
            AppSnackBar.show(context, 'Membership activated!');
            Navigator.pop(context);
          }
        } catch (e) {
          if (mounted) AppSnackBar.show(context, e.toString());
        } finally {
          if (mounted) setState(() => _actionLoading = false);
        }
        break;
    }
  }

  // ── Type-driven values ───────────────────────────────────────────────────

  Color get _accentColor => AppColors.info;

  String get _badgeLabel {
    switch (widget.type) {
      case PackageType.combo:
        return 'COMBO';
      case PackageType.membership:
        return 'MEMBERSHIP';
      case PackageType.package:
        return 'PACKAGE';
    }
  }

  String get _bookButtonLabel {
    switch (widget.type) {
      case PackageType.combo:
        return 'Book Now';
      case PackageType.membership:
        return 'Get Membership';
      case PackageType.package:
        return 'Buy Package';
    }
  }

  String get _priceSublabel {
    switch (widget.type) {
      case PackageType.combo:
        return 'TOTAL PRICE';
      case PackageType.membership:
        return 'MEMBERSHIP FEE';
      case PackageType.package:
        return 'PACKAGE PRICE';
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

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
                      SizedBox(height: 2.h),

                      // Title + badge row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.title,
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                height: 1.15,
                              ),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 3.w,
                              vertical: 0.7.h,
                            ),
                            decoration: BoxDecoration(
                              color: _accentColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _accentColor.withOpacity(0.35),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _badgeLabel,
                              style: TextStyle(
                                color: _accentColor,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.5.h),

                      // Summary chips
                      Wrap(
                        spacing: 2.w,
                        runSpacing: 1.h,
                        children: [
                          if (widget.totalDuration.isNotEmpty)
                            _chip(
                              SolarIconsOutline.clockCircle,
                              widget.totalDuration,
                            ),
                          _chip(
                            SolarIconsOutline.wallet,
                            'EGP ${widget.price}',
                            color: _accentColor,
                          ),
                        ],
                      ),
                      SizedBox(height: 2.5.h),

                      // ── About ──────────────────────────────────────────
                      _sectionLabel('ABOUT THIS ${_badgeLabel}'),
                      SizedBox(height: 1.2.h),
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.dividerColor,
                            width: 0.8,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.description,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.textSecondary,
                                height: 1.6,
                              ),
                              maxLines: _showFull ? null : 3,
                              overflow: _showFull
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                            ),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _showFull = !_showFull),
                              child: Padding(
                                padding: EdgeInsets.only(top: 1.h),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _showFull ? 'Read less' : 'Read more',
                                      style: TextStyle(
                                        color: AppColors.info,
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 1.w),
                                    Icon(
                                      _showFull
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: AppColors.info,
                                      size: 16.sp,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 2.5.h),

                      // ── What's included ────────────────────────────────
                      _sectionLabel("WHAT'S INCLUDED"),
                      SizedBox(height: 1.2.h),
                      ...widget.inclusions.map(_inclusionRow),
                      SizedBox(height: 2.5.h),

                      // ── Details card ───────────────────────────────────
                      _sectionLabel('DETAILS'),
                      SizedBox(height: 1.2.h),
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.dividerColor,
                            width: 0.8,
                          ),
                        ),
                        child: Column(
                          children: [
                            if (widget.totalDuration.isNotEmpty) ...[
                              _detailRow(
                                icon: SolarIconsOutline.clockCircle,
                                label: 'Total Duration',
                                value: widget.totalDuration,
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 1.2.h),
                                height: 0.5,
                                color: AppColors.dividerColor,
                              ),
                            ],
                            _detailRow(
                              icon: SolarIconsOutline.wallet,
                              label: _priceSublabel
                                  .split(' ')
                                  .map(
                                    (w) => w[0] + w.substring(1).toLowerCase(),
                                  )
                                  .join(' '),
                              value: 'EGP ${widget.price}',
                              valueColor: AppColors.textPrimary,
                              valueBold: true,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 12.h),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Bottom bar ──────────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                border: Border(
                  top: BorderSide(color: AppColors.dividerColor, width: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _priceSublabel,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: 0.4.h),
                      Text(
                        'EGP ${widget.price}',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: AppButton(
                      label: _actionLoading ? 'Please wait…' : _bookButtonLabel,
                      width: double.infinity,
                      borderRadius: 16,
                      size: AppButtonSize.large,
                      onPressed: _actionLoading ? null : _handleAction,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sliver App Bar ────────────────────────────────────────────────────────

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 30.h,
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
        '${_badgeLabel[0]}${_badgeLabel.substring(1).toLowerCase()} Details',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16.sp,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              widget.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.surfaceLight,
                alignment: Alignment.center,
                child: Icon(
                  SolarIconsOutline.health,
                  color: AppColors.textTertiary,
                  size: 44.sp,
                ),
              ),
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
            // Type badge on image
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.7.h),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _accentColor.withOpacity(0.5),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  _badgeLabel,
                  style: TextStyle(
                    color: _accentColor,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

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

  Widget _chip(IconData icon, String label, {Color? color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.9.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerColor, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color ?? AppColors.textTertiary, size: 12.sp),
          SizedBox(width: 1.5.w),
          Text(
            label,
            style: TextStyle(
              color: color != null
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _inclusionRow(Map<String, String> item) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerColor, width: 0.8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _iconForKey(item['icon'] ?? ''),
              color: _accentColor,
              size: 16.sp,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? '',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if ((item['duration'] ?? '').isNotEmpty) ...[
                  SizedBox(height: 0.3.h),
                  Text(
                    item['duration']!,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            SolarIconsOutline.checkCircle,
            color: AppColors.success,
            size: 16.sp,
          ),
        ],
      ),
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool valueBold = false,
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
            color: valueColor ?? AppColors.textSecondary,
            fontSize: 14.sp,
            fontWeight: valueBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  IconData _iconForKey(String key) {
    switch (key) {
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
}
