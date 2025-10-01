// pages/packages/packages_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

// Import your configurations
import 'package:recoverylab_front/configurations/colors.dart';

// Import your tab files
import 'tabs/combos_tab.dart';
import 'tabs/membership_tab.dart';
import 'tabs/packages_tab.dart';

class PackagesPage extends StatefulWidget {
  const PackagesPage({super.key});

  @override
  State<PackagesPage> createState() => _PackagesPageState();
}

class _PackagesPageState extends State<PackagesPage> {
  // Use a String to track the selected state, as the custom buttons don't use a TabController
  String selectedTab = 'Combos';

  // Map to hold the tab widgets
  final Map<String, Widget> tabViews = const {
    'Combos': CombosTab(),
    'Membership': MembershipTab(),
    'Packages': PackagesTab(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        // This line removes the back arrow or leading icon
        automaticallyImplyLeading: false,

        // Note: The iconTheme is now unnecessary since no leading icon will be shown
        // title: Text( ... ) remains the same
        title: Text(
          "Packages",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: AppColors.textPrimary, // White
          ),
        ),
      ),
      body: Column(
        children: [
          // 1. Tab/Segmented Control (Top Row) - Custom Implementation
          Padding(
            // Reduced vertical padding as the control seems closer to the app bar
            padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
            child: Container(
              // The entire control has a dark background and rounded edges
              decoration: BoxDecoration(
                color: AppColors.cardBackground, // Dark grey background
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTabButton('Combos'),
                  _buildTabButton('Membership'),
                  _buildTabButton('Packages'),
                ],
              ),
            ),
          ),

          // 2. Current Tab View
          Expanded(child: tabViews[selectedTab]!),
        ],
      ),
    );
  }

  // Helper widget to build the custom tab buttons (the 'pill' design)
  Widget _buildTabButton(String tabName) {
    final isSelected = selectedTab == tabName;

    return Expanded(
      // Ensures buttons fill the container width
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = tabName;
          });
        },
        child: Container(
          // Inner padding to make the pill height correct
          padding: EdgeInsets.symmetric(vertical: 1.2.h, horizontal: 1.w),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            // Use AppColors.textPrimary (White) for selected background
            color: isSelected ? AppColors.textPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Text(
            tabName,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              // Use AppColors.background (Black) for selected text
              color: isSelected ? AppColors.background : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
