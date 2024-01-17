import 'dart:math';
import 'package:flutter/material.dart';

class ArcPainter extends CustomPainter {
  final double progress; // Add a progress parameter

  ArcPainter({required this.progress}); // Constructor that initializes progress

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.lightBlueAccent
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    final double finalprogress = (progress/100) * 360; // Use 360 degrees for a full circle
    final double radius = size.width * 0.93 / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    // Calculate the sweep angle based on the progress
    final double sweepAngle = 2 * pi * finalprogress / 360; // Use positive angle for clockwise direction

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // start angle (offset by -pi/2 to start from the top)
      sweepAngle, // sweep angle based on progress
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
