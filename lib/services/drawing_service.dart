import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/drawing_data.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> sendChatMessage(
    String roomId,
    String text,
    String senderId,
  ) async {
    await _firestore
        .collection('drawingRooms')
        .doc(roomId)
        .collection('chat')
        .add({
          'text': text,
          'senderId': senderId,
          'senderEmail':
              senderId == 'system' ? null : _firebaseAuth.currentUser?.email,
          'timestamp': FieldValue.serverTimestamp(),
        });
  }

  // Отправка точки рисования
  Future<void> sendDrawingPoint(DrawingPoint point, String roomId) async {
    await _firestore
        .collection('drawingRooms')
        .doc(roomId)
        .collection('points')
        .add(point.toMap());
  }

  // Очистка холста
  Future<void> clearCanvas(String roomId) async {
    final batch = _firestore.batch();
    final points =
        await _firestore
            .collection('drawingRooms')
            .doc(roomId)
            .collection('points')
            .get();

    for (var doc in points.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // Получение потока точек рисования
  Stream<List<DrawingPoint>> getDrawingPoints(String roomId) {
    return _firestore
        .collection('drawingRooms')
        .doc(roomId)
        .collection('points')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => DrawingPoint.fromMap(doc.data()))
              .toList();
        });
  }

  // Получение сообщений чата
  Stream<List<ChatMessage>> getChatMessages(String roomId) {
    return _firestore
        .collection('drawingRooms')
        .doc(roomId)
        .collection('chat')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ChatMessage.fromMap(doc.data(), doc.id))
              .toList();
        });
  }
}
