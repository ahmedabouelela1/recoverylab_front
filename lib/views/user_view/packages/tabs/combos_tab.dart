import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recoverylab_front/models/Offer/offer_package.dart';
import 'package:recoverylab_front/providers/api/api_provider.dart';
import 'package:recoverylab_front/providers/exception/snack_bar.dart';
import 'package:recoverylab_front/views/user_view/packages/packages_details_page.dart';
import 'package:sizer/sizer.dart';
import '../widgets/package_card.dart';

class CombosTab extends ConsumerStatefulWidget {
  const CombosTab({super.key});

  @override
  ConsumerState<CombosTab> createState() => _CombosTabState();
}

class _CombosTabState extends ConsumerState<CombosTab> {
  List<OfferPackage> _combos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
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
      return const Center(child: CircularProgressIndicator());
    }
    if (_combos.isEmpty) {
      return Center(
        child: Text(
          'No combos available',
          style: TextStyle(color: Colors.grey, fontSize: 14.sp),
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
}
