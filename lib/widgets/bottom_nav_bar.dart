import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:text_the_answer/config/colors.dart';
import 'package:text_the_answer/router/routes.dart';
import 'package:text_the_answer/utils/font_utility.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
     this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? AppColors.darkPrimaryBg : AppColors.lightPrimaryBg;
    final shadowColor = isDarkMode 
        ? Colors.black.withOpacity(0.3) 
        : Colors.black.withOpacity(0.05);

    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 10.r,
            offset: Offset(0, -5.h),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home', context),
          _buildNavItem(1, Icons.book_outlined, Icons.book, 'Library', context),
          _buildJoinButton(2, context),
          _buildNavItem(3, Icons.quiz_outlined, Icons.quiz, 'Quiz', context),
          _buildProfileNavItem(context),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData outlinedIcon,
    IconData filledIcon,
    String label,
    BuildContext context,
  ) {
    final bool isSelected = currentIndex == index;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final Color selectedColor = AppColors.primary;
    final Color unselectedColor = isDarkMode
        ? AppColors.darkLabelText
        : AppColors.lightLabelText;

    return InkWell(
      onTap: () => onTap!(index),
      child: Container(
        width: 70.w,
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? filledIcon : outlinedIcon,
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
  
  Widget _buildProfileNavItem(BuildContext context) {
    final bool isSelected = currentIndex == 4;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final Color selectedColor = AppColors.primary;
    final Color unselectedColor = isDarkMode
        ? AppColors.darkLabelText
        : AppColors.lightLabelText;

    return InkWell(
      onTap: () {
        // Navigate to profile screen instead of changing tab
        Navigator.pushNamed(context, Routes.profile);
      },
      child: Container(
        width: 70.w,
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.person : Icons.person_outline,
              color: isSelected ? selectedColor : unselectedColor,
              size: 28.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              'Profile',
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final Color buttonColor = isSelected
        ? AppColors.primary.withOpacity(0.2)
        : AppColors.primary;
    
    final Color iconColor = isSelected 
        ? AppColors.primary 
        : (isDarkMode ? AppColors.darkPrimaryText : AppColors.lightPrimaryBg);

    return GestureDetector(
      onTap: () => onTap!(index),
      child: Container(
        width: 60.w,
        height: 60.h,
        decoration: BoxDecoration(
          color: buttonColor,
          shape: BoxShape.circle,
          boxShadow: isSelected ? [] : [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.gamepad,
            color: iconColor,
            size: 30.sp,
          ),
        ),
      ),
    );
  }
} 