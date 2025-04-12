import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/game/game_bloc.dart';
import '../../blocs/game/game_state.dart';

class ResultsScreen extends StatelessWidget {
  final VoidCallback toggleTheme;

  const ResultsScreen({required this.toggleTheme, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<GameBloc, GameState>(
          builder: (context, state) {
            if (state is GameLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is GameResultsLoaded) {
              final results = state.results;
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Game Results 🏆',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 20),
                    Text('Winner: ${results['winner']['name']}'),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: results['players'].length,
                        itemBuilder: (context, index) {
                          final player = results['players'][index];
                          return ListTile(
                            title: Text(player['name']),
                            subtitle: Text('Score: ${player['score']}'),
                            trailing: Text('Correct: ${player['correctAnswers']}'),
                          );
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      child: const Text('Back to Home'),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text('Loading results...'));
          },
        ),
      ),
    );
  }
}