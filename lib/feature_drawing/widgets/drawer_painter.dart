import 'package:Flui/feature_drawing/data/models/drawing_data.dart';

import 'package:flutter/material.dart';

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint> points;

  DrawingPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final Map<String, Map<String, List<DrawingPoint>>> userStrokes = {};

    for (final point in points) {
      userStrokes
          .putIfAbsent(point.userId, () => {})
          .putIfAbsent(point.strokeId, () => [])
          .add(point);
    }

    for (final userEntry in userStrokes.entries) {
      for (final strokeEntry in userEntry.value.entries) {
        final strokePoints = strokeEntry.value;
        if (strokePoints.length < 2) continue;

        for (int i = 0; i < strokePoints.length - 1; i++) {
          final current = strokePoints[i];
          final next = strokePoints[i + 1];

          final paint =
              Paint()
                ..color = current.color.withOpacity(current.color.opacity)
                ..strokeWidth = current.strokeWidth
                ..strokeCap = StrokeCap.round
                ..style = PaintingStyle.stroke;

          canvas.drawLine(current.offset, next.offset, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
