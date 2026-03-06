import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:recoverylab_front/configurations/colors.dart';

class TermsPoliciesPage extends StatelessWidget {
  const TermsPoliciesPage({super.key});

  static const _sections = [
    {
      'icon': 'terms',
      'title': 'Terms of Service',
      'body':
          'By using the Recovery Lab app and its services, you agree to abide by these terms. Recovery Lab reserves the right to modify services, pricing, and policies at any time with reasonable notice. Bookings are subject to availability and confirmed only upon payment.',
    },
    {
      'icon': 'cancel',
      'title': 'Cancellation Policy',
      'body':
          'Cancellations made at least 24 hours before a session are eligible for a full refund. Cancellations within 24 hours may incur a 50% fee. No-shows are charged in full. Exceptions may be granted for documented emergencies.',
    },
    {
      'icon': 'privacy',
      'title': 'Privacy Policy',
      'body':
          'We collect only the data necessary to provide our services, including your name, contact details, and health information. Your data is stored securely and is never sold to third parties. Health survey data is only accessible to assigned therapists.',
    },
    {
      'icon': 'refund',
      'title': 'Refund Policy',
      'body':
          'Eligible refunds are processed within 5–10 business days to the original payment method. Package and membership purchases are non-refundable after the first session has been used. Partial refunds may apply in exceptional circumstances.',
    },
    {
      'icon': 'health',
      'title': 'Health & Safety',
      'body':
          'Clients are responsible for disclosing any medical conditions that may affect treatment. Recovery Lab therapists are not medical professionals. Services are not a substitute for medical advice or treatment. Clients use services at their own discretion.',
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
          'Terms & Policies',
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
          // Last updated
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.dividerColor, width: 0.8),
            ),
            child: Row(
              children: [
                Icon(
                  SolarIconsOutline.calendarDate,
                  color: AppColors.textTertiary,
                  size: 14.sp,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Last updated: January 2025',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),

          ..._sections.map((s) => _buildSection(s)),

          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildSection(Map<String, String> section) {
    IconData icon;
    Color color;
    switch (section['icon']) {
      case 'terms':
        icon = SolarIconsOutline.fileText;
        color = AppColors.info;
        break;
      case 'cancel':
        icon = SolarIconsOutline.closeCircle;
        color = AppColors.error;
        break;
      case 'privacy':
        icon = SolarIconsOutline.shield;
        color = AppColors.primary;
        break;
      case 'refund':
        icon = SolarIconsOutline.wallet;
        color = AppColors.success;
        break;
      default:
        icon = SolarIconsOutline.health;
        color = AppColors.warning;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerColor, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 15.sp),
              ),
              SizedBox(width: 3.w),
              Text(
                section['title']!,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Container(height: 0.5, color: AppColors.dividerColor),
          SizedBox(height: 1.5.h),
          Text(
            section['body']!,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.sp,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
