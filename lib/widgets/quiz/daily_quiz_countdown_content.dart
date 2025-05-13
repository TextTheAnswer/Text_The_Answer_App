import 'dart:async';

import 'package:flutter/material.dart';
import 'package:text_the_answer/utils/constants/breakpoint.dart';
import 'package:text_the_answer/utils/quiz/time_utility.dart';

class DailyQuizCountdownContent extends StatefulWidget {
  const DailyQuizCountdownContent({super.key, this.dailyQuizData});

  final Map<String, dynamic>? dailyQuizData;

  @override
  State<DailyQuizCountdownContent> createState() =>
      _DailyQuizCountdownContentState();
}

class _DailyQuizCountdownContentState extends State<DailyQuizCountdownContent> {
  Timer? _timer;
  late DateTime _now;
  DateTime? _nextQuizTime;
  bool _quizAvailable = false;

  Duration get _remaining => _nextQuizTime?.difference(_now) ?? Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeTimes();
    _startTimer();
  }

  void _initializeTimes() {
    _nextQuizTime = _parseNextQuizTime(widget.dailyQuizData);
    _now = DateTime.now();
    _updateAvailability();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _now = DateTime.now();
        _updateAvailability();
      });
    });
  }

  void _updateAvailability() {
    _quizAvailable = _remaining <= Duration.zero;
  }

  DateTime _parseNextQuizTime(Map<String, dynamic>? data) {
    try {
      if (data?['nextAvailable'] != null) {
        return DateTime.parse(data!['nextAvailable']);
      }
    } catch (_) {}
    // -- Fallback
    return QuizTimeUtility.getNextEventTime();
  }

  bool _hasTakenTodaysQuiz() {
    try {
      final last = DateTime.parse(widget.dailyQuizData?['lastCompleted'] ?? '');
      final now = DateTime.now();
      return last.year == now.year &&
          last.month == now.month &&
          last.day == now.day;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int h, int m, int s) =>
      '${_pad(h)}hrs ${_pad(m)}m ${_pad(s)}s';

  String _pad(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final hasTaken = _hasTakenTodaysQuiz();
    final remaining = _quizAvailable ? Duration.zero : _remaining;

    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: kStandardContentWidth),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(
              top: 30,
              bottom: 30,
              left: 30,
              right: 10,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  const Color.fromARGB(255, 47, 40, 110),
                  const Color.fromARGB(255, 25, 21, 61),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -- Daily Quiz Challenge Text
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Daily Quiz',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      'Challenge',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // -- Next Daily Quiz
                Row(
                  children: [
                    // -- Next quiz available in:
                    Text(
                      hasTaken
                          ? 'You\'ve completed today\'s quiz!'
                          : _quizAvailable
                          ? "Today's quiz is available!"
                          : 'Next quiz available in: ',
                      style: TextStyle(color: Colors.white),
                    ),

                    // -- Timer
                    if (!_quizAvailable && !hasTaken)
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _formatTime(hours, minutes, seconds),
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                // -- Quiz Coming soon
                Center(
                  child: ElevatedButton(
                    onPressed:
                        hasTaken
                            ? () {}
                            : _quizAvailable
                            ? () {}
                            : null,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 76, 71, 177),
                      disabledBackgroundColor: Color.fromARGB(
                        255,
                        76,
                        71,
                        177,
                      ).withValues(alpha: 0.7),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      disabledForegroundColor: Colors.white.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    child: const Text("Quiz Coming Soon"),
                  ),
                ),
              ],
            ),
          ),

          // -- Bubble Avater
          Positioned(
            top: -10,
            right: -10,
            child: SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                children: [
                  _DailyQuizContainerFloatingBubble(
                    offset: Offset(40, 0),
                    size: 32,
                  ),
                  _DailyQuizContainerFloatingBubble(
                    offset: Offset(10, 20),
                    size: 40,
                  ),
                  _DailyQuizContainerFloatingBubble(
                    offset: Offset(60, 60),
                    size: 36,
                  ),
                  _DailyQuizContainerFloatingBubble(
                    offset: Offset(20, 70),
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyQuizContainerFloatingBubble extends StatelessWidget {
  const _DailyQuizContainerFloatingBubble({
    required this.offset,
    this.size = 36,
  });

  final Offset offset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          image: DecorationImage(
            image: AssetImage('assets/avatar1.png'),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}
