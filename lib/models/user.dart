class User {
  final String id;
  final String email;
  final String name;
  final String subscription;
  final bool isPremium;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.subscription,
    required this.isPremium,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '', // Ensure id is a string, provide default if null
      email: json['email']?.toString() ?? '', // Ensure email is a string, provide default if null
      name: json['name']?.toString() ?? '', // Ensure name is a string, provide default if null
      subscription: json['subscription']?.toString() ?? 'free', // Default to 'free' if null
      isPremium: json['isPremium'] as bool? ?? false, // Default to false if null
    );
  }
}