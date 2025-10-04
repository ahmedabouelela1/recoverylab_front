// pages/packages/tabs/membership_tab.dart

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
// Note: Changed import to the unified component
import '../widgets/membership_card.dart'; // Assuming you rename this file content to PackageListItem

class MembershipTab extends StatelessWidget {
  const MembershipTab({super.key});

  // Data from the Membership screenshot
  final List<Map<String, String>> membershipPackages = const [
    {
      'title': 'Platinum Membership',
      'subtitle': '12 Months',
      'duration': 'Full Spa Access', // Reused field for the first feature line
      'details': '12-Week Freeze Period\n25% Off All Services',
      'price': '\$230/year',
      'imagePath': 'lib/assets/images/haven.jpg', // Replace with actual path
    },
    {
      'title': 'Gold Membership',
      'subtitle': '6 Months',
      'duration': 'Full Spa Access',
      'details': '6-Week Freeze Period\n15% Off All Services',
      'price': '\$130/6 months',
      'imagePath': 'lib/assets/images/steam.jpg', // Replace with actual path
    },
    {
      'title': 'Silver Membership',
      'subtitle': '3 Months',
      'duration': 'Full Spa Access',
      'details': '2-Week Freeze Period\n10% Off All Services',
      'price': '\$65/3 months',
      'imagePath': 'lib/assets/images/spa.jpg', // Replace with actual path
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
      itemCount: membershipPackages.length,
      itemBuilder: (context, index) {
        final package = membershipPackages[index];
        // Using MembershipCard which now implements the full design
        return MembershipCard(
          title: package['title']!,
          subtitle: package['subtitle']!,
          durationOrDetail: package['duration']!,
          detailLine: package['details']!,
          price: package['price']!,
          imagePath: package['imagePath']!,
          onBookNow: () =>
              print("Booking ${package['title']} from Membership!"),
        );
      },
    );
  }
}
