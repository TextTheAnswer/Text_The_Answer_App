import '../../models/question.dart';

abstract class DailyQuizState {}

class DailyQuizInitial extends DailyQuizState {}

class DailyQuizLoading extends DailyQuizState {}

class DailyQuizError extends DailyQuizState {
  final String message;
  
  DailyQuizError({required this.message});
}

class DailyQuizWaiting extends DailyQuizState {
  final String message;
  
  DailyQuizWaiting({required this.message});
}

class DailyQuizStarted extends DailyQuizState {
  final int currentQuestionIndex;
  final int totalQuestions;
  
  DailyQuizStarted({
    required this.currentQuestionIndex,
    required this.totalQuestions
  });
}

class DailyQuizQuestionActive extends DailyQuizState {
  final Question question;
  final int questionIndex;
  final int totalQuestions;
  final int timeLimit;
  final List<Map<String, dynamic>> participants;
  
  DailyQuizQuestionActive({
    required this.question,
    required this.questionIndex,
    required this.totalQuestions,
    required this.timeLimit,
    required this.participants
  });
}

class DailyQuizAnswerSubmitted extends DailyQuizState {
  final Question question;
  final int questionIndex;
  final int totalQuestions;
  final String userAnswer;
  final List<Map<String, dynamic>> participants;
  
  DailyQuizAnswerSubmitted({
    required this.question,
    required this.questionIndex,
    required this.totalQuestions,
    required this.userAnswer,
    required this.participants
  });
}

class DailyQuizQuestionResult extends DailyQuizState {
  final Question question;
  final int questionIndex;
  final int totalQuestions;
  final String userAnswer;
  final bool isCorrect;
  final String correctAnswer;
  final String explanation;
  final int points;
  final int totalPoints;
  final List<Map<String, dynamic>> participants;
  final int userRank;
  
  DailyQuizQuestionResult({
    required this.question,
    required this.questionIndex,
    required this.totalQuestions,
    required this.userAnswer,
    required this.isCorrect,
    required this.correctAnswer,
    required this.explanation,
    required this.points,
    required this.totalPoints,
    required this.participants,
    required this.userRank
  });
  
  DailyQuizQuestionResult copyWith({
    Question? question,
    int? questionIndex,
    int? totalQuestions,
    String? userAnswer,
    bool? isCorrect,
    String? correctAnswer,
    String? explanation,
    int? points,
    int? totalPoints,
    List<Map<String, dynamic>>? participants,
    int? userRank
  }) {
    return DailyQuizQuestionResult(
      question: question ?? this.question,
      questionIndex: questionIndex ?? this.questionIndex,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      userAnswer: userAnswer ?? this.userAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
      points: points ?? this.points,
      totalPoints: totalPoints ?? this.totalPoints,
      participants: participants ?? this.participants,
      userRank: userRank ?? this.userRank
    );
  }
}

class DailyQuizCompleted extends DailyQuizState {
  final int totalQuestions;
  final int correctAnswers;
  final int totalPoints;
  final List<Map<String, dynamic>> participants;
  final int userRank;
  final Map<String, dynamic>? winner;
  
  DailyQuizCompleted({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.totalPoints,
    required this.participants,
    required this.userRank,
    this.winner
  });
} 