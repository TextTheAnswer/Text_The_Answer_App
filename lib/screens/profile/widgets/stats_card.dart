import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:text_the_answer/config/colors.dart';
import 'package:text_the_answer/models/profile.dart';
import 'package:text_the_answer/utils/font_utility.dart';

class StatsCard extends StatelessWidget {
  final UserStats stats;

  const StatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // -- Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // -- Title
            Text('Your Stats', style: TextStyle(fontSize: 24)),

            // -- Show More
            TextButton(
              onPressed: () {},
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
        SizedBox(height: 16),

        // -- Content
        Row(
          children: [
            // -- Streak
            _StartCardItem(
              icon: Icons.local_fire_department,
              label: 'Streak',
              value: stats.streak.toString(),
              color: Colors.orange,
            ),
            SizedBox(width: 12),

            // -- Accuracy
            _StartCardItem(
              icon: Icons.check_circle_outline,
              label: 'Accuracy',
              value: stats.accuracy,
              color: Colors.green,
            ),
          ],
        ),
        SizedBox(height: 16),

        Row(
          children: [
            // -- Correct
            _StartCardItem(
              icon: Icons.check,
              label: 'Correct',
              value: stats.totalCorrect.toString(),
              color: Colors.blue,
            ),
            SizedBox(width: 12),

            // -- Answered
            _StartCardItem(
              icon: Icons.question_answer_outlined,
              label: 'Answered',
              value: stats.totalAnswered.toString(),
              color: Colors.purple,
            ),
          ],
        ),

        if (stats.lastPlayed.isNotEmpty) ...[
          SizedBox(height: 16),
          Row(
            children: [
              Icon(
                IconlyLight.calendar,
                size: 16,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
              SizedBox(width: 8),
              Text(
                'Last played: ${stats.lastPlayed}',
                style: FontUtility.interRegular(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _StartCardItem extends StatelessWidget {
  const _StartCardItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.flex = 1,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                SizedBox(width: 8),
                Text(label, style: FontUtility.interMedium(fontSize: 14)),
              ],
            ),
            SizedBox(height: 8),
            Text(value, style: FontUtility.montserratBold(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
