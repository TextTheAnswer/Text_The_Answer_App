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
    return Lobby(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      isPublic: json['isPublic'],
      host: json['host'],
      players: List<Map<String, dynamic>>.from(json['players']),
      maxPlayers: json['maxPlayers'],
      status: json['status'],
    );
  }
}