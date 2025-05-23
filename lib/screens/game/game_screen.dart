import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:text_the_answer/blocs/game/game_bloc.dart';
import 'package:text_the_answer/blocs/game/game_event.dart';
import 'package:text_the_answer/blocs/game/game_state.dart';
import 'package:text_the_answer/models/question.dart';
import '../../utils/theme/theme_cubit.dart';
import '../../widgets/common/theme_aware_widget.dart';

class GameScreen extends StatefulWidget {
  final String gameId;
  final List<Question> questions;
  final List<dynamic> players;
  final VoidCallback toggleTheme;

  const GameScreen({
    required this.gameId,
    required this.questions,
    required this.players,
    required this.toggleTheme,
    super.key,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int currentQuestionIndex = 0;

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
  Widget build(BuildContext context) {
    return ThemeAwareWidget(
      builder: (context, themeState) {
        return Scaffold(
          body: SafeArea(
            child: BlocConsumer<GameBloc, GameState>(
              listener: (context, state) {
                if (state is GameError) {
                  print('GameScreen Error: ${state.message}'); // Debug statement
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                } else if (state is GameAnswerSubmitted) {
                  if (state.allAnswered) {
                    context.read<GameBloc>().add(FetchGameResults(gameId: widget.gameId));
                  } else {
                    setState(() {
                      currentQuestionIndex++;
                    });
                  }
                }
              },
              builder: (context, state) {
                if (state is GameLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (currentQuestionIndex >= widget.questions.length) {
                  return const Center(child: Text('Waiting for other players...'));
                }

                final question = widget.questions[currentQuestionIndex];
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Question ${currentQuestionIndex + 1}/${widget.questions.length} ❓',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 20),
                      Text(question.text),
                      const SizedBox(height: 20),
                      ...List.generate(
                        question.options.length,
                        (index) => ElevatedButton(
                          onPressed: () {
                            context.read<GameBloc>().add(
                                  SubmitGameAnswer(
                                    gameId: widget.gameId,
                                    questionIndex: currentQuestionIndex,
                                    answer: question.options[index],
                                  ),
                                );
                          },
                          child: Text(question.options[index]),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}