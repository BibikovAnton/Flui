import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';

class DrawingPoint {
  final Offset offset;
  final Color color;
  final double strokeWidth;
  final bool isErase;
  final String userId;

  DrawingPoint({
    required this.offset,
    required this.color,
    required this.strokeWidth,
    this.isErase = false,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'dx': offset.dx,
      'dy': offset.dy,
      'color': color.value,
      'strokeWidth': strokeWidth,
      'isErase': isErase,
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  factory DrawingPoint.fromMap(Map<String, dynamic> map) {
    return DrawingPoint(
      offset: Offset(map['dx'], map['dy']),
      color: Color(map['color']),
      strokeWidth: map['strokeWidth'],
      isErase: map['isErase'] ?? false,
      userId: map['userId'],
    );
  }
}

class ChatMessage {
  final String id;
  final String text;
  final String senderId;
  final DateTime? timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.senderId,
    this.timestamp,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map, String id) {
    return ChatMessage(
      id: id,
      text: map['text'],
      senderId: map['senderId'],
      timestamp: map['timestamp']?.toDate(),
    );
  }
}
