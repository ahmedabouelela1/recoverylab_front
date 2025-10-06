// service_details_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/components/app_button.dart';
import 'package:sizer/sizer.dart';
import 'dart:math';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:recoverylab_front/models/booking_model.dart';

class ServiceDetailsPage extends StatelessWidget {
  final String title;
  final String location;
  final String rating;
  final String image;
  final String price;
  final String duration;
  final List<String> availableFeatures;
  final List<Map<String, String>> reviews;

  const ServiceDetailsPage({
    super.key,
    required this.title,
    required this.location,
    required this.rating,
    required this.image,
    required this.price,
    required this.duration,
    required this.availableFeatures,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(4.w),
        children: [
          // 🖼️ Image with Gradient Overlay
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Image.asset(
                  image,
                  height: 20.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                // 🎨 Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.4), // soft dark top
                          Colors.transparent, // clear middle
                          Colors.black.withOpacity(0.8), // deep bottom
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),

          // Title, Price, and Duration
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          duration,
                          style: GoogleFonts.inter(
                            fontSize: 15.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: GoogleFonts.inter(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 1.h),

          // Location & Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, size: 18, color: Colors.grey),
                  SizedBox(width: 1.w),
                  Text(
                    location,
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.star, size: 18, color: Colors.amber),
                  SizedBox(width: 1.w),
                  Text(
                    rating,
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Description
          Text(
            "About this service",
            style: GoogleFonts.inter(
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            "This is a relaxing and rejuvenating experience designed to help you unwind. "
            "Enjoy the premium facilities and expert care provided by our professionals.",
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: 3.h),

          // Features/Inclusions Section
          Text(
            "What's Included",
            style: GoogleFonts.inter(
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 1.h),
          ...availableFeatures.map(
            (feature) => Padding(
              padding: EdgeInsets.only(bottom: 0.5.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      feature,
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 3.h),

          // Customer Reviews Section
          Text(
            "Customer Reviews",
            style: GoogleFonts.inter(
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 1.h),
          ...reviews.map(
            (review) => Padding(
              padding: EdgeInsets.only(bottom: 2.h),
              child: Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.textSecondary.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          review['name']!,
                          style: GoogleFonts.inter(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            ...List.generate(
                              int.tryParse(review['stars']!) ?? 0,
                              (index) => const Icon(
                                Icons.star,
                                size: 18,
                                color: Colors.amber,
                              ),
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              review['stars']!,
                              style: GoogleFonts.inter(
                                fontSize: 15.sp,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      review['comment']!,
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 3.h),
        ],
      ),

      // Bottom Button
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(4.w),
        child: AppButton(
          label: "Book Now",
          width: double.infinity,
          size: AppButtonSize.large,
          onPressed: () {
            final double parsedRating = double.tryParse(rating) ?? 0.0;
            final String temporaryId =
                DateTime.now().millisecondsSinceEpoch.toString() +
                Random().nextInt(1000).toString();

            final Booking newBooking = Booking(
              id: temporaryId,
              title: title,
              description: 'Booking for $title at $location.',
              imageUrl: image,
              duration: duration,
              rating: parsedRating,
              location: location,
              date: '',
              time: '',
              status: BookingStatus.upcoming,
            );

            Navigator.pushNamed(
              context,
              Routes.bookingsOne,
              arguments: newBooking,
            );
            print("Navigating to Booking Page One for $title");
          },
        ),
      ),
    );
  }
}
