import 'dart:async';
import 'package:flutter/material.dart';
import '../../utils/quiz/time_utility.dart';
import 'package:go_router/go_router.dart';
import '../../router/routes.dart';

@Deprecated("Depreated in favour of DailyQuizCountdownContent")
class DailyQuizCountdown extends StatefulWidget {
  final Map<String, dynamic>? dailyQuizData;

  const DailyQuizCountdown({super.key, this.dailyQuizData});

  @override
  State<DailyQuizCountdown> createState() => _DailyQuizCountdownState();
}

class _DailyQuizCountdownState extends State<DailyQuizCountdown> {
  Timer? _timer;
  Map<String, int> _timeRemaining = {'hours': 0, 'minutes': 0, 'seconds': 0};
  bool _quizAvailable = false;
  DateTime? _nextQuizTime;

  @override
  void initState() {
    super.initState();
    _updateNextQuizTime();
    _updateTimeRemaining();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateNextQuizTime() {
    // Check if we have quiz data from the profile
    if (widget.dailyQuizData != null &&
        widget.dailyQuizData!.containsKey('nextAvailable')) {
      try {
        // Convert the nextAvailable timestamp to DateTime
        final nextAvailable = DateTime.parse(
          widget.dailyQuizData!['nextAvailable'],
        );
        _nextQuizTime = nextAvailable;
      } catch (e) {
        // If there's an error parsing the date, fallback to utility method
        _nextQuizTime = QuizTimeUtility.getNextEventTime();
      }
    } else {
      // If no quiz data is available, use the utility method
      _nextQuizTime = QuizTimeUtility.getNextEventTime();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimeRemaining();
    });
  }

  void _updateTimeRemaining() {
    final now = DateTime.now();
    final diff = _nextQuizTime!.difference(now);

    setState(() {
      if (diff.isNegative) {
        // Quiz is available now
        _timeRemaining = {'hours': 0, 'minutes': 0, 'seconds': 0};
        _quizAvailable = true;
      } else {
        _timeRemaining = {
          'hours': diff.inHours,
          'minutes': (diff.inMinutes % 60),
          'seconds': (diff.inSeconds % 60),
        };
        _quizAvailable = false;
      }
    });
  }

  bool _hasTakenTodaysQuiz() {
    if (widget.dailyQuizData == null) return false;

    // Check if lastCompleted exists and is today
    if (widget.dailyQuizData!.containsKey('lastCompleted')) {
      try {
        final lastCompleted = DateTime.parse(
          widget.dailyQuizData!['lastCompleted'],
        );
        final now = DateTime.now();

        return lastCompleted.year == now.year &&
            lastCompleted.month == now.month &&
            lastCompleted.day == now.day;
      } catch (e) {
        return false;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final hours = _timeRemaining['hours'] ?? 0;
    final minutes = _timeRemaining['minutes'] ?? 0;
    final seconds = _timeRemaining['seconds'] ?? 0;

    final bool alreadyTakenToday = _hasTakenTodaysQuiz();

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 400),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade700, Colors.purple.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -- Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.quiz, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Daily Quiz Challenge',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (_nextQuizTime != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      QuizTimeUtility.formatEventTime(_nextQuizTime!),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Status message
            Text(
              alreadyTakenToday
                  ? 'You\'ve completed today\'s quiz!'
                  : (_quizAvailable
                      ? 'Quiz is available now!'
                      : 'Next quiz available in:'),
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),

            if (!alreadyTakenToday && !_quizAvailable) ...[
              const SizedBox(height: 16),
              // Countdown timer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTimeBox(context, hours, 'hrs'),
                  const SizedBox(width: 8),
                  const Text(
                    ':',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildTimeBox(context, minutes, 'min'),
                  const SizedBox(width: 8),
                  const Text(
                    ':',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildTimeBox(context, seconds, 'sec'),
                ],
              ),
            ],

            const SizedBox(height: 16),

            // Take quiz or view results button
            Center(
              child: ElevatedButton(
                onPressed:
                    alreadyTakenToday
                        ? () {
                          // Go to quiz results page
                          context.push(AppRoutePath.leaderboard);
                        }
                        : (_quizAvailable
                            ? () {
                              // Go to take quiz page
                              context.push(AppRoutePath.dailyQuiz);
                            }
                            : null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.purple.shade700,
                  disabledBackgroundColor: Colors.white.withOpacity(0.3),
                  disabledForegroundColor: Colors.white.withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  alreadyTakenToday
                      ? 'View Leaderboard'
                      : (_quizAvailable
                          ? 'Take Quiz Now!'
                          : 'Quiz Coming Soon'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeBox(BuildContext context, int value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value.toString().padLeft(2, '0'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
