import 'dart:math';

import 'package:flutter/material.dart';


class ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.lightBlueAccent
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    final double radius = size.width * 0.93 / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0, // start angle
      -2 * pi * 0.75, // sweep angle (-270 degrees)
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}