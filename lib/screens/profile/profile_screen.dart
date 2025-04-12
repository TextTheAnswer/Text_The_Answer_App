import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import 'edit_profile_screen.dart';
import 'game_history_screen.dart';
import 'streak_progress_screen.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback toggleTheme;

  const ProfileScreen({required this.toggleTheme, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AuthAuthenticated) {
              final user = state.user;
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile 👤',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 20),
                    Text('Username: ${user.name}'),
                    const SizedBox(height: 10),
                    Text('Email: ${user.email}'),
                    const SizedBox(height: 10),
                    Text('Subscription: ${user.subscription}'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditProfileScreen(toggleTheme: toggleTheme),
                          ),
                        );
                      },
                      child: const Text('Edit Profile'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GameHistoryScreen(toggleTheme: toggleTheme),
                          ),
                        );
                      },
                      child: const Text('Game History'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StreakProgressScreen(toggleTheme: toggleTheme),
                          ),
                        );
                      },
                      child: const Text('Streak Progress'),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text('Error loading profile'));
          },
        ),
      ),
    );
  }
}