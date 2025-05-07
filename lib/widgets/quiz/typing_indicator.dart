import 'package:flutter/material.dart';

class TypingProgressIndicator extends StatefulWidget {
  final TextEditingController controller;
  final double maxWidth;
  final Color color;
  
  const TypingProgressIndicator({
    super.key,
    required this.controller,
    required this.maxWidth,
    this.color = Colors.blue,
  });

  @override
  State<TypingProgressIndicator> createState() => _TypingProgressIndicatorState();
}

class _TypingProgressIndicatorState extends State<TypingProgressIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _progress = 0.0;
  
  @override
  void initState() {
    super.initState();
    
    // Setup animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    // Listen to text changes
    widget.controller.addListener(_updateProgress);
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    widget.controller.removeListener(_updateProgress);
    super.dispose();
  }
  
  void _updateProgress() {
    // Simple calculation - adjust this based on your expected answer length
    final expectedMaxLength = 30; // Expected max length of a typical answer
    final currentLength = widget.controller.text.length;
    final newProgress = currentLength > 0 
        ? (currentLength / expectedMaxLength).clamp(0.0, 1.0)
        : 0.0;
    
    setState(() {
      _progress = newProgress;
    });
    
    if (newProgress > 0) {
      _animationController.animateTo(newProgress);
    } else {
      _animationController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              width: widget.maxWidth,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Row(
                children: [
                  Container(
                    width: widget.maxWidth * _animation.value * _progress,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _getProgressColor(),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        _buildLabel(),
      ],
    );
  }
  
  Widget _buildLabel() {
    // Only show the label if typing has started
    if (_progress <= 0) {
      return const SizedBox.shrink();
    }
    
    return Text(
      'Typing...',
      style: TextStyle(
        color: Colors.grey.shade600,
        fontSize: 12,
      ),
    );
  }
  
  Color _getProgressColor() {
    // Change color based on progress
    if (_progress < 0.3) {
      return Colors.red;
    } else if (_progress < 0.7) {
      return Colors.orange;
    } else {
      return widget.color;
    }
  }
} 