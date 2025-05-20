import 'package:flutter/material.dart';

class DailyQuizProcessing extends StatelessWidget {
  const DailyQuizProcessing({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 24),
            Text(
              'Processing your answers...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Please wait while we check your responses.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
