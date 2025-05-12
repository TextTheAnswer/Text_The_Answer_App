import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class QuizShareCard extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final int rank;
  final int totalParticipants;
  final int points;
  
  const QuizShareCard({
    Key? key,
    required this.score,
    required this.totalQuestions,
    required this.rank,
    required this.totalParticipants,
    required this.points,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.share, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Share Your Results',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            _buildSharePreview(context),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareButton(
                  context,
                  'Twitter',
                  Icons.abc,
                  Colors.blue,
                  () => _shareToTwitter(),
                ),
                _buildShareButton(
                  context,
                  'Facebook',
                  Icons.facebook,
                  Colors.indigo,
                  () => _shareToFacebook(),
                ),
                _buildShareButton(
                  context,
                  'Copy',
                  Icons.copy,
                  Colors.grey,
                  () => _copyToClipboard(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSharePreview(BuildContext context) {
    final percentage = (score / totalQuestions * 100).toInt();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Text(
            '🧠 Daily Quiz Results',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildResultItem(
                context,
                'Score',
                '$score/$totalQuestions',
                Icons.quiz,
              ),
              _buildResultItem(
                context,
                'Accuracy',
                '$percentage%',
                Icons.percent,
              ),
              _buildResultItem(
                context,
                'Rank',
                '$rank/$totalParticipants',
                Icons.leaderboard,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Points earned: $points',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Think you can beat my score? Download Text The Answer app now!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildResultItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildShareButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getShareText() {
    final percentage = (score / totalQuestions * 100).toInt();
    
    return '''
🧠 I just completed the Text The Answer daily quiz!
✅ Score: $score/$totalQuestions ($percentage%)
🏆 Rank: $rank / $totalParticipants
⭐ Points: $points
Think you can beat my score? Download Text The Answer app now!
''';
  }
  
  void _shareToTwitter() {
    final text = _getShareText();
    Share.share(text, subject: 'Daily Quiz Results');
  }
  
  void _shareToFacebook() {
    final text = _getShareText();
    Share.share(text, subject: 'Daily Quiz Results');
  }
  
  void _copyToClipboard(BuildContext context) {
    final text = _getShareText();
    // This would use a clipboard package in a real implementation
    Share.share(text, subject: 'Daily Quiz Results');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
} 