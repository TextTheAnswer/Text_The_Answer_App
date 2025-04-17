import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:text_the_answer/config/colors.dart';
import 'package:text_the_answer/utils/font_utility.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color:
            Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkGray
                : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, -5.h),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(0, Icons.home, 'Home', context),
          _buildNavItem(1, Icons.category, 'Categories', context),
          _buildJoinButton(2, context),
          _buildNavItem(3, Icons.extension, 'Daily Quiz', context),
          _buildNavItem(4, Icons.person, 'Profile', context),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    BuildContext context,
  ) {
    final bool isSelected = currentIndex == index;
    final Color selectedColor = AppColors.primary;
    final Color unselectedColor =
        Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withOpacity(0.7)
            : Colors.black.withOpacity(0.5);

    return InkWell(
      onTap: () => onTap(index),
      child: Container(
        width: 70.w,
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? selectedColor : unselectedColor,
              size: 28.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: FontUtility.montserratMedium(
                fontSize: 12,
                color: isSelected ? selectedColor : unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinButton(int index, BuildContext context) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        width: 60.w,
        height: 60.h,
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primary.withOpacity(0.2)
                  : AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.gamepad,
            color: isSelected ? AppColors.primary : Colors.white,
            size: 30.sp,
          ),
        ),
      ),
    );
  }
}
