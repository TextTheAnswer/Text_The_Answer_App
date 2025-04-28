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
    try {
      // Debug print to see what we received
      print('User.fromJson: Parsing data with keys - ${json.keys.toList()}');
      
      // Ensure we can handle both id and _id fields from the API
      String id = '';
      if (json.containsKey('id')) {
        id = json['id']?.toString() ?? '';
      } else if (json.containsKey('_id')) {
        id = json['_id']?.toString() ?? '';
      } else if (json.containsKey('userId')) {
        id = json['userId']?.toString() ?? '';
      }
      
      // Handle different subscription formats (string or object)
      String subscriptionStr = 'free';
      if (json['subscription'] is String) {
        subscriptionStr = json['subscription'];
      } else if (json['subscription'] is Map) {
        // If subscription is an object, get the status or type field
        final subObj = json['subscription'] as Map;
        subscriptionStr = subObj['status']?.toString() ?? subObj['type']?.toString() ?? 'free';
      }
      
      return User(
        id: id,
        email: json['email']?.toString() ?? '',
        name: json['name']?.toString() ?? json['displayName']?.toString() ?? '',
        subscription: subscriptionStr,
        isPremium: json['isPremium'] == true || subscriptionStr.toLowerCase() == 'premium',
      );
    } catch (e) {
      // Log the error and the json data
      print('Error in User.fromJson: $e');
      print('JSON data: $json');
      
      // Return a default user as a fallback
      return User(
        id: '',
        email: '',
        name: 'User',
        subscription: 'free',
        isPremium: false,
      );
    }
  }
}