// pages/packages/tabs/packages_tab.dart

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../widgets/package_card.dart';

class PackagesTab extends StatelessWidget {
  const PackagesTab({super.key});

  static const List<Map<String, String>> _packages = [
    {
      'title': '5-Session Wellness Pack',
      'subtitle': 'Choose any 5 massages (60–90 min each)',
      'duration': '15% Off Total Value',
      'details': '',
      'price': '4,700',
      'imagePath': 'lib/assets/images/haven.jpg',
    },
    {
      'title': '10-Session Body Boost',
      'subtitle': 'Mix of massages, baths, and spa services',
      'duration': '25% Off Total Value',
      'details': '1 Free Spa Access included',
      'price': '8,450',
      'imagePath': 'lib/assets/images/steam.jpg',
    },
    {
      'title': '10-Session Recovery Pro',
      'subtitle': 'Mix of massages, baths, and spa services',
      'duration': '25% Off Total Value',
      'details': '1 Free Spa Access included',
      'price': '8,450',
      'imagePath': 'lib/assets/images/retreat.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
      itemCount: _packages.length,
      itemBuilder: (context, index) {
        final p = _packages[index];
        return PackageCard(
          badge: 'PACKAGE',
          title: p['title']!,
          subtitle: p['subtitle']!,
          durationOrDetail: p['duration']!,
          detailLine: p['details']!,
          price: p['price']!,
          imagePath: p['imagePath']!,
          onBookNow: () {
            // TODO: navigate to package purchase flow
          },
        );
      },
    );
  }
}
