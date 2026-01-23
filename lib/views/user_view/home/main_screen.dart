import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/views/user_view/bookings/booking_screen.dart';
import 'package:recoverylab_front/views/user_view/home/home.dart';
import 'package:recoverylab_front/views/user_view/packages/packages_page.dart';
import 'package:recoverylab_front/views/user_view/profile/settings.dart';
import 'package:solar_icons/solar_icons.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    BookingScreen(),
    PackagesPage(),
    SettingsPage(),
  ];

  final GlobalKey<CurvedNavigationBarState> _bottomNavKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _pages[_selectedIndex],

      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavKey,
        index: _selectedIndex,
        height: 60,
        backgroundColor: Colors.transparent,
        color: AppColors.primary, // bar color
        // buttonBackgroundColor: Colors.black, // active icon bg
        animationDuration: const Duration(milliseconds: 300),

        items: const [
          Icon(SolarIconsOutline.home, size: 26, color: Colors.white),
          Icon(SolarIconsOutline.calendarAdd, size: 26, color: Colors.white),
          Icon(SolarIconsOutline.bedsideTable4, size: 26, color: Colors.white),
          Icon(SolarIconsOutline.user, size: 26, color: Colors.white),
        ],

        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
