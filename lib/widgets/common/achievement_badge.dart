import 'package:flutter/material.dart';
import '../../models/achievement.dart';

class AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final double size;
  final bool showTooltip;
  final VoidCallback? onTap;
  final bool isUnlocked;
  final bool isNew;

  const AchievementBadge({
    Key? key,
    required this.achievement,
    this.size = 60.0,
    this.showTooltip = true,
    this.onTap,
    this.isUnlocked = true,
    this.isNew = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget badge = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isUnlocked 
            ? Color(int.parse(achievement.tierColor.substring(1), radix: 16) | 0xFF000000).withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        border: Border.all(
          color: isUnlocked 
              ? Color(int.parse(achievement.tierColor.substring(1), radix: 16) | 0xFF000000)
              : Colors.grey,
          width: 2,
        ),
        boxShadow: isUnlocked ? [
          BoxShadow(
            color: Color(int.parse(achievement.tierColor.substring(1), radix: 16) | 0xFF000000).withOpacity(0.3),
            blurRadius: 4,
            spreadRadius: 1,
          )
        ] : null,
      ),
      child: Center(
        child: Text(
          isUnlocked ? achievement.emojiIcon : '🔒',
          style: TextStyle(fontSize: size * 0.6),
        ),
      ),
    );

    final Widget badgeWithNewIndicator = Stack(
      children: [
        badge,
        if (isNew)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
              ),
              child: const Text(
                '!',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );

    if (!showTooltip) {
      return GestureDetector(
        onTap: onTap,
        child: badgeWithNewIndicator,
      );
    }

    return Tooltip(
      message: isUnlocked 
          ? achievement.name
          : 'Locked Achievement',
      child: GestureDetector(
        onTap: onTap,
        child: badgeWithNewIndicator,
      ),
    );
  }
}

class AchievementBadgeRow extends StatelessWidget {
  final List<Achievement> achievements;
  final double badgeSize;
  final VoidCallback? onViewAll;

  const AchievementBadgeRow({
    Key? key,
    required this.achievements,
    this.badgeSize = 40.0,
    this.onViewAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const int maxDisplayCount = 5;
    
    // Show a limited number of badges
    final displayedAchievements = achievements.length > maxDisplayCount
        ? achievements.sublist(0, maxDisplayCount)
        : achievements;
    
    return Row(
      children: [
        ...displayedAchievements.map((achievement) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: AchievementBadge(
              achievement: achievement,
              size: badgeSize,
              isUnlocked: achievement.unlockedAt != null,
              isNew: achievement.unlockedAt != null && !achievement.viewed,
            ),
          );
        }).toList(),
        
        // Show a "+X more" button if there are more achievements
        if (achievements.length > maxDisplayCount)
          GestureDetector(
            onTap: onViewAll,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  '+${achievements.length - maxDisplayCount}',
                  style: TextStyle(
                    fontSize: badgeSize * 0.4,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
} 