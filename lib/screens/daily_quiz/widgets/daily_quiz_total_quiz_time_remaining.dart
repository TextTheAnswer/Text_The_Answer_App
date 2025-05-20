import 'package:flutter/material.dart';

class DailyQuizTotalQuizTimeRemaining extends StatelessWidget {
  const DailyQuizTotalQuizTimeRemaining({
    super.key,
    required this.totalTimeRemaining,
  });

  final Duration totalTimeRemaining;

  @override
  Widget build(BuildContext context) {
    final minutes = totalTimeRemaining.inMinutes;
    final seconds = (totalTimeRemaining.inSeconds % 60);
    final milliseconds =
        (totalTimeRemaining.inMilliseconds % 1000) ~/
        10; // Show only tens of milliseconds

    // Format as MM:SS:mm
    final secondsStr = seconds.toString().padLeft(2, '0');
    final millisecondsStr = milliseconds.toString().padLeft(2, '0');

    // Determine color based on time remaining
    Color timerColor;
    if (minutes < 1) {
      timerColor = Colors.red;
    } else if (minutes < 3) {
      timerColor = Colors.orange;
    } else {
      timerColor = Colors.blue;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: timerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: timerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timelapse, size: 16, color: timerColor),
          SizedBox(width: 4),
          Text(
            'Quiz Time: $minutes:$secondsStr:$millisecondsStr',
            style: TextStyle(fontWeight: FontWeight.bold, color: timerColor),
          ),
        ],
      ),
    );
  }
}
