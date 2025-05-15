import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconly/iconly.dart';
import 'package:text_the_answer/models/achievement.dart';
import 'package:text_the_answer/router/routes.dart';
import 'package:text_the_answer/utils/font_utility.dart';
import 'package:text_the_answer/widgets/common/achievement_badge.dart';

class ProfileAchievementSection extends StatelessWidget {
  const ProfileAchievementSection({
    super.key,
    required this.achievements,
    required this.unviewedAchievements,
  });

  final List<Achievement> achievements;
  final List<Achievement> unviewedAchievements;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // -- Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // -- Title
            Text('Achievements', style: TextStyle(fontSize: 24)),

            // -- Show More
            TextButton(
              onPressed: () {
                // context.go('${AppRoutePath.library}/achievements');
              },
              style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
              child: Row(
                children: [
                  Text('View All'),
                  const SizedBox(width: 4),
                  Icon(IconlyLight.arrow_right_2),
                ],
              ),
            ),
          ],
        ),

        // -- Content

        // -- Empty Achievements
        if (achievements.isEmpty)
          SizedBox(
            height: 70,
            child: Center(child: Text('Complete quizzes to earn achievements')),
          ),

        // -- Active Achievements
        //TODO: Code below not audited
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badges row
            AchievementBadgeRow(
              achievements: achievements,
              badgeSize: 50,
              onViewAll: () {
                context.go('${AppRoutePath.library}/achievements');
              },
            ),
            if (unviewedAchievements.isNotEmpty) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.celebration, color: Colors.amber),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You have ${unviewedAchievements.length} new achievements!',
                        style: FontUtility.interMedium(
                          fontSize: 14,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
