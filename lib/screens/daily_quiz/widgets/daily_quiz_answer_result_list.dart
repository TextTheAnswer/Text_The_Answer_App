import 'package:flutter/material.dart';

class DailyQuizAnswerResultList extends StatelessWidget {
  const DailyQuizAnswerResultList({super.key, required this.results});

  final List<Map<String, dynamic>> results;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question Details',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final result = results[index];
                    return Card(
                      color:
                          result['isCorrect'] == true
                              ? Colors.green.withValues(alpha: .1)
                              : Colors.red.withValues(alpha: .1),
                      margin: EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Question ${index + 1}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  result['isCorrect'] == true
                                      ? '+${result['points']} points'
                                      : '0 points',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        result['isCorrect'] == true
                                            ? Colors.green
                                            : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text('${result['explanation']}'),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  'Correct answer: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text('${result['correctAnswer']}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
