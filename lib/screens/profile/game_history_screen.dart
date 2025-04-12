import 'package:flutter/material.dart';

class GameHistoryScreen extends StatelessWidget {
  final VoidCallback toggleTheme;

  const GameHistoryScreen({required this.toggleTheme, super.key});

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
                'Game History 📜',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 20),
              const Text('Game 1: Score 850'),
              const Text('Game 2: Score 920'),
            ],
          ),
        ),
      ),
    );
  }
}