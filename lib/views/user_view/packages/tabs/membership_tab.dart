import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recoverylab_front/models/Offer/membership_plan.dart';
import 'package:recoverylab_front/providers/api/api_provider.dart';
import 'package:recoverylab_front/providers/exception/snack_bar.dart';
import 'package:recoverylab_front/views/user_view/packages/packages_details_page.dart';
import 'package:sizer/sizer.dart';
import '../widgets/package_card.dart';

class MembershipTab extends ConsumerStatefulWidget {
  const MembershipTab({super.key});

  @override
  ConsumerState<MembershipTab> createState() => _MembershipTabState();
}

class _MembershipTabState extends ConsumerState<MembershipTab> {
  List<MembershipPlan> _plans = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
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
      return const Center(child: CircularProgressIndicator());
    }
    if (_plans.isEmpty) {
      return Center(
        child: Text(
          'No memberships available',
          style: TextStyle(color: Colors.grey, fontSize: 14.sp),
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
}
