import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:recoverylab_front/configurations/colors.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  int? _expandedFaq;

  static const _faqs = [
    {
      'q': 'How do I cancel or reschedule a booking?',
      'a':
          'You can cancel or reschedule any upcoming booking from the Bookings tab. Cancellations made at least 24 hours before the session receive a full refund.',
    },
    {
      'q': 'What payment methods are accepted?',
      'a':
          'We accept credit/debit cards, cash on arrival, mobile wallets, and bank transfers.',
    },
    {
      'q': 'How do memberships work?',
      'a':
          'Memberships give you full spa access for a fixed duration (3, 6, or 12 months) along with a service discount. You can freeze your membership once per period.',
    },
    {
      'q': 'Can I choose my therapist?',
      'a':
          'Yes. When booking a service, you can optionally select a preferred therapist from the available staff list.',
    },
    {
      'q': 'Is my health survey data private?',
      'a':
          'Your health information is only shared with the therapists assigned to your sessions and is never disclosed to third parties.',
    },
  ];

  static const _contacts = [
    {'icon': 'phone', 'label': 'Call Us', 'value': '+20 100 000 0000'},
    {
      'icon': 'email',
      'label': 'Email Support',
      'value': 'support@recoverylab.com',
    },
    {'icon': 'chat', 'label': 'Live Chat', 'value': 'Available 9 AM – 10 PM'},
    {
      'icon': 'map',
      'label': 'Visit Us',
      'value': 'Cairo Festival City, New Cairo',
    },
  ];

  @override
  Widget build(BuildContext context) {
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
          'Help & Support',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17.sp,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        children: [
          // Contact cards
          _sectionLabel('CONTACT US'),
          SizedBox(height: 1.2.h),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 3.w,
            mainAxisSpacing: 2.h,
            childAspectRatio: 2.2,
            children: _contacts.map((c) => _contactCard(c)).toList(),
          ),
          SizedBox(height: 3.h),

          // FAQs
          _sectionLabel('FREQUENTLY ASKED QUESTIONS'),
          SizedBox(height: 1.2.h),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.dividerColor, width: 0.8),
            ),
            child: Column(
              children: _faqs.asMap().entries.map((entry) {
                final i = entry.key;
                final faq = entry.value;
                final isExpanded = _expandedFaq == i;
                final isLast = i == _faqs.length - 1;
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () =>
                          setState(() => _expandedFaq = isExpanded ? null : i),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.8.h,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                faq['q']!,
                                style: TextStyle(
                                  color: isExpanded
                                      ? AppColors.info
                                      : AppColors.textPrimary,
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(width: 2.w),
                            AnimatedRotation(
                              turns: isExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                Icons.keyboard_arrow_down,
                                color: isExpanded
                                    ? AppColors.info
                                    : AppColors.textTertiary,
                                size: 18.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      child: isExpanded
                          ? Padding(
                              padding: EdgeInsets.only(
                                left: 4.w,
                                right: 4.w,
                                bottom: 2.h,
                              ),
                              child: Text(
                                faq['a']!,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13.sp,
                                  height: 1.6,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    if (!isLast)
                      Divider(
                        color: AppColors.dividerColor,
                        height: 1,
                        thickness: 0.5,
                        indent: 4.w,
                        endIndent: 4.w,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _contactCard(Map<String, String> c) {
    IconData icon;
    Color color;
    switch (c['icon']) {
      case 'phone':
        icon = SolarIconsOutline.phone;
        color = AppColors.success;
        break;
      case 'email':
        icon = SolarIconsOutline.letter;
        color = AppColors.info;
        break;
      case 'chat':
        icon = SolarIconsOutline.chatRound;
        color = AppColors.primary;
        break;
      default:
        icon = SolarIconsOutline.mapPoint;
        color = AppColors.error;
        break;
    }
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dividerColor, width: 0.8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 14.sp),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  c['label']!,
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  c['value']!,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
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
