import 'package:flutter/material.dart';

class DailyQuizResultWithAwards extends StatelessWidget {
  const DailyQuizResultWithAwards({super.key, required this.isWinner});

  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Quiz Results',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: 24),

          // Premium award notice if user is the winner
          if (isWinner)
            Container(
              margin: EdgeInsets.only(bottom: 24),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events, color: Colors.amber, size: 32),
                      SizedBox(width: 8),
                      Text(
                        'CONGRATULATIONS!',
                        style: TextStyle(
                          color: Colors.amber.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'You\'ve won 1 month of FREE premium access!',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your premium features have been activated.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

          // Regular results display (use existing methods)
          // Implementation depends on available data in QuizResultsState

          // Button to return to home
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.home),
            label: Text('Return to Home'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
