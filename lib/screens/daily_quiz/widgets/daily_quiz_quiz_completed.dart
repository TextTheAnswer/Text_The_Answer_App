import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:text_the_answer/blocs/quiz/quiz_bloc.dart';
import 'package:text_the_answer/blocs/quiz/quiz_event.dart';
import 'package:text_the_answer/models/question.dart';

class DailyQuizQuizCompleted extends StatelessWidget {
  const DailyQuizQuizCompleted({
    super.key,
    required this.questions,
    required this.correctAnswers,
    required this.totalPoints,
    required this.clearCollectedAnswers,
  });

  final List<Question> questions;
  final int correctAnswers;
  final int totalPoints;
  final VoidCallback clearCollectedAnswers;

  @override
  Widget build(BuildContext context) {
    final percentage =
        questions.isEmpty ? 0.0 : (correctAnswers / questions.length) * 100;

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
            'Score: $correctAnswers/${questions.length}',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Total Points: $totalPoints',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // Clear any previous answers when restarting
              clearCollectedAnswers();
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
}
