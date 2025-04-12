import 'package:flutter/material.dart';

class LeaderboardTile extends StatelessWidget {
  final int rank;
  final String name;
  final int score;

  const LeaderboardTile({
    required this.rank,
    required this.name,
    required this.score,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text('$rank'),
      title: Text(name),
      trailing: Text('$score points'),
    );
  }
}