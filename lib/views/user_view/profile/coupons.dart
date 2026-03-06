import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/components/app_button.dart';

class CouponsPage extends StatefulWidget {
  const CouponsPage({super.key});

  @override
  State<CouponsPage> createState() => _CouponsPageState();
}

class _CouponsPageState extends State<CouponsPage> {
  final _codeCtrl = TextEditingController();
  bool _isRedeeming = false;

  // Mock coupons — replace with API data
  final List<Map<String, dynamic>> _coupons = [
    {
      'code': 'WELCOME20',
      'desc': '20% off your first booking',
      'expiry': '31 Dec 2025',
      'used': false,
      'discount': '20%',
    },
    {
      'code': 'SPA15',
      'desc': '15% off any spa service',
      'expiry': '28 Feb 2026',
      'used': false,
      'discount': '15%',
    },
    {
      'code': 'SUMMER10',
      'desc': '10% off summer sessions',
      'expiry': '30 Jun 2025',
      'used': true,
      'discount': '10%',
    },
  ];

  Future<void> _redeem() async {
    if (_codeCtrl.text.trim().isEmpty) return;
    setState(() => _isRedeeming = true);
    await Future.delayed(const Duration(milliseconds: 800)); // TODO: API
    if (!mounted) return;
    setState(() => _isRedeeming = false);
    _codeCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
        margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          'Coupon added successfully!',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = _coupons.where((c) => !(c['used'] as bool)).toList();
    final expired = _coupons.where((c) => (c['used'] as bool)).toList();

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
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
              size: 16,
            ),
          ),
        ),
        title: Text(
          'Coupons',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17.sp,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        children: [
          // Redeem input
          _sectionLabel('REDEEM A COUPON'),
          SizedBox(height: 1.2.h),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.dividerColor,
                      width: 0.8,
                    ),
                  ),
                  child: TextField(
                    controller: _codeCtrl,
                    textCapitalization: TextCapitalization.characters,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                    decoration: InputDecoration(
                      hintText: 'ENTER CODE',
                      hintStyle: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 13.sp,
                        letterSpacing: 1.5,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 2.h,
                      ),
                      prefixIcon: Icon(
                        SolarIconsOutline.ticket,
                        color: AppColors.textTertiary,
                        size: 16.sp,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              AppButton(
                label: _isRedeeming ? '...' : 'Apply',
                onPressed: _isRedeeming ? null : _redeem,
                size: AppButtonSize.medium,
                borderRadius: 16,
                width: 22.w,
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Active coupons
          if (active.isNotEmpty) ...[
            _sectionLabel('YOUR COUPONS (${active.length})'),
            SizedBox(height: 1.2.h),
            ...active.map((c) => _couponCard(c, used: false)),
            SizedBox(height: 3.h),
          ],

          // Used coupons
          if (expired.isNotEmpty) ...[
            _sectionLabel('USED COUPONS'),
            SizedBox(height: 1.2.h),
            ...expired.map((c) => _couponCard(c, used: true)),
          ],

          if (_coupons.isEmpty) _empty(),

          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _couponCard(Map<String, dynamic> coupon, {required bool used}) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: used
            ? AppColors.cardBackground.withOpacity(0.5)
            : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: used
              ? AppColors.dividerColor
              : AppColors.success.withOpacity(0.3),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          // Left accent
          Container(
            width: 4,
            height: 90,
            decoration: BoxDecoration(
              color: used ? AppColors.textTertiary : AppColors.success,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: used
                          ? AppColors.textTertiary.withOpacity(0.1)
                          : AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      SolarIconsOutline.ticket,
                      color: used ? AppColors.textTertiary : AppColors.success,
                      size: 18.sp,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              coupon['code'] as String,
                              style: TextStyle(
                                color: used
                                    ? AppColors.textTertiary
                                    : AppColors.textPrimary,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                                decoration: used
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: used
                                    ? AppColors.textTertiary.withOpacity(0.1)
                                    : AppColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                coupon['discount'] as String,
                                style: TextStyle(
                                  color: used
                                      ? AppColors.textTertiary
                                      : AppColors.success,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 0.4.h),
                        Text(
                          coupon['desc'] as String,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(height: 0.4.h),
                        Row(
                          children: [
                            Icon(
                              SolarIconsOutline.calendarDate,
                              color: AppColors.textTertiary,
                              size: 11.sp,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              used ? 'Used' : 'Expires ${coupon['expiry']}',
                              style: TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!used)
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: coupon['code'] as String),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.cardBackground,
                            margin: EdgeInsets.symmetric(
                              horizontal: 5.w,
                              vertical: 2.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            content: Text(
                              'Code copied!',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13.sp,
                              ),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Icon(
                        SolarIconsOutline.copy,
                        color: AppColors.info,
                        size: 16.sp,
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

  Widget _empty() {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 6.h),
          Icon(
            SolarIconsOutline.ticket,
            size: 48.sp,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: 2.h),
          Text(
            'No coupons yet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Enter a code above to redeem a coupon',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: TextStyle(
      color: AppColors.textSecondary,
      fontSize: 12.sp,
      fontWeight: FontWeight.bold,
      letterSpacing: 2,
    ),
  );
}
