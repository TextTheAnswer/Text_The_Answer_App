import 'package:flutter/material.dart';

class QuizCountdownTimer extends StatelessWidget {
  final int seconds;
  
  const QuizCountdownTimer({
    Key? key,
    required this.seconds,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color timerColor;
    if (seconds > 10) {
      timerColor = Colors.green;
    } else if (seconds > 5) {
      timerColor = Colors.orange;
    } else {
      timerColor = Colors.red;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: timerColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: timerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: 18,
            color: timerColor,
          ),
          SizedBox(width: 4),
          Text(
            '$seconds',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: timerColor,
            ),
          ),
        ],
      ),
    );
  }
} 