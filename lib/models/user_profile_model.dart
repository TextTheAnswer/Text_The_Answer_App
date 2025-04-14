import 'package:text_the_answer/models/profile_model.dart';

class UserProfileFull {
  final String id;
  final String email;
  final String name;
  final Profile profile;
  final Subscription subscription;
  final UserStats stats;
  final bool isPremium;
  final bool isEducation;

  UserProfileFull({
    required this.id,
    required this.email,
    required this.name,
    required this.profile,
    required this.subscription,
    required this.stats,
    required this.isPremium,
    required this.isEducation,
  });

  factory UserProfileFull.fromJson(Map<String, dynamic> json) {
    return UserProfileFull(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      profile: json['profile'] != null 
          ? Profile.fromJson(json['profile']) 
          : Profile(),
      subscription: json['subscription'] != null 
          ? Subscription.fromJson(json['subscription']) 
          : Subscription(),
      stats: json['stats'] != null 
          ? UserStats.fromJson(json['stats']) 
          : UserStats(),
      isPremium: json['isPremium'] ?? false,
      isEducation: json['isEducation'] ?? false,
    );
  }
}

class Subscription {
  final String status;
  final DateTime? currentPeriodEnd;
  final bool cancelAtPeriodEnd;

  Subscription({
    this.status = 'free',
    this.currentPeriodEnd,
    this.cancelAtPeriodEnd = false,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      status: json['status'] ?? 'free',
      currentPeriodEnd: json['currentPeriodEnd'] != null 
          ? DateTime.parse(json['currentPeriodEnd']) 
          : null,
      cancelAtPeriodEnd: json['cancelAtPeriodEnd'] ?? false,
    );
  }
}

class UserStats {
  final int streak;
  final DateTime? lastPlayed;
  final int totalCorrect;
  final int totalAnswered;
  final String accuracy;

  UserStats({
    this.streak = 0,
    this.lastPlayed,
    this.totalCorrect = 0,
    this.totalAnswered = 0,
    this.accuracy = '0%',
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      streak: json['streak'] ?? 0,
      lastPlayed: json['lastPlayed'] != null 
          ? DateTime.parse(json['lastPlayed']) 
          : null,
      totalCorrect: json['totalCorrect'] ?? 0,
      totalAnswered: json['totalAnswered'] ?? 0,
      accuracy: json['accuracy'] ?? '0%',
    );
  }
}

class ProfileFullResponse {
  final bool success;
  final UserProfileFull? profile;
  final String? message;

  ProfileFullResponse({
    required this.success,
    this.profile,
    this.message,
  });

  factory ProfileFullResponse.fromJson(Map<String, dynamic> json) {
    return ProfileFullResponse(
      success: json['success'] ?? false,
      profile: json['profile'] != null 
          ? UserProfileFull.fromJson(json['profile']) 
          : null,
      message: json['message'],
    );
  }
} 