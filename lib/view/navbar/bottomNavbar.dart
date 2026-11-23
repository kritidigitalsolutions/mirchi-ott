import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirchi_ott/app/routes/app_routes.dart';
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
    bool isHomeSelected = selectedIndex == 1;
    bool isUpcomingSelected = selectedIndex == 0;
    bool isProfileSelected = selectedIndex == 2;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF161616).withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(35),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(
                  icon: isHomeSelected ? Icons.home_rounded : Icons.home_outlined,
                  label: "Home",
                  isSelected: isHomeSelected,
                  onTap: () => onItemTapped(1),
                ),
                _buildNavItem(
                  icon: Icons.search_rounded,
                  label: "Search",
                  isSelected: false,
                  onTap: () => Get.toNamed(AppRoutes.search),
                ),
                _buildNavItem(
                  icon: isUpcomingSelected
                      ? Icons.calendar_month_rounded
                      : Icons.calendar_month_outlined,
                  label: "Upcoming",
                  isSelected: isUpcomingSelected,
                  onTap: () => onItemTapped(0),
                ),
                _buildNavItem(
                  icon: isProfileSelected
                      ? Icons.person_rounded
                      : Icons.person_outline_rounded,
                  label: isLoggedIn ? "Profile" : "More",
                  isSelected: isProfileSelected,
                  onTap: () => onItemTapped(2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 18 : 10,
          vertical: isSelected ? 6 : 4,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white70,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
