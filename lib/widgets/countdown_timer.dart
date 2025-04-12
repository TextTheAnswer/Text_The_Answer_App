import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final int seconds;

  const CountdownTimer({required this.seconds, super.key});

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.seconds),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Text(
          '${(widget.seconds * _controller.value).ceil()}s',
          style: Theme.of(context).textTheme.headlineLarge,
        );
      },
    );
  }
}