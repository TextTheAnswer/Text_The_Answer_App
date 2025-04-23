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
    // Debug the JSON structure we're trying to parse
    print('UserProfileFull.fromJson: Parsing data with keys - ${json.keys.toList()}');
    
    // If the profile is at root level (not nested), we assume the json IS the profile
    final hasNestedProfile = json.containsKey('profile');
    final profileData = hasNestedProfile ? json['profile'] : json;
    
    // Handle potentially null profile data
    final profile = json.containsKey('profile') && json['profile'] != null
        ? Profile.fromJson(json['profile'])
        : json.containsKey('bio') || json.containsKey('location') || json.containsKey('imageUrl')
            ? Profile.fromJson(json) // The JSON object itself contains profile fields
            : Profile(); // Fallback to an empty profile
            
    print('UserProfileFull.fromJson: Has nested profile? $hasNestedProfile, Using profile data: ${profile.id != null}');
    
    return UserProfileFull(
      id: json['id'] ?? json['_id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? json['displayName'] ?? '',
      profile: profile,
      subscription: json['subscription'] != null 
          ? Subscription.fromJson(json['subscription']) 
          : Subscription(status: 'inactive'),
      stats: json['stats'] != null 
          ? UserStats.fromJson(json['stats']) 
          : UserStats(),
      isPremium: json['isPremium'] ?? false,
      isEducation: json['isEducation'] ?? false,
    );
  }
}

class Subscription {
  final String? id;
  final String? customerId;
  final String? planId;
  final String status;
  final int? currentPeriodStart;
  final int? currentPeriodEnd;
  final String? interval;
  final bool cancelAtPeriodEnd;

  Subscription({
    this.id,
    this.customerId,
    this.planId,
    required this.status,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.interval,
    this.cancelAtPeriodEnd = false,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      customerId: json['customerId'],
      planId: json['planId'],
      status: json['status'] ?? 'inactive',
      currentPeriodStart: json['currentPeriodStart'],
      currentPeriodEnd: json['currentPeriodEnd'],
      interval: json['interval'],
      cancelAtPeriodEnd: json['cancelAtPeriodEnd'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'planId': planId,
      'status': status,
      'currentPeriodStart': currentPeriodStart,
      'currentPeriodEnd': currentPeriodEnd,
      'interval': interval,
      'cancelAtPeriodEnd': cancelAtPeriodEnd,
    };
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
    print('ProfileFullResponse.fromJson: Parsing data with keys - ${json.keys.toList()}');
    
    // Check different possible data structures
    UserProfileFull? profileData;
    
    // Case 1: Standard profile location
    if (json.containsKey('profile') && json['profile'] != null) {
      try {
        profileData = UserProfileFull.fromJson(json['profile']);
        print('ProfileFullResponse: Found profile in standard location');
      } catch (e) {
        print('ProfileFullResponse: Error parsing profile in standard location: $e');
      }
    }
    
    // Case 2: Profile might be in data
    if (profileData == null && json.containsKey('data') && json['data'] != null) {
      try {
        if (json['data'] is Map<String, dynamic>) {
          // Try data.profile first
          if (json['data'].containsKey('profile') && json['data']['profile'] != null) {
            profileData = UserProfileFull.fromJson(json['data']['profile']);
            print('ProfileFullResponse: Found profile in data.profile');
          } 
          // Then try data itself
          else {
            profileData = UserProfileFull.fromJson(json['data']);
            print('ProfileFullResponse: Using data as profile');
          }
        }
      } catch (e) {
        print('ProfileFullResponse: Error parsing profile in data: $e');
      }
    }
    
    // Case 3: Profile might be in user
    if (profileData == null && json.containsKey('user') && json['user'] != null) {
      try {
        profileData = UserProfileFull.fromJson(json['user']);
        print('ProfileFullResponse: Found profile in user');
      } catch (e) {
        print('ProfileFullResponse: Error parsing profile in user: $e');
      }
    }
    
    // Case 4: Root object might be the profile
    if (profileData == null && (json.containsKey('id') || json.containsKey('_id'))) {
      try {
        profileData = UserProfileFull.fromJson(json);
        print('ProfileFullResponse: Using root object as profile');
      } catch (e) {
        print('ProfileFullResponse: Error parsing root as profile: $e');
      }
    }
    
    return ProfileFullResponse(
      success: json['success'] ?? profileData != null, // If we found profile data, consider it successful
      profile: profileData,
      message: json['message'] ?? (profileData == null ? 'No profile data found in response' : null),
    );
  }
} 