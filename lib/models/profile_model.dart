class Profile {
  final String? id;
  final String? bio;
  final String? location;
  final String? imageUrl;
  final String? imagePublicId;
  final ProfilePreferences? preferences;

  Profile({
    this.id,
    this.bio,
    this.location,
    this.imageUrl,
    this.imagePublicId,
    this.preferences,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    print('Profile.fromJson: Parsing data with keys - ${json.keys.toList()}');
    
    return Profile(
      id: json['id'] ?? json['_id'] ?? json['profileId'],
      bio: json['bio'],
      location: json['location'],
      imageUrl: json['imageUrl'] ?? json['avatarUrl'] ?? json['image'],
      imagePublicId: json['imagePublicId'] ?? json['imageId'],
      preferences: json['preferences'] != null 
          ? ProfilePreferences.fromJson(json['preferences']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (bio != null) data['bio'] = bio;
    if (location != null) data['location'] = location;
    if (imageUrl != null) data['imageUrl'] = imageUrl;
    if (imagePublicId != null) data['imagePublicId'] = imagePublicId;
    if (preferences != null) data['preferences'] = preferences!.toJson();
    return data;
  }
}

class ProfilePreferences {
  final List<String>? favoriteCategories;
  final NotificationSettings? notificationSettings;
  final String? displayTheme;

  ProfilePreferences({
    this.favoriteCategories,
    this.notificationSettings,
    this.displayTheme,
  });

  factory ProfilePreferences.fromJson(Map<String, dynamic> json) {
    return ProfilePreferences(
      favoriteCategories: json['favoriteCategories'] != null 
          ? List<String>.from(json['favoriteCategories']) 
          : null,
      notificationSettings: json['notificationSettings'] != null 
          ? NotificationSettings.fromJson(json['notificationSettings']) 
          : null,
      displayTheme: json['displayTheme'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (favoriteCategories != null) data['favoriteCategories'] = favoriteCategories;
    if (notificationSettings != null) data['notificationSettings'] = notificationSettings!.toJson();
    if (displayTheme != null) data['displayTheme'] = displayTheme;
    return data;
  }
}

class NotificationSettings {
  final bool? dailyQuizReminder;
  final bool? multiplayerInvites;

  NotificationSettings({
    this.dailyQuizReminder,
    this.multiplayerInvites,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      dailyQuizReminder: json['dailyQuizReminder'],
      multiplayerInvites: json['multiplayerInvites'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (dailyQuizReminder != null) 'dailyQuizReminder': dailyQuizReminder,
      if (multiplayerInvites != null) 'multiplayerInvites': multiplayerInvites,
    };
  }
}

class ProfileResponse {
  final bool success;
  final String message;
  final Profile? profile;

  ProfileResponse({
    required this.success,
    required this.message,
    this.profile,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    print('ProfileResponse.fromJson: Parsing data with keys - ${json.keys.toList()}');
    
    // Look for profile in different possible locations
    Profile? profileData;
    
    // Case 1: Standard profile location
    if (json.containsKey('profile') && json['profile'] != null) {
      try {
        profileData = Profile.fromJson(json['profile']);
        print('ProfileResponse: Found profile in standard location');
      } catch (e) {
        print('ProfileResponse: Error parsing profile in standard location: $e');
      }
    }
    
    // Case 2: Profile might be in data
    if (profileData == null && json.containsKey('data') && json['data'] != null) {
      try {
        if (json['data'] is Map<String, dynamic>) {
          if (json['data'].containsKey('profile')) {
            profileData = Profile.fromJson(json['data']['profile']);
            print('ProfileResponse: Found profile in data.profile');
          } else {
            // Data itself might be the profile if it has profile-like fields
            final data = json['data'] as Map<String, dynamic>;
            if (data.containsKey('bio') || data.containsKey('location') || 
                data.containsKey('imageUrl') || data.containsKey('id')) {
              profileData = Profile.fromJson(data);
              print('ProfileResponse: Using data as profile');
            }
          }
        }
      } catch (e) {
        print('ProfileResponse: Error parsing profile in data: $e');
      }
    }
    
    // Case 3: Profile might be in user object
    if (profileData == null && json.containsKey('user') && json['user'] != null) {
      try {
        final user = json['user'] as Map<String, dynamic>;
        if (user.containsKey('profile')) {
          profileData = Profile.fromJson(user['profile']);
          print('ProfileResponse: Found profile in user.profile');
        }
      } catch (e) {
        print('ProfileResponse: Error parsing user.profile: $e');
      }
    }
    
    // Case 4: Root object might be the profile
    if (profileData == null && 
        (json.containsKey('bio') || json.containsKey('location') || 
         json.containsKey('imageUrl') || json.containsKey('id'))) {
      try {
        profileData = Profile.fromJson(json);
        print('ProfileResponse: Using root object as profile');
      } catch (e) {
        print('ProfileResponse: Error parsing root as profile: $e');
      }
    }
    
    return ProfileResponse(
      success: json['success'] ?? profileData != null,
      message: json['message'] ?? (profileData == null ? 'No profile data found in response' : 'Profile retrieved successfully'),
      profile: profileData,
    );
  }
} 