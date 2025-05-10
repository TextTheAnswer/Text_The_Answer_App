class ProfilePreferences {
  final List<String> favoriteCategories;
  final Map<String, dynamic> notificationSettings;
  final String displayTheme;

  ProfilePreferences({
    required this.favoriteCategories,
    required this.notificationSettings,
    required this.displayTheme,
  });

  factory ProfilePreferences.fromJson(Map<String, dynamic> json) {
    return ProfilePreferences(
      favoriteCategories: List<String>.from(json['favoriteCategories'] ?? []),
      notificationSettings: json['notificationSettings'] as Map<String, dynamic>? ?? {},
      displayTheme: json['displayTheme'] as String? ?? 'light',
    );
  }
}

class ProfileInfo {
  final String bio;
  final String location;
  final String imageUrl;
  final ProfilePreferences preferences;

  ProfileInfo({
    required this.bio,
    required this.location,
    required this.imageUrl,
    required this.preferences,
  });

  factory ProfileInfo.fromJson(Map<String, dynamic> json) {
    return ProfileInfo(
      bio: json['bio'] as String? ?? '',
      location: json['location'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      preferences: ProfilePreferences.fromJson(json['preferences'] ?? {}),
    );
  }
}

class SubscriptionInfo {
  final String status;
  final String currentPeriodEnd;
  final bool cancelAtPeriodEnd;

  SubscriptionInfo({
    required this.status,
    required this.currentPeriodEnd,
    required this.cancelAtPeriodEnd,
  });

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) {
    return SubscriptionInfo(
      status: json['status'] as String? ?? 'free',
      currentPeriodEnd: json['currentPeriodEnd'] as String? ?? '',
      cancelAtPeriodEnd: json['cancelAtPeriodEnd'] as bool? ?? false,
    );
  }
}

class UserStats {
  final int streak;
  final String lastPlayed;
  final int totalCorrect;
  final int totalAnswered;
  final String accuracy;

  UserStats({
    required this.streak,
    required this.lastPlayed,
    required this.totalCorrect,
    required this.totalAnswered,
    required this.accuracy,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      streak: json['streak'] as int? ?? 0,
      lastPlayed: json['lastPlayed'] as String? ?? '',
      totalCorrect: json['totalCorrect'] as int? ?? 0,
      totalAnswered: json['totalAnswered'] as int? ?? 0,
      accuracy: json['accuracy'] as String? ?? '0%',
    );
  }
}

class EducationInfo {
  final Map<String, dynamic> data;

  EducationInfo({required this.data});

  factory EducationInfo.fromJson(Map<String, dynamic> json) {
    return EducationInfo(data: json ?? {});
  }
}

class ProfileData {
  final String id;
  final String email;
  final String name;
  final ProfileInfo profile;
  final SubscriptionInfo subscription;
  final UserStats stats;
  final Map<String, dynamic> dailyQuiz;
  final bool isPremium;
  final bool isEducation;
  final EducationInfo education;

  ProfileData({
    required this.id,
    required this.email,
    required this.name,
    required this.profile,
    required this.subscription,
    required this.stats,
    required this.dailyQuiz,
    required this.isPremium,
    required this.isEducation,
    required this.education,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      profile: ProfileInfo.fromJson(json['profile'] ?? {}),
      subscription: SubscriptionInfo.fromJson(json['subscription'] ?? {}),
      stats: UserStats.fromJson(json['stats'] ?? {}),
      dailyQuiz: json['dailyQuiz'] as Map<String, dynamic>? ?? {},
      isPremium: json['isPremium'] as bool? ?? false,
      isEducation: json['isEducation'] as bool? ?? false,
      education: EducationInfo.fromJson(json['education'] ?? {}),
    );
  }
} 