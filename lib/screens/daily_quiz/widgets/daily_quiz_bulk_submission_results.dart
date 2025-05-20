import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:text_the_answer/blocs/quiz/quiz_bloc.dart';
import 'package:text_the_answer/blocs/quiz/quiz_event.dart';
import 'package:text_the_answer/router/routes.dart';
import 'package:text_the_answer/screens/daily_quiz/widgets/daily_quiz_achievements_section.dart';
import 'package:text_the_answer/screens/daily_quiz/widgets/daily_quiz_answer_result_list.dart';
import 'package:text_the_answer/screens/daily_quiz/widgets/daily_quiz_summary_card.dart';

class DailyQuizBulkSubmissionResults extends StatelessWidget {
  const DailyQuizBulkSubmissionResults({
    super.key,
    required this.summary,
    required this.checkForAchievement,
    required this.newAchievements,
    required this.results,
    required this.clearCollectedAnswer,
  });

  final Map<String, dynamic> summary;
  final ValueChanged<String> checkForAchievement;
  final List<Map<String, dynamic>> newAchievements;
  final List<Map<String, dynamic>> results;
  final VoidCallback clearCollectedAnswer;

  @override
  Widget build(BuildContext context) {
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

      // Check for perfect quiz achievement
      if (percentage == 100 && questionsAnswered >= 5) {
        checkForAchievement('perfect_quiz');
      }
    } else if (percentage >= 60) {
      remarks = 'Good job!';
      remarksColor = Colors.blue;
    } else if (percentage >= 40) {
      remarks = 'Not bad!';
      remarksColor = Colors.orange;
    }

    // Check for streak achievement
    if (streak >= 3) {
      checkForAchievement('streak_master');
    }

    // Check for questions answered achievement
    if (summary['totalQuestionsAnswered'] != null &&
        summary['totalQuestionsAnswered'] >= 50) {
      checkForAchievement('question_milestone');
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

          DailyQuizSummaryCard(
            correctAnswers: correctAnswers,
            questionsAnswered: questionsAnswered,
            totalScore: totalScore,
            streak: streak,
          ),
          SizedBox(height: 24),
          if (newAchievements.isNotEmpty)
            DailyQuizAchievementsSection(achievements: newAchievements),
          SizedBox(height: 24),

          DailyQuizAnswerResultList(results: results),
          SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  // Clear any previous answers when restarting
                  clearCollectedAnswer();
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
}
