import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseChatService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseChatService(this._firestore, this._auth);

  // Получение всех пользователей
  Stream<QuerySnapshot<Map<String, dynamic>>> getRawUsersStream() {
    return _firestore.collection('Users').snapshots();
  }

  Future<void> sendRawMessage({
    required String chatRoomId,
    required Map<String, dynamic> message,
  }) async {
    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .add(message);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getRawMessages(
    String chatRoomId,
  ) {
    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  Future<void> blockUserRaw(String blockerId, String blockedId) async {
    await _firestore
        .collection('Users')
        .doc(blockerId)
        .collection('BlockedUsers')
        .doc(blockedId)
        .set({});
  }

  Future<void> unblockUserRaw(String blockerId, String blockedId) async {
    await _firestore
        .collection('Users')
        .doc(blockerId)
        .collection('BlockedUsers')
        .doc(blockedId)
        .delete();
  }

  Future<void> reportUserRaw(Map<String, dynamic> reportData) async {
    await _firestore.collection('Reports').add(reportData);
  }

  Future<void> deleteUserDataRaw(String userId, String currentUserId) async {
    await _firestore
        .collection('Users')
        .doc(currentUserId)
        .collection('DeleteUsers')
        .doc(userId)
        .delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getBlockedUsersRaw(
    String userId,
  ) {
    return _firestore
        .collection('Users')
        .doc(userId)
        .collection('BlockedUsers')
        .snapshots();
  }

  Future<String?> findChatIdRaw(String user1, String user2) async {
    final query =
        await _firestore
            .collection('chat_rooms')
            .where('members', arrayContainsAny: [user1, user2])
            .limit(1)
            .get();
    return query.docs.isEmpty ? null : query.docs.first.id;
  }

  Future<void> softDeleteChatRaw(String chatId, String userId) async {
    await _firestore.collection('chat_rooms').doc(chatId).update({
      'deletedForUsers': FieldValue.arrayUnion([userId]),
    });
  }
}
