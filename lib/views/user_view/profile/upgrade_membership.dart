import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/components/app_button.dart';

class UpgradeMembershipPage extends StatefulWidget {
  const UpgradeMembershipPage({super.key});

  @override
  State<UpgradeMembershipPage> createState() => _UpgradeMembershipPageState();
}

class _UpgradeMembershipPageState extends State<UpgradeMembershipPage> {
  String _selected = 'Gold';

  static const _plans = [
    {
      'name': 'Silver',
      'duration': '3 Months',
      'price': '2,450',
      'color': 'silver',
      'freeze': '2-Week Freeze',
      'discount': '10% Off All Services',
      'perks': [
        'Full Spa Access',
        '2-Week Freeze Period',
        '10% Off All Services',
      ],
    },
    {
      'name': 'Gold',
      'duration': '6 Months',
      'price': '4,900',
      'color': 'gold',
      'freeze': '6-Week Freeze',
      'discount': '15% Off All Services',
      'perks': [
        'Full Spa Access',
        '6-Week Freeze Period',
        '15% Off All Services',
        'Priority Booking',
      ],
    },
    {
      'name': 'Platinum',
      'duration': '12 Months',
      'price': '8,600',
      'color': 'platinum',
      'freeze': '12-Week Freeze',
      'discount': '25% Off All Services',
      'perks': [
        'Full Spa Access',
        '12-Week Freeze Period',
        '25% Off All Services',
        'Priority Booking',
        'Dedicated Locker',
      ],
    },
  ];

  Color _planColor(String c) {
    if (c == 'silver') return const Color(0xFFADB5BD);
    if (c == 'gold') return const Color(0xFFFFC107);
    return const Color(0xFFB5C9D8); // platinum
  }

  @override
  Widget build(BuildContext context) {
    final selected = _plans.firstWhere((p) => p['name'] == _selected);
    final accent = _planColor(selected['color'] as String);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
              size: 16,
            ),
          ),
        ),
        title: Text(
          'Upgrade Membership',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17.sp,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            children: [
              // Current plan banner
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFFFC107).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      SolarIconsOutline.crown,
                      color: const Color(0xFFFFC107),
                      size: 16.sp,
                    ),
                    SizedBox(width: 3.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Plan',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 11.sp,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          'Gold Membership',
                          style: TextStyle(
                            color: const Color(0xFFFFC107),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 3.h),

              _sectionLabel('CHOOSE YOUR PLAN'),
              SizedBox(height: 1.5.h),

              // Plan cards
              ..._plans.map((plan) {
                final isSelected = _selected == plan['name'];
                final color = _planColor(plan['color'] as String);
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selected = plan['name'] as String),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(bottom: 2.h),
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withOpacity(0.08)
                          : AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? color.withOpacity(0.5)
                            : AppColors.dividerColor,
                        width: isSelected ? 1.5 : 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Radio
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? color
                                  : AppColors.textTertiary,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Center(
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    SolarIconsOutline.crown,
                                    color: color,
                                    size: 14.sp,
                                  ),
                                  SizedBox(width: 1.5.w),
                                  Text(
                                    plan['name'] as String,
                                    style: TextStyle(
                                      color: color,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 0.3.h),
                              Text(
                                plan['duration'] as String,
                                style: TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 11.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'EGP ${plan['price']}',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              plan['freeze'] as String,
                              style: TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 10.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              SizedBox(height: 1.h),

              // Selected plan perks
              _sectionLabel('WHAT YOU GET'),
              SizedBox(height: 1.2.h),
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.dividerColor, width: 0.8),
                ),
                child: Column(
                  children: (selected['perks'] as List<String>)
                      .map(
                        (perk) => Padding(
                          padding: EdgeInsets.only(bottom: 1.5.h),
                          child: Row(
                            children: [
                              Icon(
                                SolarIconsOutline.checkCircle,
                                color: accent,
                                size: 14.sp,
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                perk,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              SizedBox(height: 14.h),
            ],
          ),

          // Bottom bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                border: Border(
                  top: BorderSide(color: AppColors.dividerColor, width: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'TOTAL',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        'EGP ${selected['price']}',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: AppButton(
                      label: 'Upgrade to $_selected',
                      width: double.infinity,
                      borderRadius: 16,
                      size: AppButtonSize.large,
                      onPressed: () {}, // TODO
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: TextStyle(
      color: AppColors.textSecondary,
      fontSize: 12.sp,
      fontWeight: FontWeight.bold,
      letterSpacing: 2,
    ),
  );
}
