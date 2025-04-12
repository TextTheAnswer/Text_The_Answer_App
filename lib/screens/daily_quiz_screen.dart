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
              print('DailyQuizScreen Error: ${state.message}'); // Debug statement
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is QuizAnswerSubmitted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.isCorrect
                      ? 'Correct! ${state.explanation}'
                      : 'Incorrect. ${state.explanation}'),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is QuizLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is QuizLoaded) {
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
                          ...List.generate(
                            questions[state.questionsAnswered].options.length,
                            (index) => ElevatedButton(
                              onPressed: () {
                                context.read<QuizBloc>().add(
                                      SubmitQuizAnswer(
                                        questionId: questions[state.questionsAnswered].id,
                                        answer: index,
                                      ),
                                    );
                              },
                              child: Text(questions[state.questionsAnswered].options[index]),
                            ),
                          ),
                        ],
                      )
                    else
                      const Text('You have completed the daily quiz!'),
                  ],
                ),
              );
            }
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
                  ElevatedButton(
                    onPressed: () {
                      context.read<QuizBloc>().add(FetchDailyQuiz());
                    },
                    child: const Text('Start Daily Quiz'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}