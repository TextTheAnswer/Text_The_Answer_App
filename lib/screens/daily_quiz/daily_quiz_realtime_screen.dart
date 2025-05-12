import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/daily_quiz/daily_quiz_bloc.dart';
import '../../blocs/daily_quiz/daily_quiz_event.dart';
import '../../blocs/daily_quiz/daily_quiz_state.dart';
import '../../blocs/socket/socket_bloc.dart';
import '../../blocs/socket/socket_event.dart';
import '../../blocs/socket/socket_state.dart' as socket_state;
import '../../models/question.dart';
import '../../widgets/quiz/quiz_countdown_timer.dart';
import '../../widgets/quiz/participant_list.dart';
import '../../utils/socket_test.dart';
import '../../blocs/achievement/achievement_bloc.dart';
import '../../blocs/achievement/achievement_event.dart';
import '../../blocs/achievement/achievement_state.dart';
import '../../models/achievement.dart';
import 'package:go_router/go_router.dart';
import '../../router/routes.dart';
import '../../router/route_helper.dart';
import '../../widgets/quiz/quiz_share_card.dart';
import 'quiz_review_screen.dart';
import 'package:share_plus/share_plus.dart';

class DailyQuizRealtimeScreen extends StatefulWidget {
  const DailyQuizRealtimeScreen({Key? key}) : super(key: key);

  @override
  _DailyQuizRealtimeScreenState createState() => _DailyQuizRealtimeScreenState();
}

class _DailyQuizRealtimeScreenState extends State<DailyQuizRealtimeScreen> {
  final TextEditingController _answerController = TextEditingController();
  Timer? _countdownTimer;
  int _remainingSeconds = 15;
  bool _answerSubmitted = false;
  List<Map<String, dynamic>> _quizResults = [];

  @override
  void initState() {
    super.initState();
    // Initialize socket connection and join daily quiz
    context.read<SocketBloc>().add(InitializeSocket());
    context.read<DailyQuizBloc>().add(JoinDailyQuiz());
  }

  @override
  void dispose() {
    _answerController.dispose();
    _countdownTimer?.cancel();
    // Leave daily quiz when screen is disposed
    context.read<DailyQuizBloc>().add(LeaveDailyQuiz());
    super.dispose();
  }

