import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:text_the_answer/utils/quiz/time_utility.dart';
import '../blocs/quiz/quiz_bloc.dart';
import '../blocs/quiz/quiz_event.dart';
import '../blocs/quiz/quiz_state.dart';
import '../models/question.dart';
import '../widgets/quiz/typing_indicator.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../router/routes.dart';
import '../utils/theme/theme_cubit.dart';

class DailyQuizScreen extends StatefulWidget {
  const DailyQuizScreen({super.key});

  @override
  State<DailyQuizScreen> createState() => _DailyQuizScreenState();
}

class _DailyQuizScreenState extends State<DailyQuizScreen> {
  // Timer for the question countdown
  Timer? _timer;
  double _secondsRemaining = 15.0; // 15 seconds to answer

  // Timer for total quiz duration (10 minutes)
  Timer? _totalQuizTimer;
  Duration _totalTimeRemaining = QuizTimeUtility.getTotalQuizDuration();
  DateTime? _quizStartTime;

  late TextEditingController _answerController;

  // For bulk submission
  final List<Map<String, dynamic>> _collectedAnswers = [];
  bool _bulkSubmissionMode = true; // Set to true to use bulk submission
  int _startTime = 0;

  late SharedPreferences prefs; // Declare the prefs variable

  void _toggleTheme() {
    // Get the current ThemeCubit and its state
    final ThemeCubit cubit = context.read<ThemeCubit>();
    final currentState = cubit.state;
    
    // Toggle between light and dark modes
    if (currentState.mode == AppThemeMode.dark) {
      cubit.setTheme(AppThemeMode.light);
    } else {
      cubit.setTheme(AppThemeMode.dark);
    }
    
    // Call the original toggleTheme callback
    widget.toggleTheme();
  }

  @override
  void initState() {
    super.initState();
    _answerController = TextEditingController();
    initPrefs(); // Initialize prefs before using it
    checkDailyResetStatus();
  }

  @override
  void dispose() {
    _stopTimer();
    _stopTotalQuizTimer();
    _answerController.dispose();
    super.dispose();
  }

  // Add a method to initialize shared preferences
  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  void _startTotalQuizTimer() {
    _stopTotalQuizTimer();

    _totalTimeRemaining = QuizTimeUtility.getTotalQuizDuration();
    _quizStartTime = DateTime.now();

    // Use a 100ms interval for more precise timing
    _totalQuizTimer = Timer.periodic(const Duration(milliseconds: 100), (
      timer,
    ) {
      setState(() {
        // Calculate the remaining time more precisely
        final elapsed = DateTime.now().difference(_quizStartTime!);
        _totalTimeRemaining = QuizTimeUtility.getTotalQuizDuration() - elapsed;

        if (_totalTimeRemaining.inMilliseconds <= 0) {
          // Time's up - submit all answers
          _submitBulkAnswers();
          timer.cancel();
        }
      });
    });
  }

  void _stopTotalQuizTimer() {
    _totalQuizTimer?.cancel();
    _totalQuizTimer = null;
  }

