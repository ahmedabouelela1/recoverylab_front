import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/models/User/user_points.dart';
import 'package:recoverylab_front/providers/api/api_provider.dart';
import 'package:recoverylab_front/providers/exception/snack_bar.dart';

class MyPointsPage extends ConsumerStatefulWidget {
  const MyPointsPage({super.key});

  @override
  ConsumerState<MyPointsPage> createState() => _MyPointsPageState();
}

class _MyPointsPageState extends ConsumerState<MyPointsPage> {
  UserPoints? _points;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ref.read(apiProvider).getMyPoints();
      if (mounted) setState(() { _points = data; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppSnackBar.show(context, e.toString());
      }
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
        title: Text(
          'My Points',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17.sp,
            color: AppColors.textPrimary,
          ),
        ),
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.cardBackground,
              onRefresh: _load,
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                children: [
                  _buildBalanceCard(),
                  SizedBox(height: 2.h),
                  _buildHowItWorksCard(),
                  SizedBox(height: 3.h),
                  _buildTransactionList(),
                ],
              ),
            ),
    );
  }

  Widget _buildBalanceCard() {
    final pts = _points;
    final balance = pts?.pointsBalance ?? 0;
    final redeemable = pts?.redeemableNow ?? 0;
    final egp = pts?.redeemableEgp ?? 0.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, const Color(0xFF1a2a50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(SolarIconsBold.star, color: Colors.white.withOpacity(0.8), size: 16.sp),
              SizedBox(width: 2.w),
              Text(
                'Points Balance',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            '$balance pts',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 32.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            '≈ ${egp.toStringAsFixed(2)} EGP redeemable',
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.75),
              fontSize: 12.sp,
            ),
          ),
          if (redeemable > 0) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'You can redeem $redeemable pts on your next booking',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHowItWorksCard() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerColor, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(SolarIconsOutline.infoCircle, color: AppColors.info, size: 16.sp),
              SizedBox(width: 2.w),
              Text(
                'How it works',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          _howRow(SolarIconsBold.star, 'Earn 1 pt for every 1 EGP spent on bookings & packages'),
          SizedBox(height: 1.h),
          _howRow(SolarIconsOutline.wallet, 'Redeem 100 pts = 1 EGP off your total'),
          SizedBox(height: 1.h),
          _howRow(SolarIconsOutline.chartSquare, 'Use up to 1% of your balance per transaction'),
        ],
      ),
    );
  }

  Widget _howRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 13.sp),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 0.4.h),
            child: Text(
              text,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp, height: 1.4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    final txList = _points?.transactions ?? [];

    if (txList.isEmpty) {
      return Container(
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.dividerColor, width: 0.8),
        ),
        child: Column(
          children: [
            Icon(SolarIconsOutline.history, color: AppColors.textTertiary, size: 28.sp),
            SizedBox(height: 1.h),
            Text(
              'No transactions yet',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Book a session or purchase a package to start earning points.',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 12.sp, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HISTORY',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: 1.2.h),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.dividerColor, width: 0.8),
          ),
          child: Column(
            children: txList.asMap().entries.map((entry) {
              final i = entry.key;
              final tx = entry.value;
              final isLast = i == txList.length - 1;
              return _buildTxRow(tx, isLast: isLast);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTxRow(PointTransaction tx, {bool isLast = false}) {
    final isDeduct = tx.points < 0;
    final color = isDeduct ? AppColors.error : AppColors.success;
    final sign = isDeduct ? '' : '+';

    IconData icon;
    Color iconBg;
    switch (tx.type) {
      case 'EARN':
        icon = SolarIconsBold.star;
        iconBg = AppColors.success;
        break;
      case 'REDEEM':
        icon = SolarIconsOutline.wallet;
        iconBg = AppColors.info;
        break;
      case 'REVERSAL':
        icon = SolarIconsOutline.arrowRight;
        iconBg = AppColors.warning;
        break;
      case 'MANUAL_ADJUST':
        icon = SolarIconsOutline.settings;
        iconBg = AppColors.textSecondary;
        break;
      default:
        icon = SolarIconsBold.star;
        iconBg = AppColors.success;
    }

    final date = _formatDate(tx.createdAt);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconBg, size: 15.sp),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.description ?? _txLabel(tx.type),
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.3.h),
                    Text(
                      date,
                      style: TextStyle(color: AppColors.textTertiary, fontSize: 11.sp),
                    ),
                  ],
                ),
              ),
              Text(
                '$sign${tx.points} pts',
                style: TextStyle(
                  color: color,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            color: AppColors.dividerColor,
            height: 1,
            thickness: 0.5,
            indent: 14.w,
            endIndent: 4.w,
          ),
      ],
    );
  }

  String _txLabel(String type) {
    switch (type) {
      case 'EARN': return 'Points earned';
      case 'REDEEM': return 'Points redeemed';
      case 'REVERSAL': return 'Points reversed';
      case 'MANUAL_ADJUST': return 'Manual adjustment';
      default: return 'Transaction';
    }
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}
