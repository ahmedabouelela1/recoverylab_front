import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/models/Branch/branch/branch.dart';
import 'package:recoverylab_front/providers/exception/snack_bar.dart';
import 'package:recoverylab_front/providers/session/branch_provider.dart';
import 'package:recoverylab_front/providers/session/user_session_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:url_launcher/url_launcher.dart';

/// Lists all active branches with description, address, and maps deep link.
class BranchesPage extends ConsumerStatefulWidget {
  const BranchesPage({super.key});

  @override
  ConsumerState<BranchesPage> createState() => _BranchesPageState();
}

class _BranchesPageState extends ConsumerState<BranchesPage> {
  bool _fetchTriggered = false;

  /// Picks usable map URLs in order: custom link, then platform-friendly fallbacks.
  List<Uri> _mapUriCandidates(Branch branch) {
    final List<Uri> out = [];

    void add(Uri? u) {
      if (u == null) return;
      if (!u.hasScheme) return;
      if ((u.scheme == 'http' || u.scheme == 'https') && u.host.isEmpty) {
        return;
      }
      if (out.any((e) => e.toString() == u.toString())) return;
      out.add(u);
    }

    final raw = branch.mapsUrl.trim();
    if (raw.isNotEmpty) {
      final url = raw.contains('://') ? raw : 'https://$raw';
      add(Uri.tryParse(url));
    }

    final addr = branch.address.trim();
    if (addr.isNotEmpty) {
      final q = Uri.encodeComponent(addr);
      add(Uri.parse('https://www.google.com/maps/search/?api=1&query=$q'));
      if (!kIsWeb) {
        switch (defaultTargetPlatform) {
          case TargetPlatform.iOS:
            add(Uri.parse('https://maps.apple.com/?q=$q'));
            add(Uri.parse('comgooglemaps://?q=$q'));
            break;
          case TargetPlatform.android:
            add(Uri.parse('geo:0,0?q=$q'));
            add(Uri.parse(
                'https://www.google.com/maps/dir/?api=1&destination=$q'));
            break;
          default:
            break;
        }
      }
    }

    return out;
  }

  Future<void> _openMaps(Branch branch) async {
    final candidates = _mapUriCandidates(branch);
    if (candidates.isEmpty) {
      if (mounted) {
        AppSnackBar.show(context, 'No location available for this branch.');
      }
      return;
    }

    for (final uri in candidates) {
      try {
        var ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!ok) {
          ok = await launchUrl(uri, mode: LaunchMode.platformDefault);
        }
        if (ok) return;
      } catch (_) {
        continue;
      }
    }

    if (mounted) {
      AppSnackBar.show(context, 'Could not open maps.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final branches = ref.watch(branchesProvider);
    final userBranchId = ref.watch(userSessionProvider).user?.branchId;

    if (branches.isEmpty && !_fetchTriggered) {
      _fetchTriggered = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(branchesProvider.notifier).ensureBranchesFetched();
      });
    }

    final activeBranches = branches.where((b) => b.isActive).toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Our Branches',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: activeBranches.isEmpty
          ? Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Text(
                  branches.isEmpty
                      ? 'Loading branches…'
                      : 'No branches available right now.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14.sp,
                    height: 1.4,
                  ),
                ),
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 4.h),
              itemCount: activeBranches.length,
              separatorBuilder: (context, index) => SizedBox(height: 2.h),
              itemBuilder: (context, index) {
                final b = activeBranches[index];
                final isUserBranch = userBranchId != null && b.id == userBranchId;
                return _BranchCard(
                  branch: b,
                  isUserBranch: isUserBranch,
                  onOpenMaps: () => _openMaps(b),
                );
              },
            ),
    );
  }
}

class _BranchCard extends StatelessWidget {
  const _BranchCard({
    required this.branch,
    required this.isUserBranch,
    required this.onOpenMaps,
  });

  final Branch branch;
  final bool isUserBranch;
  final VoidCallback onOpenMaps;

  @override
  Widget build(BuildContext context) {
    final desc = branch.description?.trim();
    final hasMaps = branch.mapsUrl.trim().isNotEmpty ||
        branch.address.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerColor, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (branch.image.trim().isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  branch.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.surfaceLight,
                    alignment: Alignment.center,
                    child: Icon(
                      SolarIconsOutline.gallery,
                      color: AppColors.textTertiary,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        branch.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                    ),
                    if (isUserBranch) ...[
                      SizedBox(width: 2.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.5.w,
                          vertical: 0.4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.info.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          'Your branch',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.info,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (desc != null && desc.isNotEmpty) ...[
                  SizedBox(height: 1.2.h),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
                SizedBox(height: 1.5.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 0.2.h),
                      child: Icon(
                        SolarIconsOutline.mapPoint,
                        size: 16.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        branch.address.trim().isEmpty
                            ? 'Address not listed'
                            : branch.address,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: branch.address.trim().isEmpty
                              ? AppColors.textTertiary
                              : AppColors.textPrimary,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
                if (branch.phone.trim().isNotEmpty) ...[
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Icon(
                        SolarIconsOutline.phone,
                        size: 16.sp,
                        color: AppColors.textTertiary,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          branch.phone,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 2.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: hasMaps ? onOpenMaps : null,
                    icon: Icon(
                      SolarIconsOutline.map,
                      size: 18.sp,
                      color: hasMaps
                          ? AppColors.secondary
                          : AppColors.textTertiary,
                    ),
                    label: Text(
                      'Open in maps',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: hasMaps
                            ? AppColors.secondary
                            : AppColors.textTertiary,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.info,
                      disabledBackgroundColor: AppColors.surfaceLight,
                      foregroundColor: AppColors.secondary,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 1.6.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
