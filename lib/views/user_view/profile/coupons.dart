import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:sizer/sizer.dart';
import 'package:dotted_line/dotted_line.dart';

// --- CORRECTED WIDGET: TicketClipperV2 for the coupon shape ---

/// Custom Clipper to create the ticket/coupon shape with semi-circular cutouts on the sides
class TicketClipperV2 extends CustomClipper<Path> {
  final double notchRadius;

  TicketClipperV2({this.notchRadius = 14.0});

  @override
  Path getClip(Size size) {
    final Path path = Path();
    final double w = size.width;
    final double h = size.height;
    final double halfH = h / 2;

    // Start top-left
    path.moveTo(0, 0);
    path.lineTo(w, 0);

    // Right side before cutout
    path.lineTo(w, halfH - notchRadius);

    // Inward semi-circle cutout (RIGHT side)
    path.arcToPoint(
      Offset(w, halfH + notchRadius),
      radius: Radius.circular(notchRadius),
      clockwise: false, // 👈 inward cut
    );

    // Bottom-right
    path.lineTo(w, h);
    path.lineTo(0, h);

    // Left side before cutout
    path.lineTo(0, halfH + notchRadius);

    // Inward semi-circle cutout (LEFT side)
    path.arcToPoint(
      Offset(0, halfH - notchRadius),
      radius: Radius.circular(notchRadius),
      clockwise: false, // 👈 inward cut
    );

    // Back to top-left
    path.lineTo(0, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(TicketClipperV2 oldClipper) =>
      oldClipper.notchRadius != notchRadius;
}

// --- UPDATED WIDGET: CouponsPage and _buildCouponCard ---

class CouponsPage extends StatelessWidget {
  const CouponsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "My Coupons",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 2.h),
            child: _buildCouponCard(context),
          );
        },
      ),
    );
  }

  Widget _buildCouponCard(BuildContext context) {
    // We use a ClipRRect for the slightly rounded corners and then ClipPath
    // for the side cutouts to match the design's combination of effects.
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ClipPath(
        clipper: TicketClipperV2(
          notchRadius: 15.0,
        ), // Smaller radius for the ticket cutout
        child: Material(
          // The background color of the coupon
          color: AppColors.cardBackground,
          child: InkWell(
            onTap: () {
              // Handle coupon tap
            },
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, Routes.couponRedeemed);
              },
              child: Container(
                // Using a fixed height and symmetrical padding to match the compact look
                height: 12.h,
                padding: EdgeInsets.symmetric(vertical: 2.w, horizontal: 4.w),
                child: Row(
                  children: [
                    SizedBox(width: 6.w),
                    // Coupon Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        // Using the same placeholder image from your original code
                        'lib/assets/images/haven.jpg',
                        width: 6.h,
                        height: 6.h,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 8.h,
                            height: 8.h,
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.image, color: Colors.grey[600]),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      child: DottedLine(
                        direction: Axis.vertical, // vertical line
                        lineLength: double.infinity,
                        lineThickness: 0.9, // 👈 thinner line
                        dashLength: 5.0,
                        dashGapLength: 4.0,
                        dashColor: AppColors.textSecondary,
                      ), // 👈 softer faded white
                    ),
                    SizedBox(width: 4.w),

                    // Coupon Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment
                            .center, // Vertically center the text
                        children: [
                          Text(
                            '\$10',
                            style: GoogleFonts.inter(
                              color: AppColors.textPrimary,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Title is on the second line
                          Text(
                            'Massage',
                            style: GoogleFonts.inter(
                              color: AppColors.textPrimary,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          // Validity text
                          Text(
                            'Valid until 01 February 2026',
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