  void _startTimer(int seconds) {
    _remainingSeconds = seconds;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _countdownTimer?.cancel();
          // Auto-submit empty answer if time runs out
          if (!_answerSubmitted) {
            _submitAnswer();
          }
        }
      });
    });
  }

  void _submitAnswer() {
    setState(() {
      _answerSubmitted = true;
    });
    
    context.read<DailyQuizBloc>().add(
      SubmitDailyQuizAnswer(
        answer: _answerController.text.trim(),
        timeRemaining: _remainingSeconds,
      )
    );
    
    _countdownTimer?.cancel();
  }

  void _checkAndUnlockAchievements(DailyQuizCompleted state) {
    // Only check if we have a valid achievement bloc
    if (context.read<AchievementBloc>() == null) return;
    
    // Check for perfect score achievement
    if (state.correctAnswers == state.totalQuestions && state.totalQuestions >= 5) {
      _unlockAchievement(
        id: 'perfect_quiz_achievement',
        name: 'Perfect Quiz Master',
        description: 'Complete a daily quiz with a perfect score',
        icon: 'star',
        tier: 'gold',
      );
    }
    
    // Check for high scorer achievement
    if (state.totalPoints >= 1000) {
      _unlockAchievement(
        id: 'high_scorer_achievement',
        name: 'High Scorer',
        description: 'Score 1000+ points in a single daily quiz',
        icon: 'trophy',
        tier: 'silver',
      );
    }
    
    // Check for winner achievement
    if (state.userRank == 1 && state.participants.length >= 3) {
      _unlockAchievement(
        id: 'quiz_winner_achievement',
        name: 'Quiz Champion',
        description: 'Win first place in a daily quiz with at least 3 participants',
        icon: 'medal',
        tier: 'platinum',
      );
    }
    
    // Check for participation achievement (always unlocked for completing a quiz)
    _unlockAchievement(
      id: 'quiz_participation_achievement',
      name: 'Quiz Enthusiast',
      description: 'Participate in the daily quiz',
      icon: 'quiz',
      tier: 'bronze',
    );
  }
  
  void _unlockAchievement({
    required String id,
    required String name,
    required String description,
    required String icon,
    required String tier,
  }) {
    try {
      final achievement = Achievement(
        id: id,
        name: name,
        description: description,
        icon: icon,
        tier: tier,
        unlockedAt: DateTime.now(),
      );
      
      context.read<AchievementBloc>().add(UnlockAchievement(achievement));
    } catch (e) {
      print('Error unlocking achievement: $e');
    }
  }
  
  void _saveQuizResult(DailyQuizQuestionResult result) {
    // Save each question result for later review
    _quizResults.add({
      'question': result.question,
      'userAnswer': result.userAnswer,
      'isCorrect': result.isCorrect,
      'correctAnswer': result.correctAnswer,
      'explanation': result.explanation,
      'points': result.points,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Quiz - Multiplayer'),
        elevation: 0,
      ),
      body: SafeArea(
        child: BlocListener<SocketBloc, socket_state.SocketState>(
          listener: (context, state) {
            if (state is socket_state.SocketError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Socket error: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocConsumer<DailyQuizBloc, DailyQuizState>(
            listener: (context, state) {
              if (state is DailyQuizQuestionActive) {
                // Start timer when new question is received
                _startTimer(state.timeLimit);
                setState(() {
                  _answerSubmitted = false;
                  _answerController.clear();
                });
              } else if (state is DailyQuizError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is DailyQuizQuestionResult) {
                // Save each question result for review later
                _saveQuizResult(state);
              } else if (state is DailyQuizCompleted) {
                // Check for achievements when quiz is completed
                _checkAndUnlockAchievements(state);
              }
            },
            builder: (context, state) {
              if (state is DailyQuizLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is DailyQuizWaiting) {
                return _buildWaitingScreen(state);
              } else if (state is DailyQuizQuestionActive) {
                return _buildQuestionScreen(state);
              } else if (state is DailyQuizAnswerSubmitted) {
                return _buildAnswerSubmittedScreen(state);
              } else if (state is DailyQuizQuestionResult) {
                return _buildQuestionResultScreen(state);
              } else if (state is DailyQuizCompleted) {
                return _buildCompletedScreen(state);
              } else {
                return const Center(
                  child: Text('Join the daily quiz to compete with others!'),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWaitingScreen(DailyQuizWaiting state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Waiting for the quiz to start...',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(),
          const SizedBox(height: 40),
          const Text(
            'Other participants joining:',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          // Placeholder for participants list
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: LinearProgressIndicator(),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () async {
              // Test the socket connection
              await testDailyQuizSocketConnection();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Check console for connection test results'),
                ),
              );
            },
            icon: const Icon(Icons.network_check),
            label: const Text('Test Socket Connection'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionScreen(DailyQuizQuestionActive state) {
    return Column(
      children: [
        // Timer and question progress
        Container(
          padding: const EdgeInsets.all(16.0),
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${state.questionIndex + 1}/${state.totalQuestions}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              QuizCountdownTimer(seconds: _remainingSeconds),
            ],
          ),
        ),
        
        // Participants list (collapsible)
        ExpansionTile(
          title: Text('Participants (${state.participants.length})'),
          children: [
            ParticipantList(
              participants: state.participants,
              maxHeight: 150,
            ),
          ],
        ),
        
        // Question display
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.question.text,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                // Display options if available
                if (state.question.options.isNotEmpty)
                  ...state.question.options.map((option) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Text('• $option'),
                    );
                  }).toList(),
              ],
            ),
          ),
        ),
        
        // Answer input
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _answerController,
                decoration: InputDecoration(
                  hintText: 'Type your answer...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _answerSubmitted ? null : _submitAnswer,
                  ),
                ),
                enabled: !_answerSubmitted,
                onSubmitted: (_) => _answerSubmitted ? null : _submitAnswer(),
              ),
              if (_answerSubmitted)
                Container(
                  margin: const EdgeInsets.only(top: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('Processing your answer...'),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerSubmittedScreen(DailyQuizAnswerSubmitted state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.done_all,
            size: 80,
            color: Colors.green,
          ),
          const SizedBox(height: 20),
          const Text(
            'Answer submitted!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Your answer: ${state.userAnswer}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 30),
          const Text(
            'Waiting for other players...',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(),
          const SizedBox(height: 40),
          // Participants list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ExpansionTile(
              title: Text('Participants (${state.participants.length})'),
              children: [
                ParticipantList(
                  participants: state.participants,
                  maxHeight: 150,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionResultScreen(DailyQuizQuestionResult state) {
    return Column(
      children: [
        // Question progress
        Container(
          padding: const EdgeInsets.all(16.0),
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${state.questionIndex + 1}/${state.totalQuestions}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Your rank: ${state.userRank}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        
        // Participants list
        ExpansionTile(
          title: Text('Leaderboard (${state.participants.length})'),
          initiallyExpanded: true,
          children: [
            ParticipantList(
              participants: state.participants,
              maxHeight: 150,
            ),
          ],
        ),
        
        // Results display
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.question.text,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  color: state.isCorrect ? Colors.green.shade50 : Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              state.isCorrect ? Icons.check_circle : Icons.cancel,
                              color: state.isCorrect ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              state.isCorrect ? 'Correct!' : 'Incorrect',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: state.isCorrect ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text('Your answer: ${state.userAnswer}'),
                        const SizedBox(height: 8),
                        Text('Correct answer: ${state.correctAnswer}'),
                        const SizedBox(height: 16),
                        Text(
                          state.explanation,
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Points earned:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '+${state.points}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total points:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${state.totalPoints}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedScreen(DailyQuizCompleted state) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16.0),
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events, color: Colors.amber, size: 24),
              const SizedBox(width: 8),
              Text(
                'Quiz Completed!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        
        // Winner section if available
        if (state.winner != null)
          Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber),
            ),
            child: Column(
              children: [
                const Text(
                  'Winner',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${state.winner!['username'] ?? 'Unknown User'}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Score: ${state.winner!['score'] ?? 0} points',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Add reward indicator
                const SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber.shade400),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.amber.shade700, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Earned 1 Day Premium',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
           
        // User results
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                'Your Results',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildResultItem(
                    'Rank',
                    '${state.userRank}',
                    Icons.leaderboard,
                  ),
                  _buildResultItem(
                    'Score',
                    '${state.totalPoints}',
                    Icons.stars,
                  ),
                  _buildResultItem(
                    'Correct',
                    '${state.correctAnswers}/${state.totalQuestions}',
                    Icons.check_circle,
                  ),
                ],
              ),
              // Add streak indicator if available
              if (state.winner?['dailyStreak'] != null) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_fire_department, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      'Daily Streak: ${state.winner!['dailyStreak']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        
        // Achievement unlocked section (if any)
        _buildNewAchievements(),
        
        // Leaderboard
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Leaderboard',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ParticipantList(
                    participants: state.participants,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Action buttons row
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Share results button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _shareQuizResults(state);
                  },
                  icon: Icon(Icons.share),
                  label: Text('Share Results'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Review questions button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _navigateToReviewScreen();
                  },
                  icon: Icon(Icons.question_answer),
                  label: Text('Review Questions'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Return button
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.home),
            label: Text('Return to Home'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 48),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildNewAchievements() {
    return BlocBuilder<AchievementBloc, AchievementState>(
      builder: (context, state) {
        if (state is NewAchievementsUnlocked && state.achievements.isNotEmpty) {
          return Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.teal.shade300),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.emoji_events, color: Colors.teal),
                    const SizedBox(width: 8),
                    Text(
                      'Achievements Unlocked!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...state.achievements.map((achievement) => 
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _getAchievementColor(achievement.tier),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getAchievementIcon(achievement.icon),
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                achievement.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                achievement.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ).toList(),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    context.push(AppRoutePath.achievements);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    minimumSize: Size(200, 36),
                  ),
                  child: const Text('View All Achievements'),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
  
  Color _getAchievementColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'bronze':
        return Colors.brown.shade300;
      case 'silver':
        return Colors.grey.shade400;
      case 'gold':
        return Colors.amber.shade500;
      case 'platinum':
        return Colors.blueGrey.shade400;
      default:
        return Colors.teal;
    }
  }
  
  IconData _getAchievementIcon(String icon) {
    switch (icon.toLowerCase()) {
      case 'star':
        return Icons.star;
      case 'trophy':
        return Icons.emoji_events;
      case 'medal':
        return Icons.military_tech;
      case 'quiz':
        return Icons.quiz;
      default:
        return Icons.emoji_events;
    }
  }
  
  Widget _buildResultItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  void _shareQuizResults(DailyQuizCompleted state) {
    // Show a bottom sheet with the share card
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                height: 6,
                width: 80,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  child: Column(
                    children: [
                      QuizShareCard(
                        score: state.correctAnswers,
                        totalQuestions: state.totalQuestions,
                        rank: state.userRank,
                        totalParticipants: state.participants.length,
                        points: state.totalPoints,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _navigateToReviewScreen() {
    // Navigate to the review screen with quiz results using route helper
    RouteHelper.navigateToQuizReview(context, _quizResults);
  }
} 