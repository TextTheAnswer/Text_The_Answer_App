import 'package:flutter/material.dart';

class StreakProgressScreen extends StatelessWidget {
  final VoidCallback toggleTheme;

  const StreakProgressScreen({required this.toggleTheme, super.key});

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
                'Streak Progress 🔥',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 20),
              const Text('Current Streak: 3 days'),
            ],
          ),
        ),
      ),
    );
  }
}