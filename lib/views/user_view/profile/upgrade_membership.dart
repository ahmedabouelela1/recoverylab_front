import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/components/app_button.dart';
import 'package:recoverylab_front/components/app_snackbar.dart';
import 'package:recoverylab_front/providers/api/api_provider.dart';
import 'package:recoverylab_front/providers/session/active_membership_provider.dart';
import 'package:recoverylab_front/providers/session/user_session_provider.dart';
import 'package:recoverylab_front/providers/exception/exception_handling.dart';
import 'package:recoverylab_front/models/Offer/membership_plan.dart';

final membershipPlansProvider = FutureProvider<List<MembershipPlan>>((ref) async {
  return ref.read(apiProvider).getMembershipPlans();
});

class UpgradeMembershipPage extends ConsumerStatefulWidget {
  const UpgradeMembershipPage({super.key});

  @override
  ConsumerState<UpgradeMembershipPage> createState() => _UpgradeMembershipPageState();
}

class _UpgradeMembershipPageState extends ConsumerState<UpgradeMembershipPage> {
  /// Selected plan id; null until plans load, then first plan or current membership's plan.
  int? _selectedPlanId;

  Color _planColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('silver')) return const Color(0xFFADB5BD);
    if (lower.contains('gold')) return AppColors.info;
    if (lower.contains('platinum')) return const Color(0xFFB5C9D8);
    return AppColors.primary;
  }

  /// Perks list for display: from benefits' displayLabel, plus freeze if present.
  List<String> _perksForPlan(MembershipPlan plan) {
    final list = <String>[];
    if (plan.freezeWeeks != null && plan.freezeWeeks! > 0) {
      list.add('${plan.freezeWeeks!.toInt()}-Week Freeze Period');
    }
    if (plan.hasUnlimitedAccess) list.add('Full Spa Access');
    for (final b in plan.benefits) {
      final label = b.displayLabel;
      if (label.isNotEmpty && !list.contains(label)) list.add(label);
    }
    if (list.isEmpty) list.add('Full access');
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(membershipPlansProvider);
    final activeMembership = ref.watch(activeMembershipProvider).value;

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
          'All Memberships',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17.sp,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: plansAsync.when(
        data: (plans) {
          if (plans.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(5.w),
                child: Text(
                  'No membership plans available.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            );
          }
          // Init selection once: current plan if member, else first plan.
          if (_selectedPlanId == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              final id = activeMembership?.plan?.id ?? plans.first.id;
              setState(() => _selectedPlanId = id);
            });
          }
          final selectedPlan = plans.firstWhere(
                (p) => p.id == _selectedPlanId,
                orElse: () => plans.first,
              );
          return _buildBody(plans, selectedPlan);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: EdgeInsets.all(5.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Failed to load plans',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                TextButton(
                  onPressed: () => ref.refresh(membershipPlansProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(List<MembershipPlan> plans, MembershipPlan selectedPlan) {
    final accent = _planColor(selectedPlan.name);
    final activeMembership = ref.read(activeMembershipProvider).value;
    final isCurrentPlan = activeMembership?.plan?.id == selectedPlan.id;
    final isMember = activeMembership?.plan?.name != null &&
        activeMembership!.plan!.name.isNotEmpty;

    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          children: [
            // Current plan banner (from API)
            Consumer(
              builder: (context, ref, _) {
                final async = ref.watch(activeMembershipProvider);
                final membership = async.value;
                final planName = membership?.plan?.name;
                final isMember = planName != null && planName.isNotEmpty;
                return Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: isMember
                        ? AppColors.info.withOpacity(0.1)
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isMember
                          ? AppColors.info.withOpacity(0.3)
                          : AppColors.dividerColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        SolarIconsOutline.crown,
                        color: isMember
                            ? AppColors.info
                            : AppColors.textTertiary,
                        size: 16.sp,
                      ),
                      SizedBox(width: 3.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current plan',
                            style: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 11.sp,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            async.isLoading
                                ? '...'
                                : (isMember ? planName : 'Not a member'),
                            style: TextStyle(
                              color: isMember
                                  ? AppColors.info
                                  : AppColors.textSecondary,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 3.h),
            _sectionLabel('ALL PLANS'),
            SizedBox(height: 1.5.h),
            ...plans.map((plan) {
              final isSelected = _selectedPlanId == plan.id;
              final color = _planColor(plan.name);
              final freezeStr = plan.freezeWeeks != null && plan.freezeWeeks! > 0
                  ? '${plan.freezeWeeks!.toInt()}-Week Freeze'
                  : 'No freeze';
              return GestureDetector(
                onTap: isMember
                    ? null
                    : () => setState(() => _selectedPlanId = plan.id),
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
                                Flexible(
                                  child: Text(
                                    plan.name,
                                    style: TextStyle(
                                      color: color,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 0.3.h),
                            Text(
                              '${plan.durationMonths} Month${plan.durationMonths > 1 ? 's' : ''}',
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
                            'EGP ${plan.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            freezeStr,
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
            _sectionLabel('WHAT YOU GET'),
            SizedBox(height: 1.2.h),
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.dividerColor,
                  width: 0.8,
                ),
              ),
              child: Column(
                children: _perksForPlan(selectedPlan)
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
                            Expanded(
                              child: Text(
                                perk,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                ),
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
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              border: Border(
                top: BorderSide(
                  color: AppColors.dividerColor,
                  width: 0.5,
                ),
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
                      'EGP ${selectedPlan.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: AppButton(
                    label: isCurrentPlan ? 'Already a member' : 'Subscribe',
                    width: double.infinity,
                    borderRadius: 16,
                    size: AppButtonSize.large,
                    onPressed: isCurrentPlan
                        ? null
                        : () => _purchaseMembership(selectedPlan),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _purchaseMembership(MembershipPlan plan) async {
    final user = ref.read(userSessionProvider).user;
    if (user == null) {
      AppSnackbar.show(context, 'Please sign in to continue');
      return;
    }
    final now = DateTime.now();
    final startDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    try {
      await ref.read(apiProvider).purchaseMembership(
            userId: user.id,
            membershipPlanId: plan.id,
            startDate: startDate,
          );
      ref.invalidate(activeMembershipProvider);
      if (!mounted) return;
      AppSnackbar.show(context, 'Membership activated successfully');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      final message = e is ApiException
          ? e.message
          : 'Failed to activate membership';
      AppSnackbar.show(context, message);
    }
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
