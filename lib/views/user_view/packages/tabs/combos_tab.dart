// pages/packages/tabs/combos_tab.dart

import 'package:flutter/material.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:sizer/sizer.dart';
import '../widgets/package_card.dart';

class CombosTab extends StatelessWidget {
  const CombosTab({super.key});

  static const List<Map<String, dynamic>> _combos = [
    {
      'title': 'Massage + Spa Combo',
      'subtitle': 'Swedish Massage · Steam Room · Sauna',
      'duration': '120 min',
      'details': 'Free towel & locker access',
      'price': '1,350',
      'imagePath': 'lib/assets/images/haven.jpg',
      'detail_title': 'Swedish Relaxation Experience',
      'detail_description':
          'A classic combination designed for pure relaxation. Enjoy a gentle Swedish massage followed by detoxifying time in the steam room and sauna.',
      'detail_imagePath': 'lib/assets/images/haven.jpg',
      'detail_totalDuration': '120 Minutes',
      'detail_price': '1350',
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
      'subtitle': 'Deep Tissue Massage · Ice Bath · IV Drip',
      'duration': '150 min',
      'details': 'Includes Normatec boots',
      'price': '3,200',
      'imagePath': 'lib/assets/images/spa.jpg',
      'detail_title': 'Full Body Reset – Recovery Combo',
      'detail_description':
          'Experience the ultimate wellness recovery with a powerful combination of therapeutic treatments designed to relax your body, reduce fatigue, and boost recovery.',
      'detail_imagePath': 'lib/assets/images/spa.jpg',
      'detail_totalDuration': '2 Hours 30 Minutes',
      'detail_price': '3200',
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
      'subtitle': 'Traditional Bath · Relaxation Massage',
      'duration': '120 min',
      'details': 'Complimentary herbal drink',
      'price': '2,100',
      'imagePath': 'lib/assets/images/steam.jpg',
      'detail_title': 'Deep Relaxation Moroccan Experience',
      'detail_description':
          'Enjoy a traditional purifying Moroccan Hammam followed by a soothing full-body relaxation massage to melt away tension.',
      'detail_imagePath': 'lib/assets/images/steam.jpg',
      'detail_totalDuration': '120 Minutes',
      'detail_price': '2100',
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
      itemCount: _combos.length,
      itemBuilder: (context, index) {
        final p = _combos[index];
        return PackageCard(
          badge: 'COMBO',
          title: p['title'] as String,
          subtitle: p['subtitle'] as String,
          durationOrDetail: p['duration'] as String,
          detailLine: p['details'] as String,
          price: p['price'] as String,
          imagePath: p['imagePath'] as String,
          onBookNow: () => Navigator.pushNamed(
            context,
            Routes.packageDetails,
            arguments: {
              'title': p['detail_title'] as String,
              'description': p['detail_description'] as String,
              'imagePath': p['detail_imagePath'] as String,
              'totalDuration': p['detail_totalDuration'] as String,
              'price': p['detail_price'] as String,
              'inclusions': p['detail_inclusions'],
            },
          ),
        );
      },
    );
  }
}
