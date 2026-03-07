import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:recoverylab_front/providers/session/branch_provider.dart';
import 'package:recoverylab_front/providers/session/user_session_provider.dart';
import 'package:recoverylab_front/providers/session/active_membership_provider.dart';
import 'package:recoverylab_front/models/Branch/branch/branch.dart';
import 'package:sizer/sizer.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/components/app_button.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  Branch? _selectedBranch;

  // ── Edit profile modal ────────────────────────────────────────────────────

  void _showEditProfile() {
    final user = ref.read(userSessionProvider).user;
    final firstCtrl = TextEditingController(text: user?.firstName ?? '');
    final lastCtrl = TextEditingController(text: user?.lastName ?? '');
    final phoneCtrl = TextEditingController(text: user?.phone ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 5.w,
            right: 5.w,
            top: 2.h,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 4.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
              SizedBox(height: 2.5.h),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      SolarIconsOutline.pen,
                      color: AppColors.primary,
                      size: 15.sp,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Edit Profile',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.5.h),
              _sectionLabel('FIRST NAME'),
              SizedBox(height: 1.h),
              _inputField(controller: firstCtrl, hint: 'First name'),
              SizedBox(height: 2.h),
              _sectionLabel('LAST NAME'),
              SizedBox(height: 1.h),
              _inputField(controller: lastCtrl, hint: 'Last name'),
              SizedBox(height: 2.h),
              _sectionLabel('PHONE NUMBER'),
              SizedBox(height: 1.h),
              _inputField(
                controller: phoneCtrl,
                hint: '+20 100 000 0000',
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 3.h),
              AppButton(
                label: 'Save Changes',
                onPressed: () {
                  // TODO: dispatch update
                  Navigator.pop(ctx);
                },
                size: AppButtonSize.large,
                width: double.infinity,
                borderRadius: 16,
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userSessionProvider).user;
    final branches = ref.watch(branchesProvider);
    final membershipAsync = ref.watch(activeMembershipProvider);

    // Init selected branch once
    if (_selectedBranch == null && branches.isNotEmpty) {
      _selectedBranch = branches.firstWhere(
        (b) => b?.id == user?.branchId,
        orElse: () => branches.first,
      );
    }

    final initials = [
      user?.firstName?.isNotEmpty == true ? user!.firstName[0] : '',
      user?.lastName?.isNotEmpty == true ? user!.lastName[0] : '',
    ].join().toUpperCase();

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
          _buildProfileCard(user, initials, membershipAsync),
          SizedBox(height: 3.h),

          // ── Branch selector ────────────────────────────────────────────
          _sectionLabel('YOUR BRANCH'),
          SizedBox(height: 1.2.h),
          _buildBranchSelector(branches),
          SizedBox(height: 3.h),

          // ── Account ────────────────────────────────────────────────────
          _sectionLabel('ACCOUNT'),
          SizedBox(height: 1.2.h),
          _buildSection([
            _SettingItem(
              icon: SolarIconsOutline.wallet,
              label: 'My Packages & Memberships',
              route: Routes.myWallet,
            ),
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

          // ── Support ────────────────────────────────────────────────────
          _sectionLabel('SUPPORT & ABOUT'),
          SizedBox(height: 1.2.h),
          _buildSection([
            _SettingItem(
              icon: SolarIconsOutline.questionCircle,
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
            onPressed: () async {
              await ref.read(userSessionProvider.notifier).logout();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.loginPage,
                (route) => false,
              );
            },
            icon: Icons.logout,
            size: AppButtonSize.large,
            color: AppColors.error,
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  // ── Profile card — no photo, initials avatar + edit button ───────────────

  Widget _buildProfileCard(dynamic user, String initials, AsyncValue membershipAsync) {
    final membership = membershipAsync.value;
    final planName = membership?.plan?.name;
    final isMember = planName != null && planName.isNotEmpty;

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
              // Initials avatar
              Container(
                width: 14.w,
                height: 14.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.8),
                      AppColors.primary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials.isNotEmpty ? initials : '?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim(),
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 0.3.h),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.8.h),
                    // Membership badge: plan name or "Not a member"
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.5.w,
                        vertical: 0.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: isMember
                            ? AppColors.info.withOpacity(0.1)
                            : AppColors.textTertiary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isMember
                              ? AppColors.info.withOpacity(0.3)
                              : AppColors.textTertiary.withOpacity(0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            SolarIconsOutline.crown,
                            color: isMember ? AppColors.info : AppColors.textTertiary,
                            size: 11.sp,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            membershipAsync.isLoading
                                ? '...'
                                : (isMember ? planName! : 'Not a member'),
                            style: TextStyle(
                              color: isMember ? AppColors.info : AppColors.textSecondary,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Edit button
              GestureDetector(
                onTap: _showEditProfile,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.dividerColor,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        SolarIconsOutline.pen,
                        color: AppColors.textSecondary,
                        size: 12.sp,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Edit',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(height: 0.5, color: AppColors.dividerColor),
          SizedBox(height: 2.h),
          // Membership upgrade row
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

  // ── Branch selector — ported from HomePage ────────────────────────────────

  Widget _buildBranchSelector(List<Branch?> branches) {
    if (branches.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.dividerColor, width: 0.8),
        ),
        child: Row(
          children: [
            Icon(
              SolarIconsOutline.mapPoint,
              color: AppColors.textTertiary,
              size: 16.sp,
            ),
            SizedBox(width: 3.w),
            Text(
              'Loading branches...',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 13.sp),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.info, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Branch>(
          value: _selectedBranch,
          isExpanded: true,
          dropdownColor: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          icon: Icon(
            SolarIconsOutline.altArrowDown,
            color: AppColors.strokeBorder,
            size: 20.sp,
          ),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          onChanged: (Branch? val) {
            if (val != null) setState(() => _selectedBranch = val);
          },
          items: branches.whereType<Branch>().map((branch) {
            return DropdownMenuItem<Branch>(
              value: branch,
              child: Row(
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      SolarIconsOutline.mapPoint,
                      size: 14.sp,
                      color: AppColors.info,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          branch.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          branch.address,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Section helpers ───────────────────────────────────────────────────────

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

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerColor, width: 0.8),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 13.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 4.w,
            vertical: 1.8.h,
          ),
        ),
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
