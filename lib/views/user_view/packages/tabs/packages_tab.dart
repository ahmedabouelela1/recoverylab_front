import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recoverylab_front/models/Offer/offer_package.dart';
import 'package:recoverylab_front/providers/api/api_provider.dart';
import 'package:recoverylab_front/providers/exception/snack_bar.dart';
import 'package:recoverylab_front/views/user_view/packages/packages_details_page.dart';
import 'package:sizer/sizer.dart';
import '../widgets/package_card.dart';

class PackagesTab extends ConsumerStatefulWidget {
  const PackagesTab({super.key});

  @override
  ConsumerState<PackagesTab> createState() => _PackagesTabState();
}

class _PackagesTabState extends ConsumerState<PackagesTab> {
  List<OfferPackage> _packages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final result = await ref.read(apiProvider).getPackages(type: 'PACKAGE');
      if (mounted)
        setState(() {
          _packages = result;
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
    if (_packages.isEmpty) {
      return Center(
        child: Text(
          'No packages available',
          style: TextStyle(color: Colors.grey, fontSize: 14.sp),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
      itemCount: _packages.length,
      itemBuilder: (context, index) {
        final p = _packages[index];
        final credits = p.totalCredits;
        final discount = p.discountPercentage;
        final subtitle = credits != null
            ? 'Use any $credits session${credits > 1 ? 's' : ''}'
            : p.name;
        final durationOrDetail = discount != null
            ? '${discount.toInt()}% Off Per Session'
            : '';

        return PackageCard(
          badge: 'PACKAGE',
          title: p.name,
          subtitle: subtitle,
          durationOrDetail: durationOrDetail,
          detailLine: credits != null ? '$credits Credits' : '',
          price: p.price.toStringAsFixed(0),
          imagePath: 'lib/assets/images/haven.jpg',
          onBookNow: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PackageDetailsPage(
                itemId: p.id,
                type: PackageType.package,
                title: p.name,
                description: p.description ?? '',
                imagePath: 'lib/assets/images/haven.jpg',
                totalDuration: credits != null ? '$credits Sessions' : '',
                price: p.price.toStringAsFixed(0),
                inclusions: [
                  if (credits != null)
                    {
                      'icon': 'icon_massage',
                      'name': '$credits Massage Sessions (your choice)',
                      'duration': '',
                    },
                  if (discount != null)
                    {
                      'icon': 'icon_discount',
                      'name': '${discount.toInt()}% Off Per Session',
                      'duration': '',
                    },
                  if (p.validityDays != null)
                    {
                      'icon': 'icon_spa',
                      'name': 'Valid for ${p.validityDays} days',
                      'duration': '',
                    },
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
