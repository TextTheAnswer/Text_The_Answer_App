class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String tier;
  final bool isHidden;
  final AchievementCriteria? criteria;
  final DateTime? unlockedAt;
  final bool viewed;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.tier,
    this.isHidden = false,
    this.criteria,
    this.unlockedAt,
    this.viewed = false,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    DateTime? unlockedDate;
    if (json['unlockedAt'] != null) {
      try {
        // Try to parse the date string
        unlockedDate = DateTime.parse(json['unlockedAt']);
      } catch (e) {
        // If parsing fails, try to handle common format issues
        try {
          // Handle format like "2023-11-7" by ensuring day is padded with leading zero
          final parts = json['unlockedAt'].toString().split('-');
          if (parts.length == 3) {
            final year = parts[0];
            final month = parts[1].padLeft(2, '0');
            final day = parts[2].padLeft(2, '0');
            unlockedDate = DateTime.parse('$year-$month-$day');
          }
        } catch (e) {
          // If all parsing attempts fail, leave as null and log the error
          print('Error parsing date: ${json['unlockedAt']} - $e');
        }
      }
    }
    
    return Achievement(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '🏆',
      tier: json['tier'] ?? 'bronze',
      isHidden: json['isHidden'] ?? false,
      criteria: json['criteria'] != null 
          ? AchievementCriteria.fromJson(json['criteria'])
          : null,
      unlockedAt: unlockedDate,
      viewed: json['viewed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'tier': tier,
      'isHidden': isHidden,
      'viewed': viewed,
    };
    
    if (criteria != null) {
      data['criteria'] = criteria!.toJson();
    }
    
    if (unlockedAt != null) {
      data['unlockedAt'] = unlockedAt!.toIso8601String();
    }
    
    return data;
  }

  // Helper method to get an emoji based on icon string
  String get emojiIcon {
    final emojiMap = {
      'star': '⭐',
      'trophy': '🏆',
      'medal': '🥇',
      'fire': '🔥',
      'lightning': '⚡',
      'brain': '🧠',
      'rocket': '🚀',
      'check': '✅',
      'crown': '👑',
      'gem': '💎',
      'books': '📚',
      'calendar': '📅',
      'target': '🎯',
      'gift': '🎁',
      'heart': '❤️',
      'clock': '⏰',
      'lamp': '💡',
    };

    return emojiMap[icon.toLowerCase()] ?? '🏆';
  }

  // Helper method to get color based on tier
  String get tierColor {
    switch (tier.toLowerCase()) {
      case 'bronze': return '#CD7F32';
      case 'silver': return '#C0C0C0';
      case 'gold': return '#FFD700';
      case 'platinum': return '#E5E4E2';
      default: return '#CD7F32';
    }
  }
}

class AchievementCriteria {
  final String type;
  final int value;

  AchievementCriteria({
    required this.type,
    required this.value,
  });

  factory AchievementCriteria.fromJson(Map<String, dynamic> json) {
    return AchievementCriteria(
      type: json['type'] ?? '',
      value: json['value'] is int ? json['value'] : int.tryParse(json['value'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'value': value,
    };
  }
} 