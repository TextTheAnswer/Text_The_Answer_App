import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/quiz/quiz_bloc.dart';
import '../blocs/quiz/quiz_event.dart';
import '../blocs/quiz/quiz_state.dart';

class DailyQuizScreen extends StatelessWidget {
  final VoidCallback toggleTheme;

  const DailyQuizScreen({required this.toggleTheme, super.key});

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
                      ? 'Correct! ${state.explanation}'
                      : 'Incorrect. ${state.explanation}'),
                  backgroundColor: state.isCorrect ? Colors.green : Colors.orange,
                ),
              );
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
                    Text(
                      'Daily Quiz ❓',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Questions Answered: ${state.questionsAnswered}/${questions.length}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Correct Answers: ${state.correctAnswers}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    if (state.questionsAnswered < questions.length)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            questions[state.questionsAnswered].text,
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 18),
                          ),
                          const SizedBox(height: 20),
                          ...questions[state.questionsAnswered].options.map((option) => 
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  final index = questions[state.questionsAnswered].options.indexOf(option);
                                  context.read<QuizBloc>().add(
                                    SubmitQuizAnswer(
                                      questionId: questions[state.questionsAnswered].id,
                                      answer: index,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(double.infinity, 48),
                                ),
                                child: Text(option),
                              ),
                            ),
                          ).toList(),
                        ],
                      )
                    else
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, size: 64, color: Colors.green),
                            SizedBox(height: 16),
                            Text(
                              'You have completed the daily quiz!',
                              style: Theme.of(context).textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Your score: ${state.correctAnswers}/${questions.length}',
                              style: Theme.of(context).textTheme.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
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
                      'Daily Quiz ❓',
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
}