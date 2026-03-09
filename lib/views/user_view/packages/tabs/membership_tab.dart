import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recoverylab_front/models/Offer/membership_plan.dart';
import 'package:recoverylab_front/providers/api/api_provider.dart';
import 'package:recoverylab_front/providers/exception/snack_bar.dart';
import 'package:recoverylab_front/views/user_view/packages/packages_details_page.dart';
import 'package:sizer/sizer.dart';
import '../widgets/package_card.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/components/shimmer_box.dart';

class MembershipTab extends ConsumerStatefulWidget {
  const MembershipTab({super.key});

  @override
  ConsumerState<MembershipTab> createState() => _MembershipTabState();
}

class _MembershipTabState extends ConsumerState<MembershipTab>
    with TickerProviderStateMixin {
  List<MembershipPlan> _plans = [];
  bool _loading = true;
  AnimationController? _shimmerController;
  Animation<double>? _shimmerAnim;

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
    _fetch();
  }

  @override
  void dispose() {
    _shimmerController?.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    try {
      final result = await ref.read(apiProvider).getMembershipPlans();
      if (mounted)
        setState(() {
          _plans = result;
          _loading = false;
        });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        AppSnackBar.show(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _buildShimmerList();
    }
    if (_plans.isEmpty) {
      return Center(
        child: Text(
          'No memberships available',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
      itemCount: _plans.length,
      itemBuilder: (context, index) {
        final p = _plans[index];
        final freezeStr = p.freezeWeeks != null
            ? '${p.freezeWeeks!.toInt()}-Week Freeze Period'
            : '';
        final discount = p.bestDiscountPercent;
        final detailLine = discount != null
            ? '${discount.toInt()}% Off All Services'
            : (p.hasUnlimitedAccess ? 'Full Spa Access' : '');
        final subtitle =
            '${p.durationMonths} Month${p.durationMonths > 1 ? 's' : ''}${p.hasUnlimitedAccess ? ' · Full Spa Access' : ''}';

        final inclusions = <Map<String, String>>[
          if (p.hasUnlimitedAccess)
            {
              'icon': 'icon_spa',
              'name': 'Full Spa Access',
              'duration': 'Unlimited',
            },
          if (freezeStr.isNotEmpty)
            {
              'icon': 'icon_freeze',
              'name': 'Freeze Period',
              'duration': '${p.freezeWeeks!.toInt()} Weeks',
            },
          ...p.benefits
              .where((b) => b.benefitType == 'DISCOUNT')
              .map(
                (b) => {
                  'icon': 'icon_discount',
                  'name': b.displayLabel,
                  'duration': '',
                },
              ),
        ];

        return PackageCard(
          badge: 'MEMBERSHIP',
          title: p.name,
          subtitle: subtitle,
          durationOrDetail: freezeStr,
          detailLine: detailLine,
          price: p.price.toStringAsFixed(0),
          imagePath: 'lib/assets/images/haven.jpg',
          onBookNow: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PackageDetailsPage(
                itemId: p.id,
                type: PackageType.membership,
                title: p.name,
                description: p.description ?? '',
                imagePath: 'lib/assets/images/haven.jpg',
                totalDuration:
                    '${p.durationMonths} Month${p.durationMonths > 1 ? 's' : ''}',
                price: p.price.toStringAsFixed(0),
                inclusions: inclusions,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerList() {
    final anim = _shimmerAnim;
    if (anim == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
      itemCount: 3,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, __) => _shimmerCard(anim),
    );
  }

  Widget _shimmerCard(Animation<double> anim) {
    return Container(
      margin: EdgeInsets.only(bottom: 4.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ShimmerBox(
              animation: anim,
              child: Container(
                height: 20.h,
                width: double.infinity,
                color: AppColors.surfaceLight,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(
                    animation: anim,
                    child: shimmerSkeletonBar(width: 50.w, height: 1.2.h),
                  ),
                  SizedBox(height: 0.8.h),
                  ShimmerBox(
                    animation: anim,
                    child: shimmerSkeletonBar(width: 70.w, height: 1.h),
                  ),
                  SizedBox(height: 0.8.h),
                  ShimmerBox(
                    animation: anim,
                    child: shimmerSkeletonBar(width: 30.w, height: 2.h, radius: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
