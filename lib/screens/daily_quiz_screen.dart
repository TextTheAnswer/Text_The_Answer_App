import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/quiz/quiz_bloc.dart';
import '../blocs/quiz/quiz_event.dart';
import '../blocs/quiz/quiz_state.dart';
import '../models/question.dart';
import 'dart:convert';

class DailyQuizScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  const DailyQuizScreen({required this.toggleTheme, super.key});

  @override
  State<DailyQuizScreen> createState() => _DailyQuizScreenState();
}

class _DailyQuizScreenState extends State<DailyQuizScreen> {
  // Timer for the countdown
  Timer? _timer;
  int _secondsRemaining = 15; // 15 seconds to answer
  late TextEditingController _answerController;
  
  // For bulk submission
  final List<Map<String, dynamic>> _collectedAnswers = [];
  bool _bulkSubmissionMode = true; // Set to true to use bulk submission
  int _startTime = 0;
  
  @override
  void initState() {
    super.initState();
    _answerController = TextEditingController();
  }

  @override
  void dispose() {
    _stopTimer();
    _answerController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _stopTimer();
    setState(() {
      _secondsRemaining = 15;
      _startTime = DateTime.now().millisecondsSinceEpoch; // Record start time
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
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
    
    if (quizState is QuizLoaded && quizState.questionsAnswered < quizState.questions.length) {
      final currentQuestion = quizState.questions[quizState.questionsAnswered];
      final timeSpent = _calculateTimeSpent();
      
      // Debug the current question ID
      print('Handling answer for question: ${currentQuestion.text}');
      print('Question ID: ${currentQuestion.id}');
      
      if (_bulkSubmissionMode) {
        // Check if the ID is a valid MongoDB ObjectId (24-character hex string)
        final isValidId = currentQuestion.id.length == 24 && 
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
            )
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
            timeRemaining: _secondsRemaining,
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
    
    context.read<QuizBloc>().add(
      SubmitQuizAnswersBulk(
        answers: _collectedAnswers,
      ),
    );
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
                  content: Text(state.isCorrect
                      ? 'Correct! ${state.explanation} (+${state.points} points)'
                      : 'Incorrect. ${state.explanation}'),
                  backgroundColor: state.isCorrect ? Colors.green : Colors.orange,
                ),
              );
              
              // Start timer for the next question if available
              final quizBloc = context.read<QuizBloc>();
              if (quizBloc.state is QuizLoaded) {
                final loadedState = quizBloc.state as QuizLoaded;
                if (loadedState.questionsAnswered < loadedState.questions.length) {
                  _startTimer();
                }
              }
            } else if (state is QuizBulkAnswersSubmitted) {
              // Show a summary of the bulk submission
              _showBulkSubmissionResults(context, state);
            } else if (state is QuizLoaded && 
                      state.questionsAnswered < state.questions.length &&
                      _timer == null) {
              // Start timer when quiz is first loaded
              _startTimer();
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
                        // Timer display
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _getTimerColor(),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${_secondsRemaining}s',
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
                    const SizedBox(height: 24),
                    if (state.questionsAnswered < questions.length)
                      _buildActiveQuiz(context, questions[state.questionsAnswered])
                    else if (_bulkSubmissionMode && _collectedAnswers.isNotEmpty)
                      _buildQuizProcessing()
                    else
                      _buildQuizCompleted(context, state),
                  ],
                ),
              );
            } else if (state is QuizBulkAnswersSubmitted) {
              return _buildBulkSubmissionResults(context, state);
            }
            
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.quiz, size: 64, color: Theme.of(context).primaryColor),
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
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                    // Answer input field
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
                          onPressed: () => _handleAnswerSubmission(_answerController.text),
                        ),
                      ),
                      style: Theme.of(context).textTheme.titleMedium,
                      onSubmitted: _handleAnswerSubmission,
                      autofocus: true,
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
    final percentage = state.questions.isEmpty 
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
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
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
  
  Widget _buildBulkSubmissionResults(BuildContext context, QuizBulkAnswersSubmitted state) {
    final summary = state.summary;
    final correctAnswers = summary['correctAnswers'] ?? 0;
    final questionsAnswered = summary['questionsAnswered'] ?? 0;
    final totalScore = summary['totalScore'] ?? 0;
    final streak = summary['streak'] ?? 0;
    
    final percentage = questionsAnswered > 0 
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
          _buildSummaryCard(context, correctAnswers, questionsAnswered, totalScore, streak),
          SizedBox(height: 24),
          if (state.newAchievements.isNotEmpty)
            _buildAchievementsSection(context, state.newAchievements),
          SizedBox(height: 24),
          _buildAnswerResultsList(context, state.results),
          SizedBox(height: 24),
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
  
  Widget _buildSummaryCard(BuildContext context, int correctAnswers, int questionsAnswered, 
      int totalScore, int streak) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Summary',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryItem(context, 'Score', '$correctAnswers/$questionsAnswered', Icons.check_circle),
                _buildSummaryItem(context, 'Points', '$totalScore', Icons.stars),
                _buildSummaryItem(context, 'Streak', '$streak', Icons.local_fire_department),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSummaryItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).primaryColor),
        SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildAchievementsSection(BuildContext context, List<Map<String, dynamic>> achievements) {
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
              children: achievements.map((achievement) => _buildAchievementItem(context, achievement)).toList(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAchievementItem(BuildContext context, Map<String, dynamic> achievement) {
    IconData iconData = Icons.emoji_events;
    if (achievement['icon'] == 'bolt') iconData = Icons.bolt;
    else if (achievement['icon'] == 'star') iconData = Icons.star;
    
    Color tierColor = Colors.brown;
    if (achievement['tier'] == 'silver') tierColor = Colors.grey;
    else if (achievement['tier'] == 'gold') tierColor = Colors.amber;
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: tierColor,
        child: Icon(iconData, color: Colors.white),
      ),
      title: Text(achievement['name'] ?? 'Achievement'),
      subtitle: Text(achievement['description'] ?? ''),
    );
  }
  
  Widget _buildAnswerResultsList(BuildContext context, List<Map<String, dynamic>> results) {
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
                      color: result['isCorrect'] == true 
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
                                  result['isCorrect'] == true ? '+${result['points']} points' : '0 points',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: result['isCorrect'] == true ? Colors.green : Colors.red,
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
                                  style: TextStyle(fontWeight: FontWeight.bold)
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
  
  void _showBulkSubmissionResults(BuildContext context, QuizBulkAnswersSubmitted state) {
    // This would show a notification or toast with the summary
    final correctAnswers = state.summary['correctAnswers'] ?? 0;
    final questionsAnswered = state.summary['questionsAnswered'] ?? 0;
    final totalPoints = state.summary['totalScore'] ?? 0;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Quiz completed! Score: $correctAnswers/$questionsAnswered - $totalPoints points'),
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
}