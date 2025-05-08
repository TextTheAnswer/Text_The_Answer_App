import '../../models/question.dart';
import '../../models/leaderboard.dart';

abstract class QuizState {}

class QuizInitial extends QuizState {}

class QuizLoading extends QuizState {}

class QuizLoaded extends QuizState {
  final List<Question> questions;
  final int questionsAnswered;
  final int correctAnswers;
  final int totalPoints;
  final Duration totalTimeElapsed;
  final Duration totalTimeRemaining;

  QuizLoaded({
    required this.questions,
    required this.questionsAnswered,
    required this.correctAnswers,
    this.totalPoints = 0,
    this.totalTimeElapsed = Duration.zero,
    this.totalTimeRemaining = const Duration(minutes: 10),
  });
}

class QuizAnswerSubmitted extends QuizState {
  final bool isCorrect;
  final String correctAnswer;
  final String explanation;
  final int questionsAnswered;
  final int correctAnswers;
  final int streak;
  final int points;
  final int totalPoints;

  QuizAnswerSubmitted({
    required this.isCorrect,
    required this.correctAnswer,
    required this.explanation,
    required this.questionsAnswered,
    required this.correctAnswers,
    required this.streak,
    required this.points,
    required this.totalPoints,
  });
}

class QuizBulkAnswersSubmitted extends QuizState {
  final List<Map<String, dynamic>> results;
  final Map<String, dynamic> summary;
  final List<Map<String, dynamic>> newAchievements;

  QuizBulkAnswersSubmitted({
    required this.results,
    required this.summary,
    this.newAchievements = const [],
  });
}

class QuizResultsState extends QuizState {
  final List<Map<String, dynamic>> results;
  final Map<String, dynamic> summary;
  final List<dynamic> leaderboard;
  final bool isWinner;
  final bool premiumAwarded;
  final int completionTime; // Total time in milliseconds

  QuizResultsState({
    required this.results,
    required this.summary,
    required this.leaderboard,
    this.isWinner = false,
    this.premiumAwarded = false,
    this.completionTime = 0,
  });
}

class QuizError extends QuizState {
  final String message;

  QuizError({required this.message});
}