class Lobby {
  final String id;
  final String name;
  final String code;
  final bool isPublic;
  final String host;
  final List<Map<String, dynamic>> players;
  final int maxPlayers;
  final String status;

  Lobby({
    required this.id,
    required this.name,
    required this.code,
    required this.isPublic,
    required this.host,
    required this.players,
    required this.maxPlayers,
    required this.status,
  });

  factory Lobby.fromJson(Map<String, dynamic> json) {
    // Handle potential null maps by defaulting to empty map
    json = json ?? {};
    
    // Ensure ID is a string
    String id = '';
    if (json['id'] != null) {
      id = json['id'].toString();
    }
    
    // Ensure players is properly parsed
    List<Map<String, dynamic>> players = [];
    if (json['players'] != null) {
      try {
        players = List<Map<String, dynamic>>.from(
          (json['players'] as List).map((player) => 
            player is Map ? Map<String, dynamic>.from(player) : {}
          )
        );
      } catch (e) {
        print('Error parsing players: $e');
        // Fallback to empty list if parsing fails
      }
    }
    
    return Lobby(
      id: id,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      isPublic: json['isPublic'] == true,
      host: json['host']?.toString() ?? '',
      players: players,
      maxPlayers: json['maxPlayers'] is int ? json['maxPlayers'] : 4,
      status: json['status']?.toString() ?? '',
    );
  }
}