// pages/packages/tabs/membership_tab.dart

import 'package:flutter/material.dart';
import 'package:recoverylab_front/views/user_view/packages/packages_details_page.dart';
import 'package:sizer/sizer.dart';
import '../widgets/package_card.dart';

class MembershipTab extends StatelessWidget {
  const MembershipTab({super.key});

  static const List<Map<String, dynamic>> _memberships = [
    {
      'title': 'Platinum Membership',
      'subtitle': '12 Months · Full Spa Access',
      'duration': '12-Week Freeze Period',
      'details': '25% Off All Services',
      'price': '8,600 / year',
      'imagePath': 'lib/assets/images/haven.jpg',
      'detail_title': 'Platinum Membership',
      'detail_description':
          'Our most exclusive membership. Enjoy unlimited full spa access for 12 months, the longest freeze period, and the highest service discount available.',
      'detail_imagePath': 'lib/assets/images/haven.jpg',
      'detail_totalDuration': '12 Months',
      'detail_price': '8,600 / year',
      'detail_inclusions': [
        {
          'icon': 'icon_spa',
          'name': 'Full Spa Access',
          'duration': 'Unlimited',
        },
        {
          'icon': 'icon_freeze',
          'name': 'Freeze Period',
          'duration': '12 Weeks',
        },
        {
          'icon': 'icon_discount',
          'name': '25% Off All Services',
          'duration': '',
        },
        {'icon': 'icon_locker', 'name': 'Dedicated Locker', 'duration': ''},
      ],
    },
    {
      'title': 'Gold Membership',
      'subtitle': '6 Months · Full Spa Access',
      'duration': '6-Week Freeze Period',
      'details': '15% Off All Services',
      'price': '4,900 / 6 months',
      'imagePath': 'lib/assets/images/steam.jpg',
      'detail_title': 'Gold Membership',
      'detail_description':
          'Enjoy six months of full spa access with a generous freeze option and a 15% discount on all services throughout your membership.',
      'detail_imagePath': 'lib/assets/images/steam.jpg',
      'detail_totalDuration': '6 Months',
      'detail_price': '4,900 / 6 months',
      'detail_inclusions': [
        {
          'icon': 'icon_spa',
          'name': 'Full Spa Access',
          'duration': 'Unlimited',
        },
        {'icon': 'icon_freeze', 'name': 'Freeze Period', 'duration': '6 Weeks'},
        {
          'icon': 'icon_discount',
          'name': '15% Off All Services',
          'duration': '',
        },
      ],
    },
    {
      'title': 'Silver Membership',
      'subtitle': '3 Months · Full Spa Access',
      'duration': '2-Week Freeze Period',
      'details': '10% Off All Services',
      'price': '2,450 / 3 months',
      'imagePath': 'lib/assets/images/spa.jpg',
      'detail_title': 'Silver Membership',
      'detail_description':
          'A great entry-level membership giving you three months of full spa access and a 10% discount on all services.',
      'detail_imagePath': 'lib/assets/images/spa.jpg',
      'detail_totalDuration': '3 Months',
      'detail_price': '2,450 / 3 months',
      'detail_inclusions': [
        {
          'icon': 'icon_spa',
          'name': 'Full Spa Access',
          'duration': 'Unlimited',
        },
        {'icon': 'icon_freeze', 'name': 'Freeze Period', 'duration': '2 Weeks'},
        {
          'icon': 'icon_discount',
          'name': '10% Off All Services',
          'duration': '',
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
      itemCount: _memberships.length,
      itemBuilder: (context, index) {
        final p = _memberships[index];
        return PackageCard(
          badge: 'MEMBERSHIP',
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
                type: PackageType.membership,
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