  void _handleTotalQuizTimeExpired() {
    final quizState = context.read<QuizBloc>().state;
    if (quizState is QuizLoaded) {
      // Calculate total elapsed time in milliseconds
      final elapsedMilliseconds =
          DateTime.now().difference(_quizStartTime!).inMilliseconds;

      // Auto-submit current answers and any remaining questions with empty answers
      if (_bulkSubmissionMode) {
        // Submit only collected answers
        if (_collectedAnswers.isNotEmpty) {
          context.read<QuizBloc>().add(
            SubmitQuizAnswersBulk(answers: _collectedAnswers),
          );
        }

        // Notify about auto-submission
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Time\'s up! Your answers have been automatically submitted.',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );

        // Add an event to track the total quiz time expiration
        context.read<QuizBloc>().add(
          QuizTotalTimeExpired(totalQuizTimeElapsed: elapsedMilliseconds),
        );
      }
    }
  }

  void _startTimer() {
    _stopTimer();
    setState(() {
      _secondsRemaining = 15.0; // Change to double for decimal seconds
      _startTime = DateTime.now().millisecondsSinceEpoch; // Record start time
    });

    // Use a 100ms interval for more precise timing
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        if (_secondsRemaining > 0.1) {
          _secondsRemaining -= 0.1; // Decrease by 0.1 second each interval
        } else {
          // Time's up - submit empty answer
          _handleAnswerSubmission("");
          _timer?.cancel();
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _resetAnswerField() {
    _answerController.clear();
  }

  // Calculate time spent on a question in seconds
  double _calculateTimeSpent() {
    final endTime = DateTime.now().millisecondsSinceEpoch;
    return (endTime - _startTime) / 1000; // Convert milliseconds to seconds
  }

  void _handleAnswerSubmission(String answer) {
    final quizState = context.read<QuizBloc>().state;

    if (quizState is QuizLoaded &&
        quizState.questionsAnswered < quizState.questions.length) {
      final currentQuestion = quizState.questions[quizState.questionsAnswered];
      final timeSpent = _calculateTimeSpent();

      // Debug the current question ID
      print('Handling answer for question: ${currentQuestion.text}');
      print('Question ID: ${currentQuestion.id}');

      if (_bulkSubmissionMode) {
        // Check if the ID is a valid MongoDB ObjectId (24-character hex string)
        final isValidId =
            currentQuestion.id.length == 24 &&
            RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(currentQuestion.id);

        if (isValidId) {
          _collectedAnswers.add({
            'questionId': currentQuestion.id,
            'answer': answer.trim(),
            'timeSpent': timeSpent,
          });

          print('Added answer for question ID: ${currentQuestion.id}');
        } else {
          print('Skipping question with invalid ID: ${currentQuestion.id}');
        }

        // If this was the last question, submit all answers in bulk
        if (quizState.questionsAnswered + 1 >= quizState.questions.length) {
          _submitBulkAnswers();
        } else {
          // Otherwise, advance to the next question using a local state change
          context.read<QuizBloc>().emit(
            QuizLoaded(
              questions: quizState.questions,
              questionsAnswered: quizState.questionsAnswered + 1,
              correctAnswers: quizState.correctAnswers,
              totalPoints: quizState.totalPoints,
              totalTimeElapsed:
                  QuizTimeUtility.getTotalQuizDuration() - _totalTimeRemaining,
              totalTimeRemaining: _totalTimeRemaining,
            ),
          );

          // Start the timer for the next question
          _startTimer();
        }
      } else {
        // Use the original single answer submission
        context.read<QuizBloc>().add(
          SubmitQuizAnswer(
            questionId: currentQuestion.id,
            answer: answer.trim(),
            timeRemaining: _secondsRemaining.toInt(),
          ),
        );
      }

      _stopTimer();
      _resetAnswerField();
    }
  }

  void _submitBulkAnswers() {
    if (_collectedAnswers.isEmpty) {
      print('No answers to submit');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No valid answers to submit'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print('Submitting ${_collectedAnswers.length} answers in bulk');
    // Debug the answers being submitted
    for (var i = 0; i < _collectedAnswers.length; i++) {
      print('Answer $i: ${jsonEncode(_collectedAnswers[i])}');
    }

    // Stop total quiz timer when submitting
    _stopTotalQuizTimer();

    // Calculate total time taken for the quiz
    final quizDuration =
        _quizStartTime != null
            ? DateTime.now().difference(_quizStartTime!).inMilliseconds
            : 0;

    context.read<QuizBloc>().add(
      SubmitQuizAnswersBulk(answers: _collectedAnswers),
    );
  }

  void checkDailyResetStatus() async {
    await initPrefs(); // Ensure prefs is initialized
    // Get today's date in the format YYYY-MM-DD
    final today = DateTime.now().toIso8601String().split('T')[0];

    // Get the last date the user accessed the daily quiz
    final lastAccessDate = prefs.getString('lastDailyQuizDate');

    if (lastAccessDate != today) {
      // It's a new day, reset any local daily quiz data
      await prefs.setString('lastDailyQuizDate', today);
      // Clear any cached questions and answers
      await prefs.remove('dailyQuizQuestions');
      await prefs.remove('dailyQuizAnswers');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<QuizBloc, QuizState>(
          listener: (context, state) {
            if (state is QuizError) {
              print('DailyQuizScreen Error: ${state.message}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 5),
                ),
              );
            } else if (state is QuizAnswerSubmitted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.isCorrect
                        ? 'Correct! ${state.explanation} (+${state.points} points)'
                        : 'Incorrect. ${state.explanation}',
                  ),
                  backgroundColor:
                      state.isCorrect ? Colors.green : Colors.orange,
                ),
              );

              // Start timer for the next question if available
              final quizBloc = context.read<QuizBloc>();
              if (quizBloc.state is QuizLoaded) {
                final loadedState = quizBloc.state as QuizLoaded;
                if (loadedState.questionsAnswered <
                    loadedState.questions.length) {
                  _startTimer();
                }
              }
            } else if (state is QuizBulkAnswersSubmitted) {
              // Show a summary of the bulk submission
              _showBulkSubmissionResults(context, state);
            } else if (state is QuizLoaded &&
                state.questionsAnswered < state.questions.length &&
                _timer == null) {
              // Start timers when quiz is first loaded
              _startTimer();
              if (_totalQuizTimer == null) {
                _startTotalQuizTimer();
              }
            }
          },
          builder: (context, state) {
            if (state is QuizLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is QuizLoaded) {
              if (state.questions.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.quiz, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No quiz questions available',
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Try again later or contact support if the problem persists.',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            context.read<QuizBloc>().add(FetchDailyQuiz());
                          },
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final questions = state.questions;
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Daily Quiz 🧠',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        // Timer display for question
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _getTimerColor(),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _formatQuestionTime(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Total quiz time remaining
                    _buildTotalQuizTimeRemaining(),
                    const SizedBox(height: 8),
                    Text(
                      'Questions: ${state.questionsAnswered}/${questions.length}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Correct: ${state.correctAnswers}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Points: ${state.totalPoints}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (state.questionsAnswered < questions.length)
                      _buildActiveQuiz(
                        context,
                        questions[state.questionsAnswered],
                      )
                    else if (_bulkSubmissionMode &&
                        _collectedAnswers.isNotEmpty)
                      _buildQuizProcessing()
                    else
                      _buildQuizCompleted(context, state),
                  ],
                ),
              );
            } else if (state is QuizBulkAnswersSubmitted) {
              return _buildBulkSubmissionResults(context, state);
            } else if (state is QuizResultsState) {
              return _buildQuizResultsWithAwards(context, state);
            }

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.quiz,
                      size: 64,
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Daily Quiz 🧠',
                      style: Theme.of(context).textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Test your knowledge with our daily quiz challenge!',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    // Note about the 10-minute time limit
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Today\'s winner gets 1 month FREE premium!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Complete quiz with highest score in less time to win.',
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Total time limit: 10 minutes',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        // Clear any previous answers when starting a new quiz
                        _collectedAnswers.clear();
                        context.read<QuizBloc>().add(FetchDailyQuiz());
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(200, 48),
                      ),
                      child: const Text('Start Daily Quiz'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Add a widget to display total quiz time remaining
  Widget _buildTotalQuizTimeRemaining() {
    final minutes = _totalTimeRemaining.inMinutes;
    final seconds = (_totalTimeRemaining.inSeconds % 60);
    final milliseconds =
        (_totalTimeRemaining.inMilliseconds % 1000) ~/
        10; // Show only tens of milliseconds

    // Format as MM:SS:mm
    final secondsStr = seconds.toString().padLeft(2, '0');
    final millisecondsStr = milliseconds.toString().padLeft(2, '0');

    // Determine color based on time remaining
    Color timerColor;
    if (minutes < 1) {
      timerColor = Colors.red;
    } else if (minutes < 3) {
      timerColor = Colors.orange;
    } else {
      timerColor = Colors.blue;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: timerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: timerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timelapse, size: 16, color: timerColor),
          SizedBox(width: 4),
          Text(
            'Quiz Time: $minutes:$secondsStr:$millisecondsStr',
            style: TextStyle(fontWeight: FontWeight.bold, color: timerColor),
          ),
        ],
      ),
    );
  }

  // New method to build results with premium award information
  Widget _buildQuizResultsWithAwards(
    BuildContext context,
    QuizResultsState state,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Quiz Results',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: 24),

          // Premium award notice if user is the winner
          if (state.isWinner)
            Container(
              margin: EdgeInsets.only(bottom: 24),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events, color: Colors.amber, size: 32),
                      SizedBox(width: 8),
                      Text(
                        'CONGRATULATIONS!',
                        style: TextStyle(
                          color: Colors.amber.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'You\'ve won 1 month of FREE premium access!',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your premium features have been activated.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

          // Regular results display (use existing methods)
          // Implementation depends on available data in QuizResultsState

          // Button to return to home
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.home),
            label: Text('Return to Home'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveQuiz(BuildContext context, Question question) {
    // Difficulty badge color
    Color difficultyColor = Colors.green;
    if (question.difficulty == 'medium') {
      difficultyColor = Colors.orange;
    } else if (question.difficulty == 'hard') {
      difficultyColor = Colors.red;
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Difficulty badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: difficultyColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              question.difficulty.toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Question text
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.text,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),
                    // Answer input field with typing indicator
                    Column(
                      children: [
                        TextField(
                          controller: _answerController,
                          decoration: InputDecoration(
                            hintText: 'Type your answer here...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            suffixIcon: IconButton(
                              icon: Icon(Icons.send),
                              onPressed:
                                  () => _handleAnswerSubmission(
                                    _answerController.text,
                                  ),
                            ),
                          ),
                          style: Theme.of(context).textTheme.titleMedium,
                          onSubmitted: _handleAnswerSubmission,
                          autofocus: true,
                        ),
                        const SizedBox(height: 8),
                        // Add the typing progress indicator
                        TypingProgressIndicator(
                          controller: _answerController,
                          maxWidth: MediaQuery.of(context).size.width - 64,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        'Type your answer and press Enter or tap Send',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Answer quickly for more points!',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizProcessing() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 24),
            Text(
              'Processing your answers...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Please wait while we check your responses.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizCompleted(BuildContext context, QuizLoaded state) {
    final percentage =
        state.questions.isEmpty
            ? 0.0
            : (state.correctAnswers / state.questions.length) * 100;

    String remarks = 'Try again!';
    Color remarksColor = Colors.red;

    if (percentage >= 80) {
      remarks = 'Excellent!';
      remarksColor = Colors.green;
    } else if (percentage >= 60) {
      remarks = 'Good job!';
      remarksColor = Colors.blue;
    } else if (percentage >= 40) {
      remarks = 'Not bad!';
      remarksColor = Colors.orange;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            percentage >= 60 ? Icons.emoji_events : Icons.school,
            size: 80,
            color: remarksColor,
          ),
          SizedBox(height: 24),
          Text(
            remarks,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: remarksColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            'Quiz Completed',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            'Score: ${state.correctAnswers}/${state.questions.length}',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Total Points: ${state.totalPoints}',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // Clear any previous answers when restarting
              _collectedAnswers.clear();
              context.read<QuizBloc>().add(FetchDailyQuiz());
            },
            icon: Icon(Icons.refresh),
            label: Text('Try Again'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulkSubmissionResults(
    BuildContext context,
    QuizBulkAnswersSubmitted state,
  ) {
    final summary = state.summary;
    final correctAnswers = summary['correctAnswers'] ?? 0;
    final questionsAnswered = summary['questionsAnswered'] ?? 0;
    final totalScore = summary['totalScore'] ?? 0;
    final streak = summary['streak'] ?? 0;

    final percentage =
        questionsAnswered > 0
            ? (correctAnswers / questionsAnswered) * 100
            : 0.0;

    String remarks = 'Try again!';
    Color remarksColor = Colors.red;

    if (percentage >= 80) {
      remarks = 'Excellent!';
      remarksColor = Colors.green;
    } else if (percentage >= 60) {
      remarks = 'Good job!';
      remarksColor = Colors.blue;
    } else if (percentage >= 40) {
      remarks = 'Not bad!';
      remarksColor = Colors.orange;
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Text(
            'Quiz Results',
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          Icon(
            percentage >= 60 ? Icons.emoji_events : Icons.school,
            size: 80,
            color: remarksColor,
          ),
          Text(
            remarks,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: remarksColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          _buildSummaryCard(
            context,
            correctAnswers,
            questionsAnswered,
            totalScore,
            streak,
          ),
          SizedBox(height: 24),
          if (state.newAchievements.isNotEmpty)
            _buildAchievementsSection(context, state.newAchievements),
          SizedBox(height: 24),
          _buildAnswerResultsList(context, state.results),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  // Clear any previous answers when restarting
                  _collectedAnswers.clear();
                  context.read<QuizBloc>().add(FetchDailyQuiz());
                },
                icon: Icon(Icons.refresh),
                label: Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate back to the home page
                  context.go(AppRoutePath.home);
                },
                icon: Icon(Icons.home),
                label: Text('Back to Home'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    int correctAnswers,
    int questionsAnswered,
    int totalScore,
    int streak,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Summary', style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryItem(
                  context,
                  'Score',
                  '$correctAnswers/$questionsAnswered',
                  Icons.check_circle,
                ),
                _buildSummaryItem(
                  context,
                  'Points',
                  '$totalScore',
                  Icons.stars,
                ),
                _buildSummaryItem(
                  context,
                  'Streak',
                  '$streak',
                  Icons.local_fire_department,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).primaryColor),
        SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection(
    BuildContext context,
    List<Map<String, dynamic>> achievements,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'New Achievements',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            Column(
              children:
                  achievements
                      .map(
                        (achievement) =>
                            _buildAchievementItem(context, achievement),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementItem(
    BuildContext context,
    Map<String, dynamic> achievement,
  ) {
    IconData iconData = Icons.emoji_events;
    if (achievement['icon'] == 'bolt')
      iconData = Icons.bolt;
    else if (achievement['icon'] == 'star')
      iconData = Icons.star;

    Color tierColor = Colors.brown;
    if (achievement['tier'] == 'silver')
      tierColor = Colors.grey;
    else if (achievement['tier'] == 'gold')
      tierColor = Colors.amber;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: tierColor,
        child: Icon(iconData, color: Colors.white),
      ),
      title: Text(achievement['name'] ?? 'Achievement'),
      subtitle: Text(achievement['description'] ?? ''),
    );
  }

  Widget _buildAnswerResultsList(
    BuildContext context,
    List<Map<String, dynamic>> results,
  ) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question Details',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final result = results[index];
                    return Card(
                      color:
                          result['isCorrect'] == true
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                      margin: EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Question ${index + 1}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  result['isCorrect'] == true
                                      ? '+${result['points']} points'
                                      : '0 points',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        result['isCorrect'] == true
                                            ? Colors.green
                                            : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text('${result['explanation']}'),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  'Correct answer: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text('${result['correctAnswer']}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBulkSubmissionResults(
    BuildContext context,
    QuizBulkAnswersSubmitted state,
  ) {
    // This would show a notification or toast with the summary
    final correctAnswers = state.summary['correctAnswers'] ?? 0;
    final questionsAnswered = state.summary['questionsAnswered'] ?? 0;
    final totalPoints = state.summary['totalScore'] ?? 0;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Quiz completed! Score: $correctAnswers/$questionsAnswered - $totalPoints points',
        ),
        duration: Duration(seconds: 5),
        backgroundColor: Colors.purple,
      ),
    );
  }

  Color _getTimerColor() {
    if (_secondsRemaining > 10) {
      return Colors.green;
    } else if (_secondsRemaining > 5) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _formatQuestionTime() {
    // Convert seconds to seconds:milliseconds format
    // For simplicity, we'll simulate milliseconds by dividing the second into 10 parts
    final seconds = _secondsRemaining ~/ 1;
    final milliseconds =
        (_secondsRemaining * 100) % 100; // Using 2 decimal places
    return '$seconds:${milliseconds.toInt().toString().padLeft(2, '0')}';
  }
}
