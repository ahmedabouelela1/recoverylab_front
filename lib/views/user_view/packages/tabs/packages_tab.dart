// pages/packages/tabs/packages_tab.dart

import 'package:flutter/material.dart';
import 'package:recoverylab_front/views/user_view/packages/packages_details_page.dart';
import 'package:sizer/sizer.dart';
import '../widgets/package_card.dart';

class PackagesTab extends StatelessWidget {
  const PackagesTab({super.key});

  static const List<Map<String, dynamic>> _packages = [
    {
      'title': '5-Session Wellness Pack',
      'subtitle': 'Choose any 5 massages (60–90 min each)',
      'duration': '15% Off Total Value',
      'details': '',
      'price': '4,700',
      'imagePath': 'lib/assets/images/haven.jpg',
      'detail_title': '5-Session Wellness Pack',
      'detail_description':
          'Flexibility at its finest. Choose any 5 massage sessions from our full menu, each 60–90 minutes, at a 15% discount off the regular price.',
      'detail_imagePath': 'lib/assets/images/haven.jpg',
      'detail_totalDuration': '5 Sessions',
      'detail_price': '4,700',
      'detail_inclusions': [
        {
          'icon': 'icon_massage',
          'name': '5 Massage Sessions (your choice)',
          'duration': '60–90 min each',
        },
        {
          'icon': 'icon_discount',
          'name': '15% Off Total Value',
          'duration': '',
        },
        {
          'icon': 'icon_locker',
          'name': 'Free Locker Access per Visit',
          'duration': '',
        },
      ],
    },
    {
      'title': '10-Session Body Boost',
      'subtitle': 'Mix of massages, baths, and spa services',
      'duration': '25% Off Total Value',
      'details': '1 Free Spa Access included',
      'price': '8,450',
      'imagePath': 'lib/assets/images/steam.jpg',
      'detail_title': '10-Session Body Boost',
      'detail_description':
          'Our most popular multi-session package. Enjoy a flexible mix of massages, baths, and spa services at a 25% discount, plus one complimentary spa access pass.',
      'detail_imagePath': 'lib/assets/images/steam.jpg',
      'detail_totalDuration': '10 Sessions',
      'detail_price': '8,450',
      'detail_inclusions': [
        {
          'icon': 'icon_massage',
          'name': '10 Mixed Sessions',
          'duration': '60–90 min each',
        },
        {
          'icon': 'icon_discount',
          'name': '25% Off Total Value',
          'duration': '',
        },
        {'icon': 'icon_spa', 'name': '1 Free Spa Access', 'duration': ''},
        {
          'icon': 'icon_locker',
          'name': 'Free Locker Access per Visit',
          'duration': '',
        },
      ],
    },
    {
      'title': '10-Session Recovery Pro',
      'subtitle': 'Mix of massages, baths, and spa services',
      'duration': '25% Off Total Value',
      'details': '1 Free Spa Access included',
      'price': '8,450',
      'imagePath': 'lib/assets/images/retreat.jpg',
      'detail_title': '10-Session Recovery Pro',
      'detail_description':
          'Focused on recovery and performance. This pack prioritises deep tissue, ice baths, and IV therapies, all at a 25% discount plus a free spa session.',
      'detail_imagePath': 'lib/assets/images/retreat.jpg',
      'detail_totalDuration': '10 Sessions',
      'detail_price': '8,450',
      'detail_inclusions': [
        {
          'icon': 'icon_deep_tissue',
          'name': '10 Recovery Sessions',
          'duration': '60–90 min each',
        },
        {
          'icon': 'icon_discount',
          'name': '25% Off Total Value',
          'duration': '',
        },
        {'icon': 'icon_spa', 'name': '1 Free Spa Access', 'duration': ''},
        {
          'icon': 'icon_ice_bath',
          'name': 'Priority Ice Bath Booking',
          'duration': '',
        },
      ],
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
          title: p['title'] as String,
          subtitle: p['subtitle'] as String,
          durationOrDetail: p['duration'] as String,
          detailLine: p['details'] as String,
          price: p['price'] as String,
          imagePath: p['imagePath'] as String,
          onBookNow: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PackageDetailsPage(
                type: PackageType.package,
                title: p['detail_title'] as String,
                description: p['detail_description'] as String,
                imagePath: p['detail_imagePath'] as String,
                totalDuration: p['detail_totalDuration'] as String,
                price: p['detail_price'] as String,
                inclusions: List<Map<String, String>>.from(
                  (p['detail_inclusions'] as List).map(
                    (e) => Map<String, String>.from(e as Map),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
