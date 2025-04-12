class LeaderboardEntry {
  final String userId;
  final String name;
  final int score;
  final int rank;

  LeaderboardEntry({
    required this.userId,
    required this.name,
    required this.score,
    required this.rank,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId'],
      name: json['name'],
      score: json['score'],
      rank: json['rank'],
    );
  }
}