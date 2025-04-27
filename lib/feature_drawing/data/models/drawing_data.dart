import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DrawingPoint {
  final Offset offset;
  final Color color;
  final double strokeWidth;
  final String userId;
  final String strokeId;
  final String receiverId;

  DrawingPoint({
    required this.offset,
    required this.color,
    required this.strokeWidth,
    required this.userId,
    required this.strokeId,
    required this.receiverId,
  });

  Map<String, dynamic> toMap() {
    return {
      'dx': offset.dx,
      'dy': offset.dy,
      'color': color.value,
      'strokeWidth': strokeWidth,
      'userId': userId,
      'strokeId': strokeId,
      'receiverId': receiverId,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  factory DrawingPoint.fromMap(Map<String, dynamic> map) {
    return DrawingPoint(
      offset: Offset(
        (map['dx'] as num?)?.toDouble() ?? 0.0,
        (map['dy'] as num?)?.toDouble() ?? 0.0,
      ),
      color: Color(map['color'] as int? ?? Colors.black.value),
      strokeWidth: (map['strokeWidth'] as num?)?.toDouble() ?? 3.0,
      userId: map['userId'] as String? ?? '',
      strokeId: map['strokeId'] as String? ?? '',
      receiverId: map['receiverId'] as String? ?? '',
    );
  }
}
