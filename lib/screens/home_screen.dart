import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'daily_quiz_screen.dart';
import 'game/game_mode_screen.dart';
import 'leaderboard_screen.dart';
import 'profile/profile_screen.dart';
import 'subscription/subscription_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback toggleTheme;

  const HomeScreen({required this.toggleTheme, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back! 👋',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DailyQuizScreen(toggleTheme: toggleTheme),
                    ),
                  );
                },
                child: const Text('Daily Quiz'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GameModeScreen(toggleTheme: toggleTheme),
                    ),
                  );
                },
                child: const Text('Play Multiplayer'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LeaderboardScreen(toggleTheme: toggleTheme),
                    ),
                  );
                },
                child: const Text('Leaderboard'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(toggleTheme: toggleTheme),
                    ),
                  );
                },
                child: const Text('Profile'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SubscriptionScreen(toggleTheme: toggleTheme),
                    ),
                  );
                },
                child: const Text('Go Premium'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SettingsScreen(toggleTheme: toggleTheme),
                    ),
                  );
                },
                child: const Text('Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}