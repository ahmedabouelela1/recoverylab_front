import 'package:flutter/material.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/views/user_view/bookings/booking_screen.dart';
import 'package:recoverylab_front/views/user_view/home/home.dart';
import 'package:recoverylab_front/views/user_view/packages/packages_page.dart';
import 'package:recoverylab_front/views/user_view/profile/settings.dart';
import 'package:sizer/sizer.dart';

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _CustomNavBarItem(
                icon: Icons.home_outlined,
                label: 'Home',
                index: 0,
                selectedIndex: _selectedIndex,
                onTap: _onItemTapped,
              ),
              _CustomNavBarItem(
                icon: Icons.calendar_today_outlined,
                label: 'Booking',
                index: 1,
                selectedIndex: _selectedIndex,
                onTap: _onItemTapped,
              ),
              _CustomNavBarItem(
                icon: Icons.inventory_2_outlined,
                label: 'Packages',
                index: 2,
                selectedIndex: _selectedIndex,
                onTap: _onItemTapped,
              ),
              _CustomNavBarItem(
                icon: Icons.person_outline,
                label: 'Profile',
                index: 3,
                selectedIndex: _selectedIndex,
                onTap: _onItemTapped,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomNavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _CustomNavBarItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
  });

  bool get isSelected => index == selectedIndex;

  @override
  Widget build(BuildContext context) {
    final Color iconColor = isSelected ? Colors.black : Colors.grey.shade500;
    final Color textColor = isSelected ? Colors.black : Colors.grey.shade500;
    final Color backgroundColor = isSelected
        ? Colors.white
        : Colors.transparent;

    final double verticalPadding = 1.25.h;

    final Widget content = Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: verticalPadding),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 24),
          if (isSelected) ...[
            SizedBox(width: 1.5.w),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        child: Center(
          // ✅ Keeps item centered inside its slot
          child: FittedBox(
            // ✅ Prevents overflow by scaling content slightly if needed
            fit: BoxFit.scaleDown,
            child: isSelected
                ? content
                : Container(
                    padding: EdgeInsets.symmetric(vertical: verticalPadding),
                    alignment: Alignment.center,
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
          ),
        ),
      ),
    );
  }
}
