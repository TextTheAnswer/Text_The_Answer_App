import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../blocs/quiz/quiz_bloc.dart';
import '../../blocs/quiz/quiz_state.dart';
import '../../models/question.dart';
import '../../router/routes.dart';

class QuizReviewScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? quizResults;
  
  const QuizReviewScreen({
    Key? key,
    this.quizResults,
  }) : super(key: key);

  @override
  State<QuizReviewScreen> createState() => _QuizReviewScreenState();
}

class _QuizReviewScreenState extends State<QuizReviewScreen> {
  List<Map<String, dynamic>> _quizResults = [];
  int _score = 0;
  int _totalQuestions = 0;
  
  @override
  void initState() {
    super.initState();
    _initializeQuizData();
  }
  
  void _initializeQuizData() {
    if (widget.quizResults != null && widget.quizResults!.isNotEmpty) {
      _quizResults = widget.quizResults!;
      
      // Calculate score
      _totalQuestions = _quizResults.length;
      _score = _quizResults.where((result) => result['isCorrect'] == true).length;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Review'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareResults,
            tooltip: 'Share Results',
          ),
        ],
      ),
      body: _quizResults.isEmpty
          ? _buildEmptyState()
          : _buildReviewContent(),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.quiz_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No quiz results to review',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Take a daily quiz first to see your results here',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go(AppRoutePath.dailyQuizHome),
            child: const Text('Go to Daily Quiz'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildReviewContent() {
    return Column(
      children: [
        _buildSummaryCard(),
        Expanded(
          child: _buildQuestionsList(),
        ),
      ],
    );
  }
  
  Widget _buildSummaryCard() {
    final correctPercentage = _totalQuestions > 0
        ? (_score / _totalQuestions * 100).toInt()
        : 0;
        
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Quiz Performance',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildScoreItem(
                'Score',
                '$_score/$_totalQuestions',
                Icons.score,
              ),
              _buildScoreItem(
                'Accuracy',
                '$correctPercentage%',
                Icons.analytics,
              ),
              _buildScoreItem(
                'Time',
                '10:00',
                Icons.timer,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildScoreItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuestionsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _quizResults.length,
      itemBuilder: (context, index) {
        final result = _quizResults[index];
        final question = result['question'] as Question?;
        final answer = result['userAnswer'] as String?;
        final isCorrect = result['isCorrect'] as bool? ?? false;
        final correctAnswer = result['correctAnswer'] as String?;
        final explanation = result['explanation'] as String?;
        
        return _buildQuestionCard(
          index: index + 1,
          question: question?.text ?? 'Question not available',
          userAnswer: answer ?? 'No answer',
          isCorrect: isCorrect,
          correctAnswer: correctAnswer ?? 'Not available',
          explanation: explanation ?? 'No explanation available',
        );
      },
    );
  }
  
  Widget _buildQuestionCard({
    required int index,
    required String question,
    required String userAnswer,
    required bool isCorrect,
    required String correctAnswer,
    required String explanation,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCorrect ? Colors.green.shade200 : Colors.red.shade200,
          width: 1,
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: isCorrect ? Colors.green : Colors.red,
          child: Icon(
            isCorrect ? Icons.check : Icons.close,
            color: Colors.white,
          ),
        ),
        title: Text(
          'Question $index',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          question,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Question:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(question),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Answer:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userAnswer,
                          style: TextStyle(
                            color: isCorrect ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Correct Answer:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          correctAnswer,
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (explanation.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Explanation:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(explanation),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
  
  void _shareResults() {
    if (_quizResults.isEmpty) {
      return;
    }
    
    final shareText = '''
🧠 I just completed the Text The Answer daily quiz!
✅ Score: $_score/$_totalQuestions (${(_score / _totalQuestions * 100).toInt()}%)
⏱️ Completed in 10 minutes
🏆 Think you can beat my score? Download Text The Answer app now!
''';
    
    Share.share(shareText);
  }
} 