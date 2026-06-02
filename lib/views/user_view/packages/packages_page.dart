import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/models/Branch/branch/branch.dart';
import 'package:recoverylab_front/providers/session/branch_provider.dart';
import 'package:recoverylab_front/providers/session/user_session_provider.dart';
import 'package:recoverylab_front/components/branch_selector.dart';
import 'tabs/combos_tab.dart';
import 'tabs/membership_tab.dart';
class PackagesPage extends ConsumerStatefulWidget {
  const PackagesPage({super.key});

  @override
  ConsumerState<PackagesPage> createState() => _PackagesPageState();
}

class _PackagesPageState extends ConsumerState<PackagesPage> {
  String selectedTab = 'Combos';
  Branch? _selectedBranch;
  bool _isFetchingBranches = false;

  List<Widget> _tabViews(List<Branch> branches, Branch? selectedBranch) => [
        CombosTab(branchId: selectedBranch?.id),
        MembershipTab(branchId: selectedBranch?.id),
      ];

  final List<String> _tabs = ['Combos', 'Membership'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureBranches();
    });
  }

  Future<void> _ensureBranches() async {
    if (!mounted) return;
    setState(() => _isFetchingBranches = true);
    try {
      await ref.read(branchesProvider.notifier).ensureBranchesFetched();
    } catch (_) {}
    if (mounted) setState(() => _isFetchingBranches = false);
  }

  Color _tabColor(String tab) {
    if (tab == 'Combos') return AppColors.info;
    if (tab == 'Membership') return AppColors.info;
    return AppColors.info;
  }

  @override
  Widget build(BuildContext context) {
    final branches = ref.watch(branchesProvider);
    final user = ref.watch(userSessionProvider).user;
    Branch? selectedBranch = _selectedBranch;
    if (selectedBranch == null && branches.isNotEmpty) {
      if (user?.branchId != null && branches.any((b) => b.id == user!.branchId)) {
        selectedBranch = branches.firstWhere((b) => b.id == user!.branchId);
      } else {
        selectedBranch = branches.first;
      }
    }

    final tabWidgets = _tabViews(branches, selectedBranch);
    final currentTabIndex = _tabs.indexOf(selectedTab).clamp(0, tabWidgets.length - 1);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Offers',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: branches.isEmpty && _isFetchingBranches
                ? SizedBox(
                    height: 6.h,
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                    ),
                  )
                : branches.isEmpty
                    ? SizedBox(
                        height: 6.h,
                        child: GestureDetector(
                          onTap: _ensureBranches,
                          child: Center(
                            child: Text(
                              'Could not load branches. Tap to retry.',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      )
                    : BranchSelector(
                        title: 'BRANCH',
                        branches: branches,
                        selectedBranch: selectedBranch,
                        onSelected: (branch) async {
                          setState(() => _selectedBranch = branch);
                        },
                      ),
          ),
          SizedBox(height: 1.5.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: _buildTabSelector(),
          ),
          SizedBox(height: 2.h),
          Expanded(
            child: IndexedStack(
              index: currentTabIndex,
              children: tabWidgets,
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
        border: Border.all(color: AppColors.info.withOpacity(0.25), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: _tabs.map((tab) {
          final isSelected = selectedTab == tab;
          final tabColor = _tabColor(tab);

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => selectedTab = tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                margin: EdgeInsets.all(0.7.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? tabColor.withOpacity(0.14)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: isSelected
                      ? Border.all(color: tabColor.withOpacity(0.35), width: 1)
                      : null,
                ),
                child: Center(
                  child: Text(
                    tab,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected ? tabColor : AppColors.textSecondary,
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
}
