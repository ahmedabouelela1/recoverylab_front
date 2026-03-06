import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:sizer/sizer.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/components/app_button.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  File? _profileImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 10.w,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'CHANGE PHOTO',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 2.h),
                _photoOption(
                  icon: SolarIconsOutline.camera,
                  label: 'Take a photo',
                  onTap: () async {
                    Navigator.pop(context);
                    final picked = await picker.pickImage(
                      source: ImageSource.camera,
                    );
                    if (picked != null)
                      setState(() => _profileImage = File(picked.path));
                  },
                ),
                SizedBox(height: 1.5.h),
                _photoOption(
                  icon: SolarIconsOutline.gallery,
                  label: 'Choose from gallery',
                  onTap: () async {
                    Navigator.pop(context);
                    final picked = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (picked != null)
                      setState(() => _profileImage = File(picked.path));
                  },
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _photoOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.dividerColor, width: 0.8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.info, size: 16.sp),
            ),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        children: [
          _buildProfileCard(context),
          SizedBox(height: 3.h),
          _sectionLabel('ACCOUNT'),
          SizedBox(height: 1.2.h),
          _buildSection([
            _SettingItem(
              icon: SolarIconsOutline.health,
              label: 'Edit Health Survey',
              route: Routes.editHealthSurvey,
            ),
            _SettingItem(
              icon: SolarIconsOutline.lockPassword,
              label: 'Change Password',
              route: Routes.resetPassword,
            ),
            _SettingItem(
              icon: SolarIconsOutline.crown,
              label: 'Upgrade Membership',
              route: Routes.upgradeMembership,
            ),
            _SettingItem(
              icon: SolarIconsOutline.ticket,
              label: 'Coupons',
              route: Routes.coupons,
            ),
          ], context),
          SizedBox(height: 3.h),
          _sectionLabel('SUPPORT & ABOUT'),
          SizedBox(height: 1.2.h),
          _buildSection([
            _SettingItem(
              icon: SolarIconsOutline.accumulator,
              label: 'Help & Support',
              route: Routes.helpAndSupport,
            ),
            _SettingItem(
              icon: SolarIconsOutline.fileText,
              label: 'Terms and Policies',
              route: Routes.termsAndPolicies,
            ),
          ], context),
          SizedBox(height: 4.h),
          AppButton(
            label: 'Log Out',
            onPressed: () {},
            icon: Icons.logout,
            size: AppButtonSize.large,
            color: AppColors.error,
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12.sp,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    const defaultProfilePath = 'lib/assets/images/profile.png';
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerColor, width: 0.8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 7.w,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!) as ImageProvider
                          : const AssetImage(defaultProfilePath),
                      backgroundColor: AppColors.surfaceLight,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.cardBackground,
                          width: 2,
                        ),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.edit,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Michael Smith',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 0.3.h),
                    Text(
                      'michael.smith@example.com',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(height: 0.5, color: AppColors.dividerColor),
          SizedBox(height: 2.h),
          // Membership row
          GestureDetector(
            onTap: () =>
                Navigator.of(context).pushNamed(Routes.upgradeMembership),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.6.h),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.success.withOpacity(0.25),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      SolarIconsOutline.crown,
                      color: AppColors.success,
                      size: 14.sp,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gold Membership',
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Tap to upgrade',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColors.success.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(List<_SettingItem> items, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerColor, width: 0.8),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final isLast = i == items.length - 1;
          return _buildSettingRow(item, context, isLast: isLast);
        }).toList(),
      ),
    );
  }

  Widget _buildSettingRow(
    _SettingItem item,
    BuildContext context, {
    bool isLast = false,
  }) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(item.route),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.icon,
                    size: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
          if (!isLast)
            Divider(
              color: AppColors.dividerColor,
              height: 1,
              thickness: 0.5,
              indent: 14.w,
              endIndent: 4.w,
            ),
        ],
      ),
    );
  }
}

class _SettingItem {
  final IconData icon;
  final String label;
  final String route;
  const _SettingItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}
