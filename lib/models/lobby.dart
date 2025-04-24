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
    // Ensure ID is a string
    var id = json['id'];
    if (id != null && id is! String) {
      id = id.toString();
    } else if (id == null) {
      id = ''; // Default empty string if missing
    }
    
    return Lobby(
      id: id,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      isPublic: json['isPublic'] ?? false,
      host: json['host'] ?? '',
      players: List<Map<String, dynamic>>.from(json['players'] ?? []),
      maxPlayers: json['maxPlayers'] ?? 4,
      status: json['status'] ?? '',
    );
  }
}