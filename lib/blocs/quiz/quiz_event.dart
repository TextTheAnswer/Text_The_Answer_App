abstract class QuizEvent {}

class FetchDailyQuiz extends QuizEvent {}

class SubmitQuizAnswer extends QuizEvent {
  final String questionId;
  final int answer;

  SubmitQuizAnswer({required this.questionId, required this.answer});
}