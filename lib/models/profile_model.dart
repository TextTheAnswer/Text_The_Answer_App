class Profile {
  final String? id;
  final String? bio;
  final String? location;
  final String? imageUrl;
  final ProfilePreferences? preferences;

  Profile({
    this.id,
    this.bio,
    this.location,
    this.imageUrl,
    this.preferences,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      bio: json['bio'],
      location: json['location'],
      imageUrl: json['imageUrl'],
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
  final bool? email;
  final bool? push;

  NotificationSettings({
    this.email,
    this.push,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      email: json['email'],
      push: json['push'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (email != null) 'email': email,
      if (push != null) 'push': push,
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
    return ProfileResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      profile: json['profile'] != null ? Profile.fromJson(json['profile']) : null,
    );
  }
} 