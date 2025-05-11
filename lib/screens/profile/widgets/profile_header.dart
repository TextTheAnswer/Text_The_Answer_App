import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:text_the_answer/config/colors.dart';
import 'package:text_the_answer/models/profile.dart';
import 'package:text_the_answer/utils/font_utility.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileData profile;
  final bool isDarkMode;
  final bool isUpdating;
  final VoidCallback? onEditPressed;

  const ProfileHeader({
    Key? key,
    required this.profile,
    required this.isDarkMode,
    this.isUpdating = false,
    this.onEditPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkPrimaryBg : AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          // Profile image and basic info
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 40.r,
                    backgroundColor: isDarkMode 
                      ? AppColors.primary.withOpacity(0.3)
                      : AppColors.primary.withOpacity(0.2),
                    backgroundImage: profile.profile.imageUrl.isNotEmpty
                      ? NetworkImage(profile.profile.imageUrl)
                      : null,
                    child: profile.profile.imageUrl.isEmpty
                      ? Icon(
                          Icons.person,
                          size: 40.r,
                          color: AppColors.primary,
                        )
                      : null,
                  ),
                  if (onEditPressed != null)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: isUpdating ? null : onEditPressed,
                        child: Container(
                          padding: EdgeInsets.all(4.r),
                          decoration: BoxDecoration(
                            color: isUpdating
                                ? Colors.grey
                                : AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.edit,
                            size: 16.r,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: FontUtility.montserratBold(
                        fontSize: 20.sp,
                        color: isDarkMode 
                          ? AppColors.white 
                          : AppColors.darkGray,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      profile.email,
                      style: FontUtility.interRegular(
                        fontSize: 14.sp,
                        color: isDarkMode 
                          ? AppColors.white.withOpacity(0.7) 
                          : AppColors.darkGray.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: profile.isPremium
                              ? Colors.amber.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                profile.isPremium ? Icons.star : Icons.person,
                                size: 14.sp,
                                color: profile.isPremium
                                  ? Colors.amber
                                  : isDarkMode ? Colors.white70 : Colors.black54,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                profile.isPremium ? 'Premium' : 'Free',
                                style: FontUtility.interMedium(
                                  fontSize: 12.sp,
                                  color: profile.isPremium
                                    ? Colors.amber
                                    : isDarkMode ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (profile.isEducation) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.school,
                                  size: 14.sp,
                                  color: Colors.blue,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'Education',
                                  style: FontUtility.interMedium(
                                    fontSize: 12.sp,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Bio section if available
          if (profile.profile.bio.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: isDarkMode 
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                profile.profile.bio,
                style: FontUtility.interRegular(
                  fontSize: 14.sp,
                  color: isDarkMode 
                    ? Colors.white.withOpacity(0.9)
                    : Colors.black.withOpacity(0.8),
                ),
              ),
            ),
          ],
          
          // Location if available
          if (profile.profile.location.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16.sp,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
                SizedBox(width: 4.w),
                Text(
                  profile.profile.location,
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
} 