abstract class ProfileEvent {}

class FetchProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final String? name;
  final String? bio;
  final String? location;
  final String? imageUrl;
  final List<String>? favoriteCategories;
  final Map<String, dynamic>? notificationSettings;
  final String? displayTheme;

  UpdateProfileEvent({
    this.name,
    this.bio,
    this.location,
    this.imageUrl,
    this.favoriteCategories,
    this.notificationSettings,
    this.displayTheme,
  });
}

class CreateProfileEvent extends ProfileEvent {
  final String bio;
  final String location;
  final String profilePicture;
  final List<String> favoriteCategories;
  final Map<String, dynamic> notificationSettings;
  final String displayTheme;

  CreateProfileEvent({
    required this.bio,
    required this.location,
    required this.profilePicture,
    required this.favoriteCategories,
    required this.notificationSettings,
    required this.displayTheme,
  });
} 