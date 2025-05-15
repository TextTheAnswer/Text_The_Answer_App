import 'package:flutter/material.dart';
import 'package:text_the_answer/config/colors.dart';
import 'package:text_the_answer/models/profile.dart';
import 'package:text_the_answer/utils/font_utility.dart';

@Deprecated('Use PortraitProfileHeader and LandscapeProfileHeader instead ')
class ProfileHeader extends StatelessWidget {
  final ProfileData profile;
  final bool isUpdating;
  final VoidCallback? onEditPressed;

  const ProfileHeader({
    super.key,
    required this.profile,
    this.isUpdating = false,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? AppColors.darkPrimaryBg
                : AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Profile image and basic info
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor:
                    isDarkMode
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : AppColors.primary.withValues(alpha: 0.2),
                backgroundImage:
                    profile.profile.imageUrl.isNotEmpty
                        ? NetworkImage(profile.profile.imageUrl)
                        : null,
                child:
                    profile.profile.imageUrl.isEmpty
                        ? Icon(Icons.person, size: 40, color: AppColors.primary)
                        : null,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: FontUtility.montserratBold(fontSize: 20),
                    ),
                    SizedBox(height: 4),
                    Text(
                      profile.email,
                      style: FontUtility.interRegular(
                        fontSize: 14,
                        color:
                            isDarkMode
                                ? AppColors.white.withValues(alpha: 0.7)
                                : AppColors.darkGray.withValues(alpha: 0.7),
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                profile.isPremium
                                    ? Colors.amber.withValues(alpha: 0.2)
                                    : Colors.grey.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                profile.isPremium ? Icons.star : Icons.person,
                                size: 14,
                                color:
                                    profile.isPremium
                                        ? Colors.amber
                                        : isDarkMode
                                        ? Colors.white70
                                        : Colors.black54,
                              ),
                              SizedBox(width: 4),
                              Text(
                                profile.isPremium ? 'Premium' : 'Free',
                                style: FontUtility.interMedium(
                                  fontSize: 12,
                                  color:
                                      profile.isPremium
                                          ? Colors.amber
                                          : isDarkMode
                                          ? Colors.white70
                                          : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (profile.isEducation) ...[
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.school,
                                  size: 14,
                                  color: Colors.blue,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Education',
                                  style: FontUtility.interMedium(
                                    fontSize: 12,
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
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isDarkMode
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                profile.profile.bio,
                style: FontUtility.interRegular(
                  fontSize: 14,
                  color:
                      isDarkMode
                          ? Colors.white.withValues(alpha: 0.9)
                          : Colors.black.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],

          // Location if available
          if (profile.profile.location.isNotEmpty) ...[
            SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
                SizedBox(width: 4),
                Text(
                  profile.profile.location,
                  style: FontUtility.interRegular(
                    fontSize: 14,
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
