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