import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../feature_drawing/data/models/drawing_data.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Получение ID комнаты для рисования
  String _getRoomId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return ids.join('_');
  }

  // Получение точек рисования
  Stream<List<DrawingPoint>> getDrawingPoints(String receiverId) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final roomId = _getRoomId(currentUserId, receiverId);

    return _firestore
        .collection('drawingRooms')
        .doc(roomId)
        .collection('points')
        .orderBy('timestamp')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => DrawingPoint.fromMap(doc.data()))
                  .toList(),
        );
  }

  // Отправка точки рисования
  Future<void> sendDrawingPoint(DrawingPoint point, String receiverId) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final roomId = _getRoomId(currentUserId, receiverId);

    await _firestore
        .collection('drawingRooms')
        .doc(roomId)
        .collection('points')
        .add({...point.toMap(), 'timestamp': FieldValue.serverTimestamp()});
  }

  // Очистка холста
  Future<void> clearCanvas(String receiverId) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final roomId = _getRoomId(currentUserId, receiverId);

    final query =
        await _firestore
            .collection('drawingRooms')
            .doc(roomId)
            .collection('points')
            .get();

    final batch = _firestore.batch();
    for (var doc in query.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // Обновление всех точек (для undo/redo)
  Future<void> updateAllPoints(
    List<DrawingPoint> points,
    String receiverId,
  ) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final roomId = _getRoomId(currentUserId, receiverId);

    // Сначала очищаем все точки
    final query =
        await _firestore
            .collection('drawingRooms')
            .doc(roomId)
            .collection('points')
            .get();

    final batch = _firestore.batch();
    for (var doc in query.docs) {
      batch.delete(doc.reference);
    }

    // Затем добавляем новые точки
    for (final point in points) {
      final docRef =
          _firestore
              .collection('drawingRooms')
              .doc(roomId)
              .collection('points')
              .doc();
      batch.set(docRef, {
        ...point.toMap(),
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }
}
