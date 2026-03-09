import 'package:flutter/material.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/models/Branch/branch/branch.dart';
import 'package:sizer/sizer.dart';
import 'package:solar_icons/solar_icons.dart';

class BranchSelector extends StatelessWidget {
  const BranchSelector({
    super.key,
    required this.branches,
    required this.selectedBranch,
    required this.onSelected,
    this.title,
    this.loadingLabel = 'Loading branches...',
  });

  final List<Branch> branches;
  final Branch? selectedBranch;
  final Future<void> Function(Branch branch) onSelected;
  final String? title;
  final String loadingLabel;

  static Widget _buildBranchLeading({
    required Branch? branch,
    required double size,
    required double iconSize,
    required Color iconColor,
    Color? backgroundColor,
    BorderRadius? borderRadius,
  }) {
    final imageUrl = branch?.image.trim() ?? '';
    final radius = borderRadius ?? BorderRadius.circular(size / 2);

    if (imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: radius,
        child: Image.network(
          imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildBranchFallback(
              size: size,
              iconSize: iconSize,
              iconColor: iconColor,
              backgroundColor: backgroundColor,
              borderRadius: radius,
            );
          },
        ),
      );
    }

    return _buildBranchFallback(
      size: size,
      iconSize: iconSize,
      iconColor: iconColor,
      backgroundColor: backgroundColor,
      borderRadius: radius,
    );
  }

  static Widget _buildBranchFallback({
    required double size,
    required double iconSize,
    required Color iconColor,
    Color? backgroundColor,
    required BorderRadius borderRadius,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: Icon(
        SolarIconsBold.pointOnMap,
        color: iconColor,
        size: iconSize,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeBranch = branches.isEmpty
        ? null
        : selectedBranch ?? branches.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 1.h),
        ],
        GestureDetector(
          onTap: activeBranch == null
              ? null
              : () => BranchSelector.showSelectionModal(
                  context: context,
                  branches: branches,
                  selectedBranch: activeBranch,
                  onSelected: onSelected,
                ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.info),
            ),
            child: Row(
              children: [
                _buildBranchLeading(
                  branch: activeBranch,
                  size: 11.w,
                  iconSize: 20.sp,
                  iconColor: AppColors.strokeBorder,
                  borderRadius: BorderRadius.circular(12),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: activeBranch == null
                      ? Text(
                          loadingLabel,
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 13.sp,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activeBranch.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              activeBranch.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                ),
                Icon(
                  Icons.expand_more,
                  color: AppColors.strokeBorder,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static void showSelectionModal({
    required BuildContext context,
    required List<Branch> branches,
    required Branch selectedBranch,
    required Future<void> Function(Branch branch) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(modalContext).size.height * 0.7,
            ),
            padding: EdgeInsets.all(4.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 12.w,
                    height: 0.5.h,
                    decoration: BoxDecoration(
                      color: AppColors.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Select Branch',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.h),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: branches.length,
                    itemBuilder: (context, index) {
                      final branch = branches[index];
                      final isSelected = branch.id == selectedBranch.id;

                      return GestureDetector(
                        onTap: () async {
                          Navigator.pop(modalContext);
                          if (!isSelected) {
                            await onSelected(branch);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AppColors.dividerColor,
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              _buildBranchLeading(
                                branch: branch,
                                size: 10.w,
                                iconSize: 18.sp,
                                iconColor: isSelected
                                    ? AppColors.info
                                    : AppColors.textSecondary,
                                backgroundColor: isSelected
                                    ? AppColors.info.withValues(alpha: 0.12)
                                    : AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      branch.name,
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 14.sp,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    SizedBox(height: 0.5.h),
                                    Text(
                                      branch.address,
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check,
                                  color: AppColors.info,
                                  size: 20.sp,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        );
      },
    );
  }
}
