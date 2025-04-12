abstract class LeaderboardEvent {}

class FetchDailyLeaderboard extends LeaderboardEvent {}

class FetchGameLeaderboard extends LeaderboardEvent {
  final String gameId;

  FetchGameLeaderboard({required this.gameId});
}