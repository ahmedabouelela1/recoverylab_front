// pages/packages/tabs/combos_tab.dart

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
// Note: Changed import to the unified component
import '../widgets/combo_card.dart'; // Assuming you rename this file content to PackageListItem

class CombosTab extends StatelessWidget {
  const CombosTab({super.key});

  // Data from the Combos screenshot
  final List<Map<String, String>> comboPackages = const [
    {
      'title': 'Massage + Spa Combo',
      'subtitle': 'Swedish Massage + Steam Room + Sauna',
      'duration': '120 Minutes',
      'details': 'Free towel & locker access',
      'price': '\$36',
      'imagePath': 'lib/assets/images/Offer.jpg', // Replace with actual path
    },
    {
      'title': 'Full Recovery Without Cupping',
      'subtitle': 'Deep Tissue Massage + Ice Bath + IV Drip',
      'duration': '150 Minutes',
      'details': 'Includes Normatec boots',
      'price': '\$85',
      'imagePath': 'lib/assets/images/haven.jpg', // Replace with actual path
    },
    {
      'title': 'Moroccan Bath + Relax Massage',
      'subtitle': 'Traditional Bath + Relaxation Massage',
      'duration': '120 Minutes',
      'details': 'Complimentary herbal drink',
      'price': '\$56',
      'imagePath': 'lib/assets/images/steam.jpg', // Replace with actual path
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
      itemCount: comboPackages.length,
      itemBuilder: (context, index) {
        final package = comboPackages[index];
        // Using ComboCard which now implements the full design
        return ComboCard(
          title: package['title']!,
          subtitle: package['subtitle']!,
          durationOrDetail: package['duration']!,
          detailLine: package['details']!,
          price: package['price']!,
          imagePath: package['imagePath']!,
          onBookNow: () => print("Booking ${package['title']} from Combos!"),
        );
      },
    );
  }
}
