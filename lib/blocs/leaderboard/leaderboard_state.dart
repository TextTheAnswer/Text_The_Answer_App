import 'package:flutter/foundation.dart';

abstract class LeaderboardState {}

class LeaderboardInitial extends LeaderboardState {}

class LeaderboardLoading extends LeaderboardState {}

class LeaderboardLoaded extends LeaderboardState {
  final List<Map<String, dynamic>> leaderboard;
  final int userRank;
  final int userScore;
  final Map<String, dynamic> theme;
  final Map<String, dynamic>? winner;
  final DateTime lastUpdated;

  LeaderboardLoaded({
    required this.leaderboard,
    required this.userRank,
    required this.userScore,
    required this.theme,
    this.winner,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  LeaderboardLoaded copyWith({
    List<Map<String, dynamic>>? leaderboard,
    int? userRank,
    int? userScore,
    Map<String, dynamic>? theme,
    Map<String, dynamic>? winner,
    DateTime? lastUpdated,
  }) {
    return LeaderboardLoaded(
      leaderboard: leaderboard ?? this.leaderboard,
      userRank: userRank ?? this.userRank,
      userScore: userScore ?? this.userScore,
      theme: theme ?? this.theme,
      winner: winner ?? this.winner,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }
}

class LeaderboardError extends LeaderboardState {
  final String message;

  LeaderboardError({required this.message});
}