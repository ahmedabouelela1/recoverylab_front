import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:recoverylab_front/configurations/colors.dart';
// 🔑 IMPORT THE MODEL FROM ITS NEW LOCATION
import 'package:recoverylab_front/models/staff_member_model.dart';

class StaffDetailsScreen extends StatelessWidget {
  final StaffMember staff;

  const StaffDetailsScreen({super.key, required this.staff});

  @override
  Widget build(BuildContext context) {
    // Calculating required space for the bottom button, keeping your original logic
    final double safeAreaBottom = MediaQuery.of(context).padding.bottom;
    // 6.h (button height) + 3.h (bottom padding) + 2.h (vertical padding in SingleChildScrollView) + safeAreaBottom
    final double buttonClearanceHeight = 6.h + 3.h + 2.h + safeAreaBottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Staff Member",
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            // Vertical padding maintained
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(context),
                SizedBox(height: 3.h),
                _buildAboutSection(),
                SizedBox(height: 3.h),
                _buildRatingsSummary(),
                SizedBox(height: 3.h),
                // 🔑 CALL TO THE NEW REVIEW LIST WIDGET
                _buildReviewList(),

                // Spacing to prevent content from hiding behind the fixed button
                SizedBox(height: buttonClearanceHeight),
              ],
            ),
          ),
          // Confirmation Button (Fixed at bottom) - UNCHANGED
          Positioned(
            bottom: 3.h + safeAreaBottom,
            left: 4.w,
            right: 4.w,
            child: SizedBox(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context, staff);
                },
                child: Text(
                  "Confirm",
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- EXISTING WIDGETS (UNTOUCHED DESIGN) ---

  Widget _buildProfileHeader(BuildContext context) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 8.h,
            backgroundImage: AssetImage(staff.imageUrl),
            backgroundColor: AppColors.textFieldBackground,
          ),
          SizedBox(height: 1.5.h),
          Text(
            staff.name,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            staff.role,
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "About ${staff.name.split(' ').first}",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          staff.bio,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            height: 1.4,
            color: AppColors.textPrimary.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingsSummary() {
    // The summary layout based on your screenshot
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            "Ratings & Reviews (${staff.reviewsCount})",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Center(
          child: Text(
            "Summary",
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: List.generate(5, (index) {
                  final star = 5 - index;
                  // These percentages are hardcoded to match the visual feel of your screenshot
                  final percentage = star == 5 ? 70.0 : star * 15.0;

                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.5.h),
                    child: Row(
                      children: [
                        Text(
                          '$star',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(child: _buildRatingBar(percentage)),
                      ],
                    ),
                  );
                }),
              ),
            ),
            SizedBox(width: 4.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Text(
                      '${staff.rating}',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 24.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Icon(Icons.star, size: 24.sp, color: AppColors.warning),
                  ],
                ),
                Text(
                  '${staff.reviewsCount} Reviews',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  '88%',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingBar(double percentage) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: percentage / 100,
        backgroundColor: AppColors.textFieldBackground,
        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
        minHeight: 1.5.h,
      ),
    );
  }

  // --- NEW WIDGET: Displays the list of individual reviews ---
  Widget _buildReviewList() {
    if (staff.reviews.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          child: Text(
            "No customer reviews yet.",
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 14.sp,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: staff.reviews.map((review) {
        return Padding(
          padding: EdgeInsets.only(bottom: 2.h), // Spacing between reviews
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 3.h,
                backgroundImage: AssetImage(
                  review['avatarPath'] ?? 'lib/assets/images/profile.png',
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name, Role, and Stars Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review['name'] ?? 'Anonymous',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 15.sp,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            // Text(
                            //   review['role'] ?? '',
                            //   style: GoogleFonts.inter(
                            //     fontSize: 14.sp,
                            //     color: AppColors.textSecondary,
                            //   ),
                            // ),
                          ],
                        ),
                        // Stars
                        Row(
                          children: List.generate(5, (starIndex) {
                            return Icon(
                              starIndex < (review['stars'] ?? 0)
                                  ? Icons.star
                                  : Icons.star_border,
                              color: AppColors.warning,
                              size: 16.sp,
                            );
                          }),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    // 🔑 Displays the comment text
                    Text(
                      review['comment'] ?? 'No comment provided.',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        height: 1.4,
                        color: AppColors.textPrimary.withOpacity(0.8),
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
