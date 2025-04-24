import '../../models/lobby.dart';
import '../../models/question.dart';

abstract class GameState {}

class GameInitial extends GameState {}

class GameLoading extends GameState {}

class LobbyCreated extends GameState {
  final Lobby lobby;

  LobbyCreated({required this.lobby});
}

class PublicLobbiesLoaded extends GameState {
  final List<Map<String, dynamic>> lobbies;

  PublicLobbiesLoaded({required this.lobbies});
}

class LobbyJoined extends GameState {
  final Lobby lobby;

  LobbyJoined({required this.lobby});
}

class LobbyLeft extends GameState {}

// Real-time update states
class LobbyUpdated extends GameState {
  final Lobby lobby;

  LobbyUpdated({required this.lobby});
}

class AllPlayersReady extends GameState {}

class GameStarted extends GameState {
  final String gameId;
  final List<Question> questions;
  final List<dynamic> players;

  GameStarted({
    required this.gameId,
    required this.questions,
    required this.players,
  });
}

class GameAnswerSubmitted extends GameState {
  final bool isCorrect;
  final int correctAnswer;
  final int score;
  final int totalScore;
  final bool allAnswered;

  GameAnswerSubmitted({
    required this.isCorrect,
    required this.correctAnswer,
    required this.score,
    required this.totalScore,
    required this.allAnswered,
  });
}

class GameResultsLoaded extends GameState {
  final Map<String, dynamic> results;

  GameResultsLoaded({required this.results});
}

class GameError extends GameState {
  final String message;

  GameError({required this.message});
}