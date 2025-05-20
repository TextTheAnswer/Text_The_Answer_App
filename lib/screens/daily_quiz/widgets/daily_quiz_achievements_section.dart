import 'package:flutter/material.dart';

class DailyQuizAchievementsSection extends StatelessWidget {
  const DailyQuizAchievementsSection({super.key, required this.achievements});

  final List<Map<String, dynamic>> achievements;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'New Achievements',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            Column(
              children:
                  achievements
                      .map(
                        (achievement) =>
                            _AchievementItem(achievement: achievement),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementItem extends StatelessWidget {
  const _AchievementItem({required this.achievement});

  final Map<String, dynamic> achievement;

  @override
  Widget build(BuildContext context) {
    IconData iconData = Icons.emoji_events;
    if (achievement['icon'] == 'bolt') {
      iconData = Icons.bolt;
    } else if (achievement['icon'] == 'star') {
      iconData = Icons.star;
    }

    Color tierColor = Colors.brown;
    if (achievement['tier'] == 'silver') {
      tierColor = Colors.grey;
    } else if (achievement['tier'] == 'gold') {
      tierColor = Colors.amber;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: tierColor,
        child: Icon(iconData, color: Colors.white),
      ),
      title: Text(achievement['name'] ?? 'Achievement'),
      subtitle: Text(achievement['description'] ?? ''),
    );
  }
}
