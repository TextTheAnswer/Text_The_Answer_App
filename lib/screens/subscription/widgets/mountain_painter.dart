import 'package:flutter/material.dart';
import 'dart:math' as math;

class RoundedStarPainter extends CustomPainter {
  final int points;
  final Color fillColor;
  final Color borderColor;
  final double strokeWidth;

  RoundedStarPainter({
    this.points = 5,
    this.fillColor = Colors.white,
    this.borderColor = Colors.amber,
    this.strokeWidth = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double outerRadius = math.min(size.width, size.height) / 2;
    final double innerRadius = outerRadius / 2.5;
    final Offset center = Offset(size.width / 2, size.height / 2);

    final Path starPath = Path();
    final double angle = math.pi / points;

    for (int i = 0; i < points * 2; i++) {
      final double r = i.isEven ? outerRadius : innerRadius;
      final double x = center.dx + r * math.cos(i * angle - math.pi / 2);
      final double y = center.dy + r * math.sin(i * angle - math.pi / 2);
      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
    }
    starPath.close();

    // Fill first
    final Paint fillPaint =
        Paint()
          ..color = fillColor
          ..style = PaintingStyle.fill;
    canvas.drawPath(starPath, fillPaint);

    // Then stroke with rounded edges
    final Paint borderPaint =
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round;
    canvas.drawPath(starPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
