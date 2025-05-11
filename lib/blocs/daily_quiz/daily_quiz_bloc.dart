import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../services/socket_service.dart';
import '../../services/daily_quiz_socket.dart';
import '../../models/question.dart';
import '../../services/auth_token_service.dart';
import 'daily_quiz_event.dart';
import 'daily_quiz_state.dart';

class DailyQuizBloc extends Bloc<DailyQuizEvent, DailyQuizState> {
  final SocketService _socketService = SocketService();
  late final DailyQuizSocket _dailyQuizSocket;
  final AuthTokenService _authTokenService = AuthTokenService();
  final String socketUrl = dotenv.env['SOCKET_IO_URL'] ?? 'http://localhost:3000';
  
  // Stream subscriptions for socket events
  StreamSubscription? _playerJoinedSubscription;
  StreamSubscription? _playerLeftSubscription;
  StreamSubscription? _newQuestionSubscription;
  StreamSubscription? _questionEndedSubscription;
  StreamSubscription? _answerResultSubscription;
  StreamSubscription? _leaderboardUpdateSubscription;
  StreamSubscription? _quizEndedSubscription;
  StreamSubscription? _socketErrorSubscription;
  
  DailyQuizBloc() : super(DailyQuizInitial()) {
    _dailyQuizSocket = DailyQuizSocket(serverUrl: socketUrl);
    
    on<JoinDailyQuiz>((event, emit) async {
      emit(DailyQuizLoading());
      try {
        // Initialize the daily quiz socket connection
        await _dailyQuizSocket.init();
        
        // Setup socket event listeners
        _setupSocketListeners();
        
        emit(DailyQuizWaiting(message: 'Waiting for quiz to start...'));
      } catch (e) {
        emit(DailyQuizError(message: 'Failed to join daily quiz: $e'));
      }
    });
    
    on<LeaveDailyQuiz>((event, emit) {
      // Disconnect socket
      _dailyQuizSocket.disconnect();
      
      // Cancel all subscriptions
      _cancelSubscriptions();
      
      emit(DailyQuizInitial());
    });
    
    on<StartDailyQuiz>((event, emit) {
      if (state is DailyQuizWaiting) {
        emit(DailyQuizStarted(
          currentQuestionIndex: 0,
          totalQuestions: event.totalQuestions
        ));
      }
    });
    
    on<ReceiveQuestion>((event, emit) {
      emit(DailyQuizQuestionActive(
        question: event.question,
        questionIndex: event.questionIndex,
        totalQuestions: event.totalQuestions,
        timeLimit: event.timeLimit,
        participants: event.participants
      ));
    });
    
    on<SubmitDailyQuizAnswer>((event, emit) {
      if (state is DailyQuizQuestionActive) {
        final currentState = state as DailyQuizQuestionActive;
        
        // Emit waiting for results state
        emit(DailyQuizAnswerSubmitted(
          question: currentState.question,
          questionIndex: currentState.questionIndex,
          totalQuestions: currentState.totalQuestions,
          userAnswer: event.answer,
          participants: currentState.participants
        ));
        
        // Submit answer via socket
        if (_dailyQuizSocket.socket != null && _dailyQuizSocket.socket!.connected) {
          _dailyQuizSocket.socket!.emit('submit-answer', {
            'questionId': currentState.question.id,
            'answer': event.answer,
            'timeRemaining': event.timeRemaining,
          });
        }
      }
    });
    
    on<ReceiveAnswerResult>((event, emit) {
      if (state is DailyQuizAnswerSubmitted) {
        final currentState = state as DailyQuizAnswerSubmitted;
        
        emit(DailyQuizQuestionResult(
          question: currentState.question,
          questionIndex: currentState.questionIndex,
          totalQuestions: currentState.totalQuestions,
          userAnswer: currentState.userAnswer,
          isCorrect: event.isCorrect,
          correctAnswer: event.correctAnswer,
          explanation: event.explanation,
          points: event.points,
          totalPoints: event.totalPoints,
          participants: event.participants,
          userRank: event.userRank
        ));
      }
    });
    
    on<UpdateLeaderboard>((event, emit) {
      if (state is DailyQuizQuestionResult) {
        final currentState = state as DailyQuizQuestionResult;
        
        emit(currentState.copyWith(
          participants: event.participants,
          userRank: event.userRank
        ));
      } else if (state is DailyQuizAnswerSubmitted) {
        final currentState = state as DailyQuizAnswerSubmitted;
        
        emit(DailyQuizAnswerSubmitted(
          question: currentState.question,
          questionIndex: currentState.questionIndex,
          totalQuestions: currentState.totalQuestions,
          userAnswer: currentState.userAnswer,
          participants: event.participants
        ));
      } else if (state is DailyQuizQuestionActive) {
        final currentState = state as DailyQuizQuestionActive;
        
        emit(DailyQuizQuestionActive(
          question: currentState.question,
          questionIndex: currentState.questionIndex,
          totalQuestions: currentState.totalQuestions,
          timeLimit: currentState.timeLimit,
          participants: event.participants
        ));
      }
    });
    
    on<QuizEnded>((event, emit) {
      emit(DailyQuizCompleted(
        totalQuestions: event.totalQuestions,
        correctAnswers: event.correctAnswers,
        totalPoints: event.totalPoints,
        participants: event.participants,
        userRank: event.userRank,
        winner: event.winner
      ));
    });
    
    on<SocketError>((event, emit) {
      emit(DailyQuizError(message: event.message));
    });
  }
  
