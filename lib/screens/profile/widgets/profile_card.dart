import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:text_the_answer/config/colors.dart';
import 'package:text_the_answer/models/user_profile_model.dart';
import 'package:text_the_answer/screens/profile/edit_profile_screen.dart';
import 'package:text_the_answer/screens/profile/widgets/profile_image.dart';
import 'package:text_the_answer/utils/font_utility.dart';

/// Profile Card
class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.profile});

  final UserProfileFull profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 12),
        Row(
          children: [
            // -- Profile Image
            ProfileImage(imageUrl: profile.profile.imageUrl),
            SizedBox(width: 10.w),

            // -- User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // -- Name
                  Text(
                    profile.name,
                    style: FontUtility.montserratBold(fontSize: 20),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),

                  // -- Email
                  Text(
                    profile.email,
                    style: FontUtility.interRegular(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // -- Location
                  // SizedBox(height: 8.h),
                  // if (profile.profile.location != null &&
                  //     profile.profile.location!.isNotEmpty)
                  //   Row(
                  //     children: [
                  //       Icon(
                  //         Icons.location_on_outlined,
                  //         size: 16.sp,
                  //         color: Colors.grey,
                  //       ),
                  //       SizedBox(width: 4.w),
                  //       Expanded(
                  //         child: Text(
                  //           profile.profile.location!,
                  //           style: FontUtility.interRegular(fontSize: 14),
                  //           maxLines: 1,
                  //           overflow: TextOverflow.ellipsis,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                ],
              ),
            ),

            // -- Edit Profile
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(profileDetails: profile),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.buttonPrimary,
                ),
                child: Text('Edit Profile'),
              ),
            ),
          ],
        ),
        SizedBox(height: 4),

        // Subscription Badge
        if (profile.isPremium)
          Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Colors.amber.shade700),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: Colors.amber.shade700, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Premium Member',
                    style: FontUtility.montserratSemiBold(
                      fontSize: 14,
                      color: Colors.amber.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // -- Bio
        if (profile.profile.bio != null && profile.profile.bio!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bio',
                  style: FontUtility.montserratSemiBold(fontSize: 16),
                ),
                SizedBox(height: 4.h),
                Text(
                  profile.profile.bio!,
                  style: FontUtility.interRegular(fontSize: 14),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
