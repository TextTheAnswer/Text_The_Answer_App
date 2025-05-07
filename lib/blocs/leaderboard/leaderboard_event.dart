abstract class LeaderboardEvent {}

class FetchDailyLeaderboard extends LeaderboardEvent {}

class RefreshLeaderboard extends LeaderboardEvent {}

class SubscribeToLeaderboardUpdates extends LeaderboardEvent {
  final String gameId;
  
  SubscribeToLeaderboardUpdates({required this.gameId});
}

class UnsubscribeFromLeaderboardUpdates extends LeaderboardEvent {}

class FetchGameLeaderboard extends LeaderboardEvent {
  final String gameId;

  FetchGameLeaderboard({required this.gameId});
}