import 'package:flutter/material.dart';
import 'package:text_the_answer/config/colors.dart';
import 'package:text_the_answer/models/profile.dart';
import 'package:text_the_answer/utils/font_utility.dart';

class PortraitProfileHeader extends StatelessWidget {
  const PortraitProfileHeader({
    super.key,
    required this.profile,
    this.onEditPressed,
  });

  final ProfileData profile;
  final VoidCallback? onEditPressed;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -- Avater and Username
          Row(
            children: [
              // -- Avater
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary.withValues(alpha: 0.3),
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

              // -- Name and Username
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // -- Name
                    Text(profile.name, style: TextStyle(fontSize: 34)),
                    const SizedBox(height: 4),

                    // -- Username
                    Text(
                      profile.email,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            isDarkMode
                                ? AppColors.white.withValues(alpha: 0.7)
                                : AppColors.darkGray.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // -- Edit Profile
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // -- Premium check
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      profile.isPremium
                          ? Colors.amber.withValues(alpha: 0.2)
                          : Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      profile.isPremium ? Icons.star : Icons.person,
                      size: 20,
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
                        fontSize: 16,
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

              // -- Edit Profile
              ElevatedButton(
                onPressed: () {},

                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  shape: StadiumBorder(),
                ),
                child: Text('Edit Profile'),
              ),
            ],
          ),

          // -- Bio
          if (profile.profile.bio.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Bio', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 8),

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
                style: TextStyle(
                  fontSize: 14,
                  color:
                      isDarkMode
                          ? Colors.white.withValues(alpha: 0.9)
                          : Colors.black.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
