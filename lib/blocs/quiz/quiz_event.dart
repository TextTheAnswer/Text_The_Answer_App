abstract class QuizEvent {}

class FetchDailyQuiz extends QuizEvent {}

class SubmitQuizAnswer extends QuizEvent {
  final String questionId;
  final String answer;
  final int timeRemaining;

  SubmitQuizAnswer({
    required this.questionId, 
    required this.answer,
    required this.timeRemaining,
  });
}

class SubmitQuizAnswersBulk extends QuizEvent {
  final List<Map<String, dynamic>> answers;

  SubmitQuizAnswersBulk({
    required this.answers,
  });
}

class QuizTotalTimeExpired extends QuizEvent {
  final int totalQuizTimeElapsed;
  
  QuizTotalTimeExpired({
    required this.totalQuizTimeElapsed,
  });
}

class QuizCompleted extends QuizEvent {
  final List<dynamic> leaderboard;
  final bool isPremiumAwarded;
  
  QuizCompleted({
    required this.leaderboard,
    this.isPremiumAwarded = false,
  });
}