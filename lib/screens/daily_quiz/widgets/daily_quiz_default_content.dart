import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:text_the_answer/blocs/quiz/quiz_bloc.dart';
import 'package:text_the_answer/blocs/quiz/quiz_event.dart';

class DailyQuizDefaultContent extends StatelessWidget {
  const DailyQuizDefaultContent({
    super.key,
    required this.clearCollectedAnswers,
  });

  final VoidCallback clearCollectedAnswers;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              // -- QUiz Icon
              Icon(Icons.quiz, size: 64, color: Theme.of(context).primaryColor),
              SizedBox(height: 16),

              // -- Daily Quiz
              Text(
                'Daily Quiz 🧠',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),

              // -- Test your knowledge
              Text(
                'Test your knowledge with our daily quiz challenge!',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),

              // -- Today's winner container
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: .1),
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

              // -- Start Quiz Button
              ElevatedButton(
                onPressed: () {
                  // Clear any previous answers when starting a new quiz
                  clearCollectedAnswers();
                  context.read<QuizBloc>().add(FetchDailyQuiz());
                },
                style: ElevatedButton.styleFrom(minimumSize: Size(200, 48)),
                child: const Text('Start Daily Quiz'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
