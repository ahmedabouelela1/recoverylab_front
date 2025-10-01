import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:sizer/sizer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Profile + Greeting + Notification
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundImage: AssetImage(
                      "lib/assets/images/profile.png",
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hi Michael,",
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontSize: 14.sp,
                        ),
                      ),
                      Text(
                        "Good Morning!",
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Stack(
                    children: [
                      Icon(
                        Icons.notifications_none,
                        color: AppColors.textSecondary,
                        size: 28,
                      ),
                      Positioned(
                        right: 0,
                        child: CircleAvatar(
                          radius: 8,
                          backgroundColor: Colors.red,
                          child: Text(
                            "3",
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 3.h),

              // Search Bar
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search",
                        hintStyle: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontSize: 14.sp,
                        ),
                        filled: true,
                        fillColor: AppColors.cardBackground,
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.textSecondary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  GestureDetector(
                    onTap: () {
                      // Handle filter button tap
                      print("filter button tapped");
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.tune, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 3.h),

              // Special Offers
              Text(
                "Special offers",
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 1.5.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: AssetImage("lib/assets/images/Offer.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Massage room",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      "20% discount",
                      style: GoogleFonts.inter(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      "Jun 16 - Jun 18",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: AppColors.secondary),
                        ),
                      ),
                      onPressed: () {},
                      child: Text(
                        "Get offer now >",
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              // Browse Categories
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Browse Categories",
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      print("See All tapped");
                    },
                    child: Text(
                      "See All",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              SizedBox(
                height: 10.h, // ✅ matches category height
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCategory(context, "Spa", "lib/assets/images/spa.jpg"),
                    SizedBox(width: 3.w),
                    _buildCategory(
                      context,
                      "Massage",
                      "lib/assets/images/massage.jpg",
                    ),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              // Recommended for you
              Text(
                "Recommended for you",
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: _buildRecommended(
                      context,
                      "Vital Steam Sanctuary",
                      "Sheikh Zayed",
                      "lib/assets/images/steam.jpg",
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: _buildRecommended(
                      context,
                      "Serene Massage Retreat",
                      "New Cairo",
                      "lib/assets/images/retreat.jpg",
                    ),
                  ),
                ],
              ),

              SizedBox(height: 4.h),

              // Page indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _indicator(true),
                  SizedBox(width: 2.w),
                  _indicator(false),
                  SizedBox(width: 2.w),
                  _indicator(false),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategory(BuildContext context, String title, String imagePath) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, Routes.categories, arguments: title);
        print("$title category tapped");
      },
      child: Container(
        width: 44.w,
        height: 20.h, // ✅ consistent height
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        alignment: Alignment.center,
        child: Container(
          padding: EdgeInsets.all(8),
          color: Colors.transparent,
          child: Text(
            title,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecommended(
    BuildContext context,
    String title,
    String location,
    String imagePath,
  ) {
    return GestureDetector(
      onTap: () {
        print("$title recommended tapped");
        Navigator.pushNamed(
          context,
          Routes.serviceDetails,
          arguments: {
            'title': title,
            'location': location,
            'rating': "4.8 (320)",
            'image': imagePath,
            'price': "\$120", // ✅ Added
            'duration': "60 min", // ✅ Added
            'availableFeatures': [
              // ✅ Added
              "Full body massage",
              "Aromatherapy oils",
              "Complimentary tea",
            ],
            'reviews': [
              // ✅ Added
              {
                'name': "Alice",
                'stars': "5",
                'comment': "Absolutely relaxing, best massage I’ve had!",
              },
              {
                'name': "John",
                'stars': "4",
                'comment': "Very good service, but could be longer.",
              },
            ],
          },
        );
      },
      child: Container(
        height: 22.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withOpacity(0.7), Colors.transparent],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 0.5.h),
              Row(
                children: [
                  Icon(Icons.location_on, size: 15, color: Colors.white),
                  SizedBox(width: 1.w),
                  Text(
                    location,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0.5.h),
              Row(
                children: [
                  Icon(Icons.star, size: 15, color: Colors.amber),
                  SizedBox(width: 1.w),
                  Text(
                    "4.8 (320)",
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _indicator(bool isActive) {
    return Container(
      width: isActive ? 22 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.grey,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
