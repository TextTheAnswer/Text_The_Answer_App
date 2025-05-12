import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../blocs/daily_quiz/daily_quiz_bloc.dart';
import '../../blocs/daily_quiz/daily_quiz_event.dart';
import '../../blocs/daily_quiz/daily_quiz_state.dart';
import '../../router/routes.dart';
import '../../utils/quiz/time_utility.dart';
import '../../widgets/quiz/daily_quiz_countdown.dart';

class DailyQuizHomeScreen extends StatefulWidget {
  const DailyQuizHomeScreen({Key? key}) : super(key: key);

  @override
  State<DailyQuizHomeScreen> createState() => _DailyQuizHomeScreenState();
}

class _DailyQuizHomeScreenState extends State<DailyQuizHomeScreen> {
  final Map<String, dynamic> _quizMetadata = {
    'theme': 'Science & Technology',
    'duration': '10 minutes',
    'questions': 10,
    'difficulty': 'Mixed',
    'nextQuizTime': QuizTimeUtility.getNextEventTime(),
  };

  @override
  void initState() {
    super.initState();
    _fetchQuizMetadata();
  }

  Future<void> _fetchQuizMetadata() async {
    // In a real implementation, this would fetch the metadata from the server
    // For now, we'll use placeholder data
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Quiz'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Daily Quiz Countdown Card
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DailyQuizCountdown(
                dailyQuizData: {
                  'nextAvailable': _quizMetadata['nextQuizTime'].toIso8601String(),
                },
              ),
            ),

            // Quiz Info Card
            _buildQuizInfoCard(),

            // How to Play Card
            _buildHowToPlayCard(),

            // Previous Results Card
            _buildPreviousResultsCard(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  Widget _buildQuizInfoCard() {
    final nextQuizTime = _quizMetadata['nextQuizTime'] as DateTime;
    final isQuizToday = nextQuizTime.day == DateTime.now().day;
    
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  isQuizToday ? "Today's Quiz Info" : "Next Quiz Info",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.category, 'Theme', _quizMetadata['theme']),
            _buildInfoRow(Icons.timer, 'Estimated Duration', _quizMetadata['duration']),
            _buildInfoRow(Icons.question_mark_rounded, 'Questions', '${_quizMetadata['questions']}'),
            _buildInfoRow(Icons.trending_up, 'Difficulty', _quizMetadata['difficulty']),
            _buildInfoRow(
              Icons.event,
              'Scheduled Time',
              DateFormat('hh:mm a').format(nextQuizTime),
            ),
            const SizedBox(height: 16),
            Text(
              'All participants take the quiz simultaneously in real-time. Text your answers to each question before the timer runs out!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800]),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(color: Colors.grey[900]),
          ),
        ],
      ),
    );
  }

  Widget _buildHowToPlayCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.help_outline, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'How to Play',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildHowToPlayStep(
              '1',
              'Join at 9 AM UTC',
              'All participants start together once the quiz begins',
            ),
            _buildHowToPlayStep(
              '2',
              'Answer Text Questions',
              'Type your answers instead of selecting from options',
            ),
            _buildHowToPlayStep(
              '3',
              'Be Quick & Accurate',
              'Faster correct answers earn more points',
            ),
            _buildHowToPlayStep(
              '4',
              'Compete in Real-Time',
              'See the leaderboard update as others submit answers',
            ),
            _buildHowToPlayStep(
              '5',
              'Win Rewards',
              'Top performer wins a premium subscription for a day',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowToPlayStep(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviousResultsCard() {
    // This would show the user's previous quiz results
    // For now, it's a placeholder
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Your Previous Results',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.show_chart,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Complete your first daily quiz to see your results',
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      context.push(AppRoutePath.leaderboard);
                    },
                    child: const Text('View Leaderboard'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    final nextQuizTime = _quizMetadata['nextQuizTime'] as DateTime;
    final now = DateTime.now();
    final isQuizAvailable = now.isAfter(nextQuizTime) || 
                            (now.day == nextQuizTime.day && 
                             now.hour == nextQuizTime.hour && 
                             now.minute >= nextQuizTime.minute);
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: isQuizAvailable 
              ? () {
                  context.push(AppRoutePath.dailyQuizRealtime);
                }
              : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            isQuizAvailable ? 'Join Quiz Now' : 'Quiz Not Available Yet',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
} 