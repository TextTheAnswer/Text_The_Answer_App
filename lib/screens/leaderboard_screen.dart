import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/leaderboard/leaderboard_bloc.dart';
import '../blocs/leaderboard/leaderboard_event.dart';
import '../blocs/leaderboard/leaderboard_state.dart';

class LeaderboardScreen extends StatelessWidget {
  final VoidCallback toggleTheme;

  const LeaderboardScreen({required this.toggleTheme, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<LeaderboardBloc, LeaderboardState>(
          listener: (context, state) {
            if (state is LeaderboardError) {
              print('LeaderboardScreen Error: ${state.message}'); // Debug statement
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is LeaderboardLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is LeaderboardLoaded) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Leaderboard 🏆',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 20),
                    Text('Your Rank: ${state.userRank}'),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.leaderboard.length,
                        itemBuilder: (context, index) {
                          final entry = state.leaderboard[index];
                          return ListTile(
                            leading: Text('${entry.rank}'),
                            title: Text(entry.name),
                            trailing: Text('${entry.score} points'),
                          );
                        },
                      ),
                    ),
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
                    'Leaderboard 🏆',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<LeaderboardBloc>().add(FetchDailyLeaderboard());
                    },
                    child: const Text('Load Leaderboard'),
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