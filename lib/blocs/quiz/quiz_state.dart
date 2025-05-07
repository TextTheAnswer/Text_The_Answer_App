import '../../models/question.dart';

abstract class QuizState {}

class QuizInitial extends QuizState {}

class QuizLoading extends QuizState {}

class QuizLoaded extends QuizState {
  final List<Question> questions;
  final int questionsAnswered;
  final int correctAnswers;
  final int totalPoints;

  QuizLoaded({
    required this.questions,
    required this.questionsAnswered,
    required this.correctAnswers,
    this.totalPoints = 0,
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

class QuizError extends QuizState {
  final String message;

  QuizError({required this.message});
}