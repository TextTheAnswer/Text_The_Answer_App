class LeaderboardEntry {
  final String id;
  final String name;
  final int score;
  final bool isUser;
  final int totalTime; // Time in milliseconds

  LeaderboardEntry({
    required this.id,
    required this.name,
    required this.score,
    this.isUser = false,
    this.totalTime = 0,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      id: json['id'] ?? json['userId'] ?? '',
      name: json['name'] ?? 'Unknown User',
      score: json['score'] ?? 0,
      isUser: json['isUser'] ?? false,
      totalTime: json['totalTime'] ?? json['completionTime'] ?? 0,
    );
  }
}