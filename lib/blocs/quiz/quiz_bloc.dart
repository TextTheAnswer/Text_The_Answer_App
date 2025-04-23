import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter/widgets.dart';
import '../../services/api_service.dart';
import 'quiz_event.dart';
import 'quiz_state.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final ApiService _apiService;

  QuizBloc({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService(),
        super(QuizInitial()) {
    on<FetchDailyQuiz>((event, emit) async {
      emit(QuizLoading());
      try {
        print('QuizBloc: Fetching daily quiz...');
        final response = await _apiService.getDailyQuiz();
        
        // Log the response structure for debugging
        print('QuizBloc: Response received with ${response['questions']?.length ?? 0} questions');
        
        emit(QuizLoaded(
          questions: response['questions'] ?? [],
          questionsAnswered: response['questionsAnswered'] ?? 0,
          correctAnswers: response['correctAnswers'] ?? 0,
        ));
      } catch (e) {
        print('QuizBloc Error (FetchDailyQuiz): $e'); // Debug statement
        emit(QuizError(message: 'Failed to load quiz: ${e.toString()}'));
      }
    });

    on<SubmitQuizAnswer>((event, emit) async {
      emit(QuizLoading());
      try {
        print('QuizBloc: Submitting answer for question ${event.questionId}');
        final response = await _apiService.submitDailyQuizAnswer(
            event.questionId, event.answer);
        
        // Log response for debugging
        print('QuizBloc: Answer submission response received');
        
        emit(QuizAnswerSubmitted(
          isCorrect: response['isCorrect'] ?? false,
          correctAnswer: response['correctAnswer'] ?? 0,
          explanation: response['explanation'] ?? 'No explanation available',
          questionsAnswered: response['questionsAnswered'] ?? 0,
          correctAnswers: response['correctAnswers'] ?? 0,
          streak: response['streak'] ?? 0,
        ));
      } catch (e) {
        print('QuizBloc Error (SubmitQuizAnswer): $e'); // Debug statement
        emit(QuizError(message: 'Failed to submit answer: ${e.toString()}'));
      }
    });
  }
  
  // Factory constructor to create a QuizBloc from BuildContext
  factory QuizBloc.fromContext(BuildContext context) {
    return QuizBloc(
      apiService: Provider.of<ApiService>(context, listen: false),
    );
  }
}