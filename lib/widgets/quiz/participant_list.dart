import 'package:flutter/material.dart';

class ParticipantList extends StatelessWidget {
  final List<Map<String, dynamic>> participants;
  final double maxHeight;
  
  const ParticipantList({
    Key? key,
    required this.participants,
    this.maxHeight = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight,
      ),
      child: participants.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('No participants yet'),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              itemCount: participants.length,
              itemBuilder: (context, index) {
                final participant = participants[index];
                final username = participant['username'] ?? 'Unknown User';
                final score = participant['score'] ?? 0;
                final isCurrentUser = participant['isCurrentUser'] ?? false;
                final rank = index + 1;
                
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getRankColor(rank),
                    child: Text(
                      rank.toString(),
                      style: TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  title: Text(
                    username,
                    style: TextStyle(
                      fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                      color: isCurrentUser ? Theme.of(context).primaryColor : null,
                    ),
                  ),
                  trailing: Text(
                    '$score pts',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  tileColor: isCurrentUser ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
                );
              },
            ),
    );
  }
  
  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber; // Gold
      case 2:
        return Colors.blueGrey.shade400; // Silver
      case 3:
        return Colors.brown.shade400; // Bronze
      default:
        return Colors.grey.shade700;
    }
  }
} 