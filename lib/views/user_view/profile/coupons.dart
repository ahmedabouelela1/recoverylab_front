import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/models/Coupon/user_coupon.dart';
import 'package:recoverylab_front/providers/api/api_provider.dart';
import 'package:recoverylab_front/providers/exception/exception_handling.dart';
import 'package:recoverylab_front/providers/exception/snack_bar.dart';

class CouponsPage extends ConsumerStatefulWidget {
  const CouponsPage({super.key});

  @override
  ConsumerState<CouponsPage> createState() => _CouponsPageState();
}

class _CouponsPageState extends ConsumerState<CouponsPage> {
  final _codeCtrl = TextEditingController();
  List<UserCoupon> _coupons = [];
  bool _isLoading = true;
  bool _isRedeeming = false;

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCoupons() async {
    setState(() => _isLoading = true);
    try {
      final coupons = await ref.read(apiProvider).getUserCoupons();
      if (!mounted) return;
      setState(() => _coupons = coupons);
    } on ApiException catch (e) {
      if (!mounted) return;
      AppSnackBar.show(context, e.message);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(context, 'Failed to load coupons.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _redeem() async {
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.isEmpty) return;
    setState(() => _isRedeeming = true);
    try {
      await ref.read(apiProvider).redeemCoupon(code);
      if (!mounted) return;
      _codeCtrl.clear();
      AppSnackBar.show(context, 'Coupon added to your wallet!');
      await _loadCoupons();
    } on ApiException catch (e) {
      if (!mounted) return;
      AppSnackBar.show(context, e.message);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(context, 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isRedeeming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 16),
          ),
        ),
        title: Text(
          'My Coupons',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.sp, color: AppColors.textPrimary),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadCoupons,
        color: AppColors.primary,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          children: [
            _sectionLabel('REDEEM A CODE'),
            SizedBox(height: 1.h),
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.dividerColor, width: 0.8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _codeCtrl,
                      textCapitalization: TextCapitalization.characters,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14.sp,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: 'ENTER CODE',
                        hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 13.sp, letterSpacing: 1.5),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
                        prefixIcon: Icon(SolarIconsOutline.ticket, color: AppColors.primary, size: 18.sp),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 2.w),
                    child: TextButton(
                      onPressed: _isRedeeming ? null : _redeem,
                      child: Text(
                        _isRedeeming ? '...' : 'Apply',
                        style: TextStyle(
                          color: _isRedeeming ? AppColors.textTertiary : AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 3.h),
            if (_isLoading)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (_coupons.isEmpty)
              _emptyCoupons()
            else ...[
              _sectionLabel('AVAILABLE'),
              SizedBox(height: 1.h),
              ..._coupons.map((uc) => _CouponCard(userCoupon: uc)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _emptyCoupons() => Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Column(
          children: [
            Icon(SolarIconsOutline.ticket, size: 40.sp, color: AppColors.textTertiary),
            SizedBox(height: 2.h),
            Text('No coupons yet',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 1.h),
            Text('Enter a code above to add one',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 12.sp)),
          ],
        ),
      );

  Widget _sectionLabel(String text) => Text(
        text,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      );
}

class _CouponCard extends StatelessWidget {
  final UserCoupon userCoupon;
  const _CouponCard({required this.userCoupon});

  @override
  Widget build(BuildContext context) {
    final coupon = userCoupon.coupon;
    final bool isGifted = userCoupon.giftedByUserId != null;
    final Color accentColor = coupon.type == 'GIFT_SESSION'
        ? AppColors.success
        : coupon.type == 'GIFT_CARD'
            ? AppColors.info
            : AppColors.primary;

    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerColor, width: 0.8),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 1.2.w,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.8.h),
                child: Row(
                  children: [
                    Icon(SolarIconsOutline.ticket, color: accentColor, size: 22.sp),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            coupon.code,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(height: 0.4.h),
                          Text(
                            coupon.discountLabel,
                            style: TextStyle(color: accentColor, fontSize: 12.sp, fontWeight: FontWeight.w600),
                          ),
                          if (isGifted) ...[
                            SizedBox(height: 0.3.h),
                            Text('Gifted to you',
                                style: TextStyle(color: AppColors.textTertiary, fontSize: 10.sp)),
                          ],
                          if (coupon.expiresAt != null) ...[
                            SizedBox(height: 0.3.h),
                            Text('Expires ${_formatExpiry(coupon.expiresAt!)}',
                                style: TextStyle(color: AppColors.textTertiary, fontSize: 10.sp)),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.6.h),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        coupon.discountLabel,
                        style: TextStyle(color: accentColor, fontSize: 10.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatExpiry(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}
