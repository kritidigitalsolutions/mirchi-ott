import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mirchi_ott/app/theme/app_colors.dart';

class CustomBottomNavbar extends StatelessWidget {
  final int selectedIndex;
  final bool isLoggedIn;
  final Function(int) onItemTapped;

  const CustomBottomNavbar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    double navHeight = height * 0.09;
    double iconSize = width * 0.055;
    double fontSize = width * 0.03;

    return Padding(
      padding: EdgeInsets.only(
        left: width * 0.15,
        right: width * 0.15,
        bottom: height * 0.025,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(width * 0.07),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: navHeight,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45),
              borderRadius: BorderRadius.circular(width * 0.07),
              border: Border.all(
                color: Colors.white.withOpacity(0.06),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.calendar_month_outlined, "Upcoming", 0, iconSize, fontSize),
                _buildNavItem(Icons.home_outlined, "Home", 1, iconSize, fontSize),
                _buildNavItem(
                  isLoggedIn ? Icons.person_outline : Icons.menu,
                  isLoggedIn ? "Profile" : "More",
                  2,
                  iconSize,
                  fontSize,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon,
      String label,
      int index,
      double iconSize,
      double fontSize,
      ) {

    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.buttonColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppColors.white,
              size: iconSize,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: AppColors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
