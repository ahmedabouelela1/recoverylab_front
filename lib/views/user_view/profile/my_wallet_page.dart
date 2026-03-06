import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/models/Offer/user_membership.dart';
import 'package:recoverylab_front/models/Offer/user_package.dart';
import 'package:recoverylab_front/providers/api/api_provider.dart';
import 'package:recoverylab_front/providers/exception/snack_bar.dart';
import 'package:sizer/sizer.dart';

class MyWalletPage extends ConsumerStatefulWidget {
  const MyWalletPage({super.key});

  @override
  ConsumerState<MyWalletPage> createState() => _MyWalletPageState();
}

class _MyWalletPageState extends ConsumerState<MyWalletPage> {
  String _selectedTab = 'Memberships';
  final List<String> _tabs = ['Memberships', 'Packages'];

  List<UserMembership> _memberships = [];
  List<UserPackage> _packages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ref.read(apiProvider).getMyMemberships(),
        ref.read(apiProvider).getMyPackages(),
      ]);
      if (mounted) {
        setState(() {
          _memberships = results[0] as List<UserMembership>;
          _packages = results[1] as List<UserPackage>;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        AppSnackBar.show(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'My Wallet',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: _fetch,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: _buildTabSelector(),
          ),
          SizedBox(height: 2.h),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: KeyedSubtree(
                      key: ValueKey(_selectedTab),
                      child: _selectedTab == 'Memberships'
                          ? _buildMemberships()
                          : _buildPackages(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      height: 6.2.h,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.dividerColor, width: 1),
      ),
      child: Row(
        children: _tabs.map((tab) {
          final isSelected = _selectedTab == tab;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _selectedTab = tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: EdgeInsets.all(0.7.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.14)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: isSelected
                      ? Border.all(
                          color: AppColors.primary.withOpacity(0.35), width: 1)
                      : null,
                ),
                child: Center(
                  child: Text(
                    tab,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Memberships ────────────────────────────────────────────────────────────

  Widget _buildMemberships() {
    if (_memberships.isEmpty) {
      return _emptyState(
        'No Active Memberships',
        'Browse our membership plans to get started.',
      );
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _fetch,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
        itemCount: _memberships.length,
        itemBuilder: (_, i) => _MembershipCard(
          membership: _memberships[i],
          onRefresh: _fetch,
        ),
      ),
    );
  }

  // ── Packages ───────────────────────────────────────────────────────────────

  Widget _buildPackages() {
    if (_packages.isEmpty) {
      return _emptyState(
        'No Active Packages',
        'Browse our packages to purchase session credits.',
      );
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _fetch,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
        itemCount: _packages.length,
        itemBuilder: (_, i) => _PackageCard(package: _packages[i]),
      ),
    );
  }

  Widget _emptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wallet_outlined,
                size: 40.sp, color: AppColors.textTertiary),
            SizedBox(height: 2.h),
            Text(
              title,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Membership card ──────────────────────────────────────────────────────────

class _MembershipCard extends ConsumerStatefulWidget {
  final UserMembership membership;
  final VoidCallback onRefresh;

  const _MembershipCard({required this.membership, required this.onRefresh});

  @override
  ConsumerState<_MembershipCard> createState() => _MembershipCardState();
}

class _MembershipCardState extends ConsumerState<_MembershipCard> {
  bool _isLoading = false;

  Color get _statusColor {
    switch (widget.membership.status) {
      case 'ACTIVE':
        return AppColors.success;
      case 'FROZEN':
        return AppColors.info;
      case 'EXPIRED':
        return AppColors.textTertiary;
      default:
        return AppColors.error;
    }
  }

  Future<void> _freeze() async {
    int? weeks;
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => _FreezeSheet(
        maxWeeks: widget.membership.freezeWeeksRemaining.toInt(),
        onConfirm: (w) {
          weeks = w;
          Navigator.pop(ctx);
        },
      ),
    );
    if (weeks == null || !mounted) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(apiProvider).freezeMembership(widget.membership.id, weeks!);
      if (mounted) widget.onRefresh();
    } catch (e) {
      if (mounted) AppSnackBar.show(context, e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _unfreeze() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(apiProvider).unfreezeMembership(widget.membership.id);
      if (mounted) widget.onRefresh();
    } catch (e) {
      if (mounted) AppSnackBar.show(context, e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.membership;
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Expanded(
                child: Text(
                  m.plan?.name ?? 'Membership',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  m.status,
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          _infoRow(Icons.calendar_today_outlined, 'Valid until', m.endDate),
          if (m.isFrozen && m.freezeEndDate != null)
            _infoRow(Icons.ac_unit, 'Frozen until', m.freezeEndDate!),
          if (!m.isFrozen)
            _infoRow(
              Icons.ac_unit_outlined,
              'Freeze remaining',
              '${m.freezeWeeksRemaining.toStringAsFixed(1)} weeks',
            ),
          // Benefits
          if (m.plan != null && m.plan!.benefits.isNotEmpty) ...[
            SizedBox(height: 1.5.h),
            Container(height: 0.5, color: AppColors.dividerColor),
            SizedBox(height: 1.5.h),
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: m.plan!.benefits.map((b) {
                return Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 2.5.w, vertical: 0.6.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    b.displayLabel,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          // Actions
          if (m.isActive || m.isFrozen) ...[
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : (m.isFrozen ? _unfreeze : _freeze),
                style: ElevatedButton.styleFrom(
                  backgroundColor: m.isFrozen
                      ? AppColors.success
                      : AppColors.primary.withOpacity(0.15),
                  foregroundColor:
                      m.isFrozen ? Colors.white : AppColors.primary,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        m.isFrozen ? 'Unfreeze Membership' : 'Freeze Membership',
                        style: TextStyle(
                            fontSize: 13.sp, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.8.h),
      child: Row(
        children: [
          Icon(icon, size: 13.sp, color: AppColors.textTertiary),
          SizedBox(width: 2.w),
          Text(
            '$label: ',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Freeze bottom sheet ──────────────────────────────────────────────────────

class _FreezeSheet extends StatefulWidget {
  final int maxWeeks;
  final void Function(int weeks) onConfirm;

  const _FreezeSheet({required this.maxWeeks, required this.onConfirm});

  @override
  State<_FreezeSheet> createState() => _FreezeSheetState();
}

class _FreezeSheetState extends State<_FreezeSheet> {
  int _weeks = 1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Text(
            'Freeze Membership',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Select how many weeks to freeze (max ${widget.maxWeeks})',
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: 13.sp),
          ),
          SizedBox(height: 3.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _counterBtn(
                icon: Icons.remove,
                onTap: _weeks > 1 ? () => setState(() => _weeks--) : null,
              ),
              SizedBox(width: 6.w),
              Text(
                '$_weeks week${_weeks == 1 ? '' : 's'}',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 6.w),
              _counterBtn(
                icon: Icons.add,
                onTap: _weeks < widget.maxWeeks
                    ? () => setState(() => _weeks++)
                    : null,
              ),
            ],
          ),
          SizedBox(height: 3.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onConfirm(_weeks),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.secondary,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                'Confirm Freeze',
                style:
                    TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _counterBtn({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 10.w,
        height: 10.w,
        decoration: BoxDecoration(
          color: onTap != null
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 16.sp,
          color: onTap != null ? AppColors.primary : AppColors.textTertiary,
        ),
      ),
    );
  }
}

// ── Package card ─────────────────────────────────────────────────────────────

class _PackageCard extends StatelessWidget {
  final UserPackage package;

  const _PackageCard({required this.package});

  @override
  Widget build(BuildContext context) {
    final pkg = package.package;
    final pct = pkg?.discountPercentage;
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  pkg?.name ?? 'Package',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.success.withOpacity(0.3)),
                ),
                child: Text(
                  package.status,
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          // Credits remaining
          Row(
            children: [
              Icon(Icons.confirmation_number_outlined,
                  size: 14.sp, color: AppColors.primary),
              SizedBox(width: 2.w),
              Text(
                '${package.creditsRemaining} credit${package.creditsRemaining == 1 ? '' : 's'} remaining',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (pct != null) ...[
            SizedBox(height: 0.8.h),
            Row(
              children: [
                Icon(Icons.local_offer_outlined,
                    size: 13.sp, color: AppColors.textTertiary),
                SizedBox(width: 2.w),
                Text(
                  '${pct.toInt()}% off per session',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ],
          if (package.expiryDate != null) ...[
            SizedBox(height: 0.8.h),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 13.sp, color: AppColors.textTertiary),
                SizedBox(width: 2.w),
                Text(
                  'Expires ${package.expiryDate}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
