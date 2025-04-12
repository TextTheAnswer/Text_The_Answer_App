import '../../models/leaderboard.dart';

abstract class LeaderboardState {}

class LeaderboardInitial extends LeaderboardState {}

class LeaderboardLoading extends LeaderboardState {}

class LeaderboardLoaded extends LeaderboardState {
  final List<LeaderboardEntry> leaderboard;
  final int userRank;

  LeaderboardLoaded({required this.leaderboard, required this.userRank});
}

class LeaderboardError extends LeaderboardState {
  final String message;

  LeaderboardError({required this.message});
}