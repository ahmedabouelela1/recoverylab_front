import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class CustomNavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const CustomNavBarItem({
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
          // if (isSelected) ...[
          //   SizedBox(width: 1.5.w),
          //   Text(
          //     label,
          //     style: TextStyle(
          //       color: textColor,
          //       fontWeight: FontWeight.w600,
          //       fontSize: 14,
          //     ),
          //   ),
          // ],
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
