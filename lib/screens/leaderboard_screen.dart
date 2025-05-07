import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/leaderboard/leaderboard_bloc.dart';
import '../blocs/leaderboard/leaderboard_event.dart';
import '../blocs/leaderboard/leaderboard_state.dart';
import '../widgets/quiz/daily_leaderboard.dart';

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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is LeaderboardLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is LeaderboardLoaded) {
              return DailyLeaderboardWidget(
                leaderboardEntries: state.leaderboard,
                userRank: state.userRank,
                userScore: state.userScore,
                theme: state.theme,
                winner: state.winner,
                lastUpdated: state.lastUpdated,
                refreshLeaderboard: () async {
                  context.read<LeaderboardBloc>().add(RefreshLeaderboard());
                  // Return a resolved future to complete the refresh indicator
                  return Future.value();
                },
              );
            }
            
            // Initial state
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.leaderboard_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Daily Leaderboard',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<LeaderboardBloc>().add(FetchDailyLeaderboard());
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
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