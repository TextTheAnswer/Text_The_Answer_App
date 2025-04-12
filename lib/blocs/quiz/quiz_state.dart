import '../../models/question.dart';

abstract class QuizState {}

class QuizInitial extends QuizState {}

class QuizLoading extends QuizState {}

class QuizLoaded extends QuizState {
  final List<Question> questions;
  final int questionsAnswered;
  final int correctAnswers;

  QuizLoaded({
    required this.questions,
    required this.questionsAnswered,
    required this.correctAnswers,
  });
}

class QuizAnswerSubmitted extends QuizState {
  final bool isCorrect;
  final int correctAnswer;
  final String explanation;
  final int questionsAnswered;
  final int correctAnswers;
  final int streak;

  QuizAnswerSubmitted({
    required this.isCorrect,
    required this.correctAnswer,
    required this.explanation,
    required this.questionsAnswered,
    required this.correctAnswers,
    required this.streak,
  });
}

class QuizError extends QuizState {
  final String message;

  QuizError({required this.message});
}