// pages/packages/tabs/combos_tab.dart

import 'package:flutter/material.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:sizer/sizer.dart';
// NOTE: Ensure your ComboCard is correctly imported here
import '../widgets/combo_card.dart';

class CombosTab extends StatelessWidget {
  const CombosTab({super.key});

  // Comprehensive data structure with 'isDetailed' set to true for all
  final List<Map<String, dynamic>> comboPackages = const [
    {
      'title': 'Massage + Spa Combo',
      'subtitle': 'Swedish Massage + Steam Room + Sauna',
      'duration': '120 Minutes',
      'details': 'Free towel & locker access',
      'price': '\$36',
      'imagePath': 'lib/assets/images/haven.jpg',

      'isDetailed': true,

      // Detail Page Data for "Massage + Spa Combo"
      'detail_title': 'Swedish Relaxation Experience',
      'detail_description':
          'A classic combination designed for pure relaxation. Enjoy a gentle Swedish massage followed by detoxifying time in the steam room and sauna.',
      'detail_imagePath': 'lib/assets/images/haven.jpg',
      'detail_totalDuration': '120 Minutes',
      'detail_price': '36',
      'detail_inclusions': [
        {
          'icon': 'icon_massage',
          'name': 'Swedish Massage',
          'duration': '60 min',
        },
        {
          'icon': 'icon_steam_room',
          'name': 'Steam Room Access',
          'duration': '30 min',
        },
        {'icon': 'icon_sauna', 'name': 'Sauna Session', 'duration': '30 min'},
      ],
    },
    {
      'title': 'Full Recovery Without Cupping',
      'subtitle': 'Deep Tissue Massage + Ice Bath + IV Drip',
      'duration': '150 Minutes',
      'details': 'Includes Normatec boots',
      'price': '\$85',
      'imagePath': 'lib/assets/images/spa.jpg',

      'isDetailed': true,

      // Detail Page Data for "Full Recovery Without Cupping" (Matching Screenshot)
      'detail_title': 'Full Body Reset – Recovery Combo',
      'detail_description':
          'Experience the ultimate wellness recovery with a powerful combination of therapeutic treatments designed to relax your body, reduce fatigue, and boost recovery.',
      'detail_imagePath': 'lib/assets/images/spa.jpg',
      'detail_totalDuration': '2 Hours',
      'detail_price': '250',
      'detail_inclusions': [
        {
          'icon': 'icon_deep_tissue',
          'name': 'Deep Tissue Massage',
          'duration': '60 min',
        },
        {
          'icon': 'icon_ice_bath',
          'name': 'Ice Bath Session',
          'duration': '30 min',
        },
        {'icon': 'icon_iv_drip', 'name': 'IV Detox Drip', 'duration': '30 min'},
      ],
    },
    {
      'title': 'Moroccan Bath + Relax Massage',
      'subtitle': 'Traditional Bath + Relaxation Massage',
      'duration': '120 Minutes',
      'details': 'Complimentary herbal drink',
      'price': '\$56',
      'imagePath': 'lib/assets/images/steam.jpg',

      'isDetailed': true,

      // Detail Page Data for "Moroccan Bath + Relax Massage"
      'detail_title': 'Deep Relaxation Moroccan Experience',
      'detail_description':
          'Enjoy a traditional purifying Moroccan Hammam followed by a soothing full-body relaxation massage to melt away tension.',
      'detail_imagePath': 'lib/assets/images/steam.jpg',
      'detail_totalDuration': '120 Minutes',
      'detail_price': '56',
      'detail_inclusions': [
        {'icon': 'icon_bath', 'name': 'Moroccan Hammam', 'duration': '60 min'},
        {
          'icon': 'icon_massage',
          'name': 'Relaxation Massage',
          'duration': '60 min',
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
      itemCount: comboPackages.length,
      itemBuilder: (context, index) {
        final package = comboPackages[index];

        return ComboCard(
          title: package['title'] as String,
          subtitle: package['subtitle'] as String,
          durationOrDetail: package['duration'] as String,
          detailLine: package['details'] as String,
          price: package['price'] as String,
          imagePath: package['imagePath'] as String,
          onBookNow: () {
            // Navigation logic now always executes
            Navigator.pushNamed(
              context,
              Routes.packageDetails,
              arguments: {
                'title': package['detail_title'] as String,
                'description': package['detail_description'] as String,
                'imagePath': package['detail_imagePath'] as String,
                'totalDuration': package['detail_totalDuration'] as String,
                'price': package['detail_price'] as String,
                'inclusions': package['detail_inclusions'],
              },
            );
          },
        );
      },
    );
  }
}
