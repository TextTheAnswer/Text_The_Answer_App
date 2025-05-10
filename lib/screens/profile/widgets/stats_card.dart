import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:text_the_answer/config/colors.dart';
import 'package:text_the_answer/models/profile.dart';
import 'package:text_the_answer/utils/font_utility.dart';

class StatsCard extends StatelessWidget {
  final UserStats stats;
  final bool isDarkMode;

  const StatsCard({
    Key? key,
    required this.stats,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkPrimaryBg : AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: isDarkMode
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Stats',
            style: FontUtility.montserratBold(
              fontSize: 18.sp,
              color: isDarkMode ? Colors.white : AppColors.darkGray,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _buildStatItem(
                Icons.local_fire_department,
                'Streak',
                stats.streak.toString(),
                Colors.orange,
                flex: 1,
              ),
              SizedBox(width: 12.w),
              _buildStatItem(
                Icons.check_circle_outline,
                'Accuracy',
                stats.accuracy,
                Colors.green,
                flex: 1,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _buildStatItem(
                Icons.check,
                'Correct',
                stats.totalCorrect.toString(),
                Colors.blue,
                flex: 1,
              ),
              SizedBox(width: 12.w),
              _buildStatItem(
                Icons.question_answer_outlined,
                'Answered',
                stats.totalAnswered.toString(),
                Colors.purple,
                flex: 1,
              ),
            ],
          ),
          if (stats.lastPlayed.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16.sp,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Last played: ${stats.lastPlayed}',
                  style: FontUtility.interRegular(
                    fontSize: 14.sp,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String label,
    String value,
    Color color, {
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 18.sp,
                  color: color,
                ),
                SizedBox(width: 8.w),
                Text(
                  label,
                  style: FontUtility.interMedium(
                    fontSize: 14.sp,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              value,
              style: FontUtility.montserratBold(
                fontSize: 20.sp,
                color: isDarkMode ? Colors.white : color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 