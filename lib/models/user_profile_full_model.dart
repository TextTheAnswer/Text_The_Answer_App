import 'package:text_the_answer/models/profile_model.dart';

class ProfileResponse {
  final bool success;
  final ProfileData? profile;
  final String? message;

  ProfileResponse({
    required this.success,
    this.profile,
    this.message,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      success: json['success'] ?? false,
      profile: json['profile'] != null ? ProfileData.fromJson(json['profile']) : null,
      message: json['message'],
    );
  }
}

class ProfileData {
  final String id;
  final String email;
  final String name;
  final ProfileDetails? profile;
  final SubscriptionData subscription;
  final StatsData stats;
  final DailyQuizData dailyQuiz;
  final bool isPremium;
  final bool isEducation;
  final EducationData? education;
  final List<Achievement>? achievements;

  ProfileData({
    required this.id,
    required this.email,
    required this.name,
    this.profile,
    required this.subscription,
    required this.stats,
    required this.dailyQuiz,
    required this.isPremium,
    required this.isEducation,
    this.education,
    this.achievements,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      profile: json['profile'] != null ? ProfileDetails.fromJson(json['profile']) : null,
      subscription: SubscriptionData.fromJson(json['subscription'] ?? {}),
      stats: StatsData.fromJson(json['stats'] ?? {}),
      dailyQuiz: DailyQuizData.fromJson(json['dailyQuiz'] ?? {}),
      isPremium: json['isPremium'] ?? false,
      isEducation: json['isEducation'] ?? false,
      education: json['education'] != null ? EducationData.fromJson(json['education']) : null,
      achievements: json['achievements'] != null 
          ? List<Achievement>.from(json['achievements'].map((a) => Achievement.fromJson(a)))
          : null,
    );
  }
}

class ProfileDetails {
  final String? bio;
  final String? location;
  final String? imageUrl;
  final Preferences? preferences;

  ProfileDetails({
    this.bio,
    this.location,
    this.imageUrl,
    this.preferences,
  });

  factory ProfileDetails.fromJson(Map<String, dynamic> json) {
    return ProfileDetails(
      bio: json['bio'],
      location: json['location'],
      imageUrl: json['imageUrl'],
      preferences: json['preferences'] != null ? Preferences.fromJson(json['preferences']) : null,
    );
  }
}

class Preferences {
  final List<String>? favoriteCategories;
  final Map<String, dynamic>? notificationSettings;
  final String? displayTheme;

  Preferences({
    this.favoriteCategories,
    this.notificationSettings,
    this.displayTheme,
  });

  factory Preferences.fromJson(Map<String, dynamic> json) {
    return Preferences(
      favoriteCategories: json['favoriteCategories'] != null 
          ? List<String>.from(json['favoriteCategories'])
          : null,
      notificationSettings: json['notificationSettings'],
      displayTheme: json['displayTheme'],
    );
  }
}

class SubscriptionData {
  final String status;
  final String? currentPeriodEnd;
  final bool cancelAtPeriodEnd;

  SubscriptionData({
    required this.status,
    this.currentPeriodEnd,
    required this.cancelAtPeriodEnd,
  });

  factory SubscriptionData.fromJson(Map<String, dynamic> json) {
    return SubscriptionData(
      status: json['status'] ?? 'free',
      currentPeriodEnd: json['currentPeriodEnd'],
      cancelAtPeriodEnd: json['cancelAtPeriodEnd'] ?? false,
    );
  }
}

class StatsData {
  final int streak;
  final String? lastPlayed;
  final int totalCorrect;
  final int totalAnswered;
  final String accuracy;

  StatsData({
    required this.streak,
    this.lastPlayed,
    required this.totalCorrect,
    required this.totalAnswered,
    required this.accuracy,
  });

  factory StatsData.fromJson(Map<String, dynamic> json) {
    return StatsData(
      streak: json['streak'] ?? 0,
      lastPlayed: json['lastPlayed'],
      totalCorrect: json['totalCorrect'] ?? 0,
      totalAnswered: json['totalAnswered'] ?? 0,
      accuracy: json['accuracy'] ?? '0%',
    );
  }
}

class DailyQuizData {
  final String? lastCompleted;
  final int questionsAnswered;
  final int correctAnswers;
  final int score;

  DailyQuizData({
    this.lastCompleted,
    required this.questionsAnswered,
    required this.correctAnswers,
    required this.score,
  });

  factory DailyQuizData.fromJson(Map<String, dynamic> json) {
    return DailyQuizData(
      lastCompleted: json['lastCompleted'],
      questionsAnswered: json['questionsAnswered'] ?? 0,
      correctAnswers: json['correctAnswers'] ?? 0,
      score: json['score'] ?? 0,
    );
  }
}

class EducationData {
  final bool isStudent;
  final String? studentEmail;
  final int? yearOfStudy;
  final String? verificationStatus;

  EducationData({
    required this.isStudent,
    this.studentEmail,
    this.yearOfStudy,
    this.verificationStatus,
  });

  factory EducationData.fromJson(Map<String, dynamic> json) {
    return EducationData(
      isStudent: json['isStudent'] ?? false,
      studentEmail: json['studentEmail'],
      yearOfStudy: json['yearOfStudy'],
      verificationStatus: json['verificationStatus'],
    );
  }
}

class Achievement {
  final String achievementId;
  final String unlockedAt;
  final bool viewed;

  Achievement({
    required this.achievementId,
    required this.unlockedAt,
    required this.viewed,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      achievementId: json['achievementId'] ?? '',
      unlockedAt: json['unlockedAt'] ?? '',
      viewed: json['viewed'] ?? false,
    );
  }
} 