  void _setupSocketListeners() {
    // Listen for new questions
    _dailyQuizSocket.socket?.on('new-question', (data) {
      final question = Question.fromJson(data['question']);
      add(ReceiveQuestion(
        question: question,
        questionIndex: data['questionIndex'] ?? 0,
        totalQuestions: data['totalQuestions'] ?? 10,
        timeLimit: data['timeLimit'] ?? 15,
        participants: data['participants'] ?? []
      ));
    });
    
    // Listen for question ended
    _dailyQuizSocket.socket?.on('question-ended', (data) {
      // Usually transitions to the results screen
    });
    
    // Listen for answer results
    _dailyQuizSocket.socket?.on('answer-result', (data) {
      add(ReceiveAnswerResult(
        isCorrect: data['isCorrect'] ?? false,
        correctAnswer: data['correctAnswer'] ?? '',
        explanation: data['explanation'] ?? '',
        points: data['points'] ?? 0,
        totalPoints: data['totalPoints'] ?? 0,
        participants: data['participants'] ?? [],
        userRank: data['userRank'] ?? 0
      ));
    });
    
    // Listen for leaderboard updates
    _dailyQuizSocket.socket?.on('leaderboard-update', (data) {
      add(UpdateLeaderboard(
        participants: data['participants'] ?? [],
        userRank: data['userRank'] ?? 0
      ));
    });
    
    // Listen for quiz ended
    _dailyQuizSocket.socket?.on('quiz-ended', (data) {
      add(QuizEnded(
        totalQuestions: data['totalQuestions'] ?? 10,
        correctAnswers: data['correctAnswers'] ?? 0,
        totalPoints: data['totalPoints'] ?? 0,
        participants: data['participants'] ?? [],
        userRank: data['userRank'] ?? 0,
        winner: data['winner']
      ));
    });
    
    // Listen for socket errors
    _dailyQuizSocket.socket?.on('error', (data) {
      final errorMsg = data is String ? data : (data is Map ? data['message'] ?? 'Socket error occurred' : 'Socket error occurred');
      add(SocketError(message: errorMsg));
    });
  }
  
  void _cancelSubscriptions() {
    _playerJoinedSubscription?.cancel();
    _playerLeftSubscription?.cancel();
    _newQuestionSubscription?.cancel();
    _questionEndedSubscription?.cancel();
    _answerResultSubscription?.cancel();
    _leaderboardUpdateSubscription?.cancel();
    _quizEndedSubscription?.cancel();
    _socketErrorSubscription?.cancel();
  }
  
  @override
  Future<void> close() {
    _cancelSubscriptions();
    _dailyQuizSocket.dispose();
    return super.close();
  }
} 