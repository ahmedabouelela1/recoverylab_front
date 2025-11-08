import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:sizer/sizer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> branches = [
    'All Branches',
    'Sheikh Zayed',
    'New Cairo',
    'October City',
  ];
  String? selectedBranch = 'All Branches';

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
              // 👤 Top Row: Profile + Greeting + Notification
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundImage: AssetImage(
                      "lib/assets/images/profile.png",
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      "Hi Michael,",
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
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

              SizedBox(height: 2.5.h),

              // 🏢 Branch Dropdown (below greeting)
              Text(
                "Select Branch",
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              _buildBranchDropdown(),

              SizedBox(height: 3.h),

              // 🔍 Search Bar
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
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.tune, color: AppColors.textSecondary),
                  ),
                ],
              ),

              SizedBox(height: 3.h),

              // 🌟 Special Offers
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
                height: 20.h, // Optional: set a fixed height if needed
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: AssetImage("lib/assets/images/Offer.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Massage room",
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            "20% discount",
                            style: GoogleFonts.inter(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            "Jun 16 - Jun 18",
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: Colors.white,
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
                                fontWeight: FontWeight.w700,
                                fontSize: 15.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              // 🧭 Browse Categories
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
                height: 10.h,
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

              // 💆 Recommended for you
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

              // 🔘 Page indicator
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

  // 🏢 Styled Branch Dropdown
  Widget _buildBranchDropdown() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedBranch,
          isExpanded: true,
          dropdownColor: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.primary,
            size: 22,
          ),
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          onChanged: (String? newValue) {
            setState(() {
              selectedBranch = newValue;
            });
          },
          items: branches.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Row(
                children: [
                  Icon(
                    Icons.store_mall_directory_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // 🧩 Category Tile
  Widget _buildCategory(BuildContext context, String title, String imagePath) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, Routes.categories, arguments: title);
      },
      child: Container(
        width: 44.w,
        height: 20.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        alignment: Alignment.center,
        child: Container(
          color: Colors.transparent,
          padding: EdgeInsets.all(8),
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

  // ⭐ Recommended Card
  Widget _buildRecommended(
    BuildContext context,
    String title,
    String location,
    String imagePath,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.serviceDetails,
          arguments: {
            'title': title,
            'location': location,
            'image': imagePath,
            'price': "\$120",
            'duration': "60 min",
            'availableFeatures': [
              "Full body massage",
              "Aromatherapy oils",
              "Complimentary tea",
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
            ],
          ),
        ),
      ),
    );
  }

  // 🔘 Page Indicator
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
