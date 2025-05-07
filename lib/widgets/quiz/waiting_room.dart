import 'dart:async';
import 'package:flutter/material.dart';
import '../../utils/quiz/time_utility.dart';

class WaitingRoomWidget extends StatefulWidget {
  final DateTime eventTime;
  final String theme;
  final int participantCount;
  final VoidCallback onEventStart;

  const WaitingRoomWidget({
    super.key,
    required this.eventTime,
    required this.theme,
    required this.participantCount,
    required this.onEventStart,
  });

  @override
  State<WaitingRoomWidget> createState() => _WaitingRoomWidgetState();
}

class _WaitingRoomWidgetState extends State<WaitingRoomWidget> {
  Timer? _timer;
  int _secondsRemaining = 0;
  
  @override
  void initState() {
    super.initState();
    _calculateSecondsRemaining();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  void _calculateSecondsRemaining() {
    final now = DateTime.now();
    final diff = widget.eventTime.difference(now);
    setState(() {
      _secondsRemaining = diff.inSeconds;
    });
  }
  
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 0) {
        timer.cancel();
        widget.onEventStart();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }
  
  String get _formattedTime {
    final minutes = (_secondsRemaining / 60).floor();
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.timer,
            size: 64,
            color: Colors.blue,
          ),
          const SizedBox(height: 24),
          Text(
            'Event starting soon',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _formattedTime,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Today\'s theme: ${widget.theme}',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildQuizRules(),
          const SizedBox(height: 32),
          _buildParticipantsCounter(),
        ],
      ),
    );
  }
  
  Widget _buildQuizRules() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quiz Rules',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildRuleItem(
            context,
            Icons.timer_outlined,
            'You have 15 seconds to answer each question',
          ),
          _buildRuleItem(
            context,
            Icons.speed_outlined,
            'Answer faster for more points',
          ),
          _buildRuleItem(
            context,
            Icons.check_circle_outline,
            'Type your answer precisely - spelling counts!',
          ),
          _buildRuleItem(
            context,
            Icons.emoji_events_outlined,
            'Top performer wins free premium access',
          ),
        ],
      ),
    );
  }
  
  Widget _buildRuleItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildParticipantsCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.people, color: Colors.blue),
          const SizedBox(width: 12),
          Text(
            '${widget.participantCount} participants',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
} 