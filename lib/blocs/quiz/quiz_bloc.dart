import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter/widgets.dart';
import '../../services/api_service.dart';
import '../../models/question.dart';
import '../../utils/quiz/quiz_helper.dart';
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
        
        // Use our helper to fetch and parse questions properly
        final response = await QuizHelper.fetchDailyQuiz();
        
        if (response.containsKey('error')) {
          emit(QuizError(message: response['error']));
          return;
        }
        
        final questionsList = response['questions'] as List<Question>;
        print('QuizBloc: Successfully loaded ${questionsList.length} questions');
        
        emit(QuizLoaded(
          questions: questionsList,
          questionsAnswered: response['questionsAnswered'] ?? 0,
          correctAnswers: response['correctAnswers'] ?? 0,
          totalPoints: response['totalPoints'] ?? 0,
        ));
      } catch (e) {
        print('QuizBloc Error (FetchDailyQuiz): $e'); // Debug statement
        emit(QuizError(message: 'Failed to load quiz: ${e.toString()}'));
      }
    });

    on<SubmitQuizAnswer>((event, emit) async {
      if (state is! QuizLoaded) {
        emit(QuizError(message: 'Cannot submit answer: Quiz not loaded'));
        return;
      }
      
      final currentState = state as QuizLoaded;
      final currentQuestionIndex = currentState.questionsAnswered;
      
      if (currentQuestionIndex >= currentState.questions.length) {
        emit(QuizError(message: 'No more questions to answer'));
        return;
      }
      
      final currentQuestion = currentState.questions[currentQuestionIndex];
      
      emit(QuizLoading());
      try {
        print('QuizBloc: Submitting answer "${event.answer}" for question ${event.questionId}');
        
        // Local validation of the answer for the text-based format
        final userAnswer = event.answer.trim().toLowerCase();
        final acceptedAnswers = currentQuestion.acceptedAnswers
            .map((a) => a.trim().toLowerCase())
            .toList();
        
        // Check if the answer is correct
        final isCorrect = acceptedAnswers.contains(userAnswer);
        
        // Calculate points based on time
        int points = 0;
        final difficultyMultiplier = _getDifficultyMultiplier(currentQuestion.difficulty);
        
        if (isCorrect) {
          // Base points for correct answer
          points = 100;
          
          // Time bonus: up to 100 additional points
          // Assuming 15 seconds total time
          final timeBonus = (event.timeRemaining / 15 * 100).toInt();
          points += timeBonus;
          
          // Apply difficulty multiplier
          points = (points * difficultyMultiplier).toInt();
        }
        
        print('QuizBloc: Answer is ${isCorrect ? "correct" : "incorrect"}, Points: $points');
        
        // Try to submit to API if available
        try {
          final response = await _apiService.submitDailyQuizAnswer(
              event.questionId, userAnswer, timeRemaining: event.timeRemaining);
          
          print('QuizBloc: API response received for answer submission');
          
          // If we got a response from the API, use that for official scoring
          emit(QuizAnswerSubmitted(
            isCorrect: response['isCorrect'] ?? isCorrect,
            correctAnswer: userAnswer, 
            explanation: response['explanation'] ?? 
                (isCorrect ? 'Correct!' : 'The correct answer was: ${acceptedAnswers.first}'),
            questionsAnswered: response['questionsAnswered'] ?? (currentState.questionsAnswered + 1),
            correctAnswers: response['correctAnswers'] ?? 
                (isCorrect ? currentState.correctAnswers + 1 : currentState.correctAnswers),
            streak: response['streak'] ?? 0,
            points: response['points'] ?? points,
            totalPoints: response['totalPoints'] ?? 
                (isCorrect ? currentState.totalPoints + points : currentState.totalPoints),
          ));
        } catch (apiError) {
          print('QuizBloc: API error submitting answer: $apiError, using local validation');
          
          // Fallback to local validation if API fails
          emit(QuizAnswerSubmitted(
            isCorrect: isCorrect,
            correctAnswer: userAnswer,
            explanation: isCorrect ? 'Correct!' : 'The correct answer was: ${acceptedAnswers.first}',
            questionsAnswered: currentState.questionsAnswered + 1,
            correctAnswers: isCorrect ? currentState.correctAnswers + 1 : currentState.correctAnswers,
            streak: isCorrect ? (currentState is QuizAnswerSubmitted ? (currentState as QuizAnswerSubmitted).streak + 1 : 1) : 0,
            points: points,
            totalPoints: isCorrect ? currentState.totalPoints + points : currentState.totalPoints,
          ));
        }
      } catch (e) {
        print('QuizBloc Error (SubmitQuizAnswer): $e');
        emit(QuizError(message: 'Failed to submit answer: ${e.toString()}'));
      }
    });

    on<SubmitQuizAnswersBulk>((event, emit) async {
      if (state is! QuizLoaded) {
        emit(QuizError(message: 'Cannot submit bulk answers: Quiz not loaded'));
        return;
      }
      
      emit(QuizLoading());
      try {
        print('QuizBloc: Submitting ${event.answers.length} answers in bulk');
        
        // Check if we have answers to submit
        if (event.answers.isEmpty) {
          emit(QuizError(message: 'No answers to submit'));
          return;
        }
        
        // Check if we need to convert timeRemaining to timeSpent
        final answersWithTimeSpent = QuizHelper.convertToTimeSpent(event.answers);
        
        // Filter out invalid question IDs before submission to prevent ObjectId casting errors
        final validAnswers = QuizHelper.filterValidQuestionIds(answersWithTimeSpent);
        
        if (validAnswers.isEmpty) {
          emit(QuizError(message: 'No valid answers to submit. All question IDs were invalid.'));
          return;
        }
        
        if (validAnswers.length < answersWithTimeSpent.length) {
          print('QuizBloc: Filtered out ${answersWithTimeSpent.length - validAnswers.length} invalid question IDs');
        }
        
        // Use the QuizHelper for bulk submission
        final response = await QuizHelper.submitBulkAnswers(validAnswers);
        
        if (response['success'] == true || response.containsKey('results')) {
          // Process successful bulk submission
          print('QuizBloc: Bulk submission successful');
          
          final List<Map<String, dynamic>> results = response['results'] != null
              ? List<Map<String, dynamic>>.from(response['results'])
              : [];
              
          final Map<String, dynamic> summary = response['summary'] != null
              ? Map<String, dynamic>.from(response['summary'])
              : {};
              
          final List<Map<String, dynamic>> newAchievements = response['newAchievements'] != null 
              ? List<Map<String, dynamic>>.from(response['newAchievements'])
              : [];
          
          emit(QuizBulkAnswersSubmitted(
            results: results,
            summary: summary,
            newAchievements: newAchievements,
          ));
        } else {
          // Handle error in response
          emit(QuizError(message: response['message'] ?? 'Failed to submit bulk answers'));
        }
      } catch (e) {
        print('QuizBloc Error (SubmitQuizAnswersBulk): $e');
        emit(QuizError(message: 'Failed to submit bulk answers: ${e.toString()}'));
      }
    });
  }
  
  // Helper method to get difficulty multiplier
  double _getDifficultyMultiplier(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 1.0;
      case 'medium':
        return 1.5;
      case 'hard':
        return 2.0;
      default:
        return 1.0;
    }
  }
  
  // Factory constructor to create a QuizBloc from BuildContext
  factory QuizBloc.fromContext(BuildContext context) {
    return QuizBloc(
      apiService: Provider.of<ApiService>(context, listen: false),
    );
  }
}
