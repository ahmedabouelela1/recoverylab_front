// pages/packages/tabs/packages_tab.dart

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
// Note: Changed import to the unified component
import '../widgets/package_card.dart'; // Assuming you rename this file content to PackageListItem

class PackagesTab extends StatelessWidget {
  const PackagesTab({super.key});

  // Data from the Packages screenshot
  final List<Map<String, String>> individualPackages = const [
    {
      'title': '5-Session Wellness Pack',
      'subtitle': 'Choose any 5 massages (60-90 min)',
      'duration': '15% Off Total Value', // Reused field for the discount
      'details': '', // This line is empty in the screenshot for these packages
      'price': '\$125',
      'imagePath': 'lib/assets/images/haven.jpg', // Replace with actual path
    },
    {
      'title': '10-Session Body Boost',
      'subtitle': 'Mix of massages, baths, and spa services',
      'duration': '25% Off + 1 Free Spa Access',
      'details': '',
      'price': '\$225',
      'imagePath': 'lib/assets/images/steam.jpg', // Replace with actual path
    },
    {
      'title': '10-Session Body Boost',
      'subtitle': 'Mix of massages, baths, and spa services',
      'duration': '25% Off + 1 Free Spa Access',
      'details': '',
      'price': '\$225',
      'imagePath': 'lib/assets/images/retreat.jpg', // Replace with actual path
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
      itemCount: individualPackages.length,
      itemBuilder: (context, index) {
        final package = individualPackages[index];
        // Using PackageCard which now implements the full design
        return PackageCard(
          title: package['title']!,
          subtitle: package['subtitle']!,
          durationOrDetail: package['duration']!,
          detailLine: package['details']!,
          price: package['price']!,
          imagePath: package['imagePath']!,
          onBookNow: () => print("Booking ${package['title']} from Packages!"),
        );
      },
    );
  }
}
