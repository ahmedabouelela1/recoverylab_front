import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recoverylab_front/models/Offer/offer_package.dart';
import 'package:recoverylab_front/providers/api/api_provider.dart';
import 'package:recoverylab_front/providers/exception/snack_bar.dart';
import 'package:recoverylab_front/views/user_view/packages/packages_details_page.dart';
import 'package:sizer/sizer.dart';
import '../widgets/package_card.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/components/shimmer_box.dart';

class CombosTab extends ConsumerStatefulWidget {
  const CombosTab({super.key});

  @override
  ConsumerState<CombosTab> createState() => _CombosTabState();
}

class _CombosTabState extends ConsumerState<CombosTab>
    with TickerProviderStateMixin {
  List<OfferPackage> _combos = [];
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
      final result = await ref.read(apiProvider).getPackages(type: 'COMBO');
      if (mounted)
        setState(() {
          _combos = result;
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
    if (_combos.isEmpty) {
      return Center(
        child: Text(
          'No combos available',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
      itemCount: _combos.length,
      itemBuilder: (context, index) {
        final p = _combos[index];
        final subtitle = p.rules
            .map((r) => r.serviceName ?? 'Service ${r.serviceId}')
            .join(' · ');
        final totalMin = p.totalDurationMinutes;
        final durationStr = totalMin > 0 ? '$totalMin min' : '';

        return PackageCard(
          badge: 'COMBO',
          title: p.name,
          subtitle: subtitle,
          durationOrDetail: durationStr,
          detailLine: '',
          price: p.price.toStringAsFixed(0),
          imagePath: 'lib/assets/images/haven.jpg',
          onBookNow: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PackageDetailsPage(
                itemId: p.id,
                type: PackageType.combo,
                title: p.name,
                description: p.description ?? '',
                imagePath: 'lib/assets/images/haven.jpg',
                totalDuration: durationStr,
                price: p.price.toStringAsFixed(0),
                inclusions: p.rules
                    .map(
                      (r) => {
                        'icon': 'icon_massage',
                        'name': r.serviceName ?? 'Service ${r.serviceId}',
                        'duration': '${r.durationMinutes} min',
                      },
                    )
                    .toList(),
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
