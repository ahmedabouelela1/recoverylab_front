import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:sizer/sizer.dart';

class CategoryDetailsPage extends StatelessWidget {
  final String category;

  const CategoryDetailsPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    // Mock services data
    final List<Map<String, String>> services = [
      {
        "title": "Vital Steam Sanctuary",
        "location": "Sheikh Zayed",
        "image": "lib/assets/images/steam.jpg",
        "rating": "4.8 (320)",
      },
      {
        "title": "Serene Massage Retreat",
        "location": "New Cairo",
        "image": "lib/assets/images/massage.jpg",
        "rating": "4.7 (280)",
      },
      {
        "title": "Luxury Facial Haven",
        "location": "Sheikh Zayed",
        "image": "lib/assets/images/haven.jpg",
        "rating": "4.9 (150)",
      },
      {
        "title": "Vital Steam Sanctuary",
        "location": "Sheikh Zayed",
        "image": "lib/assets/images/steam.jpg",
        "rating": "4.8 (320)",
      },
    ];

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            category,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
              color: Colors.white,
            ),
          ),
        ),
        body: ListView.builder(
          padding: EdgeInsets.all(4.w),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 2.h),
              child: _buildServiceCard(
                context,
                service["title"]!,
                service["location"]!,
                service["image"]!,
                service["rating"]!,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    String title,
    String location,
    String imagePath,
    String rating,
  ) {
    return GestureDetector(
      onTap: () {
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
          padding: const EdgeInsets.all(12),
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
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 0.5.h),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 15, color: Colors.white),
                  SizedBox(width: 1.w),
                  Text(
                    location,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0.5.h),
              // Row(
              //   children: [
              //     const Icon(Icons.star, size: 15, color: Colors.amber),
              //     SizedBox(width: 1.w),
              //     Text(
              //       rating,
              //       style: GoogleFonts.inter(
              //         fontSize: 14.sp,
              //         color: Colors.white,
              //       ),
              //     ),
              //   ],
              // ),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  "view details",
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
