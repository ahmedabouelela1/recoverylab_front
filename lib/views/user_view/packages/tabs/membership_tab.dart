// pages/packages/tabs/membership_tab.dart

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../widgets/package_card.dart';

class MembershipTab extends StatelessWidget {
  const MembershipTab({super.key});

  static const List<Map<String, String>> _memberships = [
    {
      'title': 'Platinum Membership',
      'subtitle': '12 Months · Full Spa Access',
      'duration': '12-Week Freeze Period',
      'details': '25% Off All Services',
      'price': '8,600 / year',
      'imagePath': 'lib/assets/images/haven.jpg',
    },
    {
      'title': 'Gold Membership',
      'subtitle': '6 Months · Full Spa Access',
      'duration': '6-Week Freeze Period',
      'details': '15% Off All Services',
      'price': '4,900 / 6 months',
      'imagePath': 'lib/assets/images/steam.jpg',
    },
    {
      'title': 'Silver Membership',
      'subtitle': '3 Months · Full Spa Access',
      'duration': '2-Week Freeze Period',
      'details': '10% Off All Services',
      'price': '2,450 / 3 months',
      'imagePath': 'lib/assets/images/spa.jpg',
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
          title: p['title']!,
          subtitle: p['subtitle']!,
          durationOrDetail: p['duration']!,
          detailLine: p['details']!,
          price: p['price']!,
          imagePath: p['imagePath']!,
          onBookNow: () {
            // TODO: navigate to membership purchase flow
          },
        );
      },
    );
  }
}
