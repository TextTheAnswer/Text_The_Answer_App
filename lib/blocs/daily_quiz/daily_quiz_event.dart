import '../../models/question.dart';

abstract class DailyQuizEvent {}

class JoinDailyQuiz extends DailyQuizEvent {}

class LeaveDailyQuiz extends DailyQuizEvent {}

class StartDailyQuiz extends DailyQuizEvent {
  final int totalQuestions;
  
  StartDailyQuiz({required this.totalQuestions});
}

class ReceiveQuestion extends DailyQuizEvent {
  final Question question;
  final int questionIndex;
  final int totalQuestions;
  final int timeLimit;
  final List<Map<String, dynamic>> participants;
  
  ReceiveQuestion({
    required this.question,
    required this.questionIndex,
    required this.totalQuestions,
    required this.timeLimit,
    required this.participants
  });
}

class SubmitDailyQuizAnswer extends DailyQuizEvent {
  final String answer;
  final int timeRemaining;
  
  SubmitDailyQuizAnswer({
    required this.answer,
    required this.timeRemaining
  });
}

class ReceiveAnswerResult extends DailyQuizEvent {
  final bool isCorrect;
  final String correctAnswer;
  final String explanation;
  final int points;
  final int totalPoints;
  final List<Map<String, dynamic>> participants;
  final int userRank;
  
  ReceiveAnswerResult({
    required this.isCorrect,
    required this.correctAnswer,
    required this.explanation,
    required this.points,
    required this.totalPoints,
    required this.participants,
    required this.userRank
  });
}

class UpdateLeaderboard extends DailyQuizEvent {
  final List<Map<String, dynamic>> participants;
  final int userRank;
  
  UpdateLeaderboard({
    required this.participants,
    required this.userRank
  });
}

class QuizEnded extends DailyQuizEvent {
  final int totalQuestions;
  final int correctAnswers;
  final int totalPoints;
  final List<Map<String, dynamic>> participants;
  final int userRank;
  final Map<String, dynamic>? winner;
  
  QuizEnded({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.totalPoints,
    required this.participants,
    required this.userRank,
    this.winner
  });
}

class SocketError extends DailyQuizEvent {
  final String message;
  
  SocketError({required this.message});
} 