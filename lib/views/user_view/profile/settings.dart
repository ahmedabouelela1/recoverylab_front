// pages/settings/settings_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:sizer/sizer.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/components/app_button.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // Helper function for navigation using named routes
  void _navigateToNamed(BuildContext context, String routeName) {
    Navigator.of(context).pushNamed(routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        // This line removes the back arrow or leading icon
        automaticallyImplyLeading: false,

        title: Text(
          "Settings",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: AppColors.textPrimary, // White
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        children: [
          // 1. Profile Card (User Info & Membership)
          _buildProfileCard(context),
          SizedBox(height: 3.h),

          // 2. Account Section
          _buildSectionTitle("Account"),
          _buildAccountSection(context),
          SizedBox(height: 3.h),

          // 3. Support & About Section
          _buildSectionTitle("Support & About"),
          _buildSupportSection(context),
          SizedBox(height: 10.h),

          // 4. Log out Button
          AppButton(
            label: "Log out",
            onPressed: () {
              // TODO: Implement Log out logic (e.g., clear session, navigate to login)
              print("User logged out");
            },
            icon: Icons.logout,
            size: AppButtonSize.large,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h, left: 1.w),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    const String profileImagePath = 'lib/assets/images/profile.png';

    return Container(
      // Only apply padding for the user info section here
      padding: EdgeInsets.only(top: 4.w, left: 4.w, right: 4.w, bottom: 2.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Row
          Padding(
            padding: EdgeInsets.only(bottom: 2.w), // Add some space below info
            child: Row(
              children: [
                // Profile Picture with Gold Membership indicator
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 6.w,
                      backgroundImage: const AssetImage(profileImagePath),
                      backgroundColor: AppColors.textSecondary.withOpacity(0.1),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: const BoxDecoration(
                          color: Colors.yellow, // Gold color for badge
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 1.5.w,
                          minHeight: 1.5.w,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 4.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Michael Smith",
                      style: GoogleFonts.inter(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      "michael.smith@example.com",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // DEDICATED GRAY CONTAINER FOR GOLD MEMBERSHIP (NOW NAVIGATING)
          InkWell(
            onTap: () {
              // Navigate to a page showing Membership details (or UpgradeMembership if needed)
              _navigateToNamed(context, Routes.upgradeMembership);
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              // The gray container that is visually distinct
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              margin: EdgeInsets.only(
                bottom: 2.w,
              ), // Ensures the card padding is visible below it
              decoration: BoxDecoration(
                // Using a light tint of the background for a gray/slightly lighter card look
                color: AppColors.textPrimary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.workspace_premium_outlined,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        "Gold Membership",
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.security_outlined,
            title: "Edit Health Survey",
            onTap: () => _navigateToNamed(context, Routes.editHealthSurvey),
          ),
          _buildSettingItem(
            icon: Icons.lock_outlined,
            title: "Change Password",
            onTap: () => _navigateToNamed(context, Routes.resetPassword),
          ),
          _buildSettingItem(
            icon: Icons.upgrade_outlined,
            title: "Upgrade Membership",
            onTap: () => _navigateToNamed(context, Routes.upgradeMembership),
          ),
          _buildSettingItem(
            icon: Icons.local_activity_outlined,
            title: "Coupons",
            onTap: () => _navigateToNamed(context, Routes.coupons),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.help_outline,
            title: "Help & Support",
            onTap: () => _navigateToNamed(context, Routes.helpAndSupport),
          ),
          _buildSettingItem(
            icon: Icons.info_outline,
            title: "Terms and Policies",
            onTap: () => _navigateToNamed(context, Routes.termsAndPolicies),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLast = false,
    bool showTrailingIcon = false,
  }) {
    // Note: The original code didn't set showTrailingIcon to true anywhere.
    // I've kept it false for consistency with the provided functions,
    // but the Row structure is still here. You might want to remove 'showTrailingIcon'
    // from the parameters and always show the trailing icon if you want it on every item.
    // Since it's a settings list, I'll add the arrow by default on all items for UX,
    // and remove the `showTrailingIcon` parameter, setting it to true internally.

    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.textSecondary),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                // Show the trailing icon for all navigation items
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
              ],
            ),
          ),
          if (!isLast)
            Divider(
              color: AppColors.textSecondary.withOpacity(0.1),
              height: 1,
              thickness: 1,
              indent: 8.w,
              endIndent: 4.w,
            ),
        ],
      ),
    );
  }
}
