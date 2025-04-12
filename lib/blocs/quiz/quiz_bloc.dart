import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/api_service.dart';
import 'quiz_event.dart';
import 'quiz_state.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final ApiService _apiService = ApiService();

  QuizBloc() : super(QuizInitial()) {
    on<FetchDailyQuiz>((event, emit) async {
      emit(QuizLoading());
      try {
        final response = await _apiService.getDailyQuiz();
        emit(QuizLoaded(
          questions: response['questions'],
          questionsAnswered: response['questionsAnswered'],
          correctAnswers: response['correctAnswers'],
        ));
      } catch (e) {
        print('QuizBloc Error (FetchDailyQuiz): $e'); // Debug statement
        emit(QuizError(message: e.toString()));
      }
    });

    on<SubmitQuizAnswer>((event, emit) async {
      emit(QuizLoading());
      try {
        final response = await _apiService.submitDailyQuizAnswer(
            event.questionId, event.answer);
        emit(QuizAnswerSubmitted(
          isCorrect: response['isCorrect'],
          correctAnswer: response['correctAnswer'],
          explanation: response['explanation'],
          questionsAnswered: response['questionsAnswered'],
          correctAnswers: response['correctAnswers'],
          streak: response['streak'],
        ));
      } catch (e) {
        print('QuizBloc Error (SubmitQuizAnswer): $e'); // Debug statement
        emit(QuizError(message: e.toString()));
      }
    });
  }
}