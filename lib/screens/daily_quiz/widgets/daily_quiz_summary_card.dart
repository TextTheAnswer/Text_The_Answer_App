import 'package:flutter/material.dart';

class DailyQuizSummaryCard extends StatelessWidget {
  const DailyQuizSummaryCard({
    super.key,
    required this.correctAnswers,
    required this.questionsAnswered,
    required this.totalScore,
    required this.streak,
  });

  final int correctAnswers;
  final int questionsAnswered;
  final int totalScore;
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Summary', style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SummaryItem(
                  label: 'Score',
                  value: '$correctAnswers/$questionsAnswered',
                  icon: Icons.check_circle,
                ),
                _SummaryItem(
                  label: 'Points',
                  value: '$totalScore',
                  icon: Icons.stars,
                ),
                _SummaryItem(
                  label: 'Streak',
                  value: '$streak',
                  icon: Icons.local_fire_department,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).primaryColor),
        SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
