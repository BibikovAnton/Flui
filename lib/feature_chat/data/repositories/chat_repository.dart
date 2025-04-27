import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ChatRepository(this._firestore, this._auth);

  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection('Users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Future<void> updateUserStatus({
    required String userId,
    required bool isOnline,
    required DateTime lastSeen,
  }) async {
    try {
      await _firestore.collection('Users').doc(userId).update({
        'isOnline': isOnline,
        'lastSeen': lastSeen,
      });
    } catch (e) {
      throw Exception('Failed to update user status: $e');
    }
  }

  Future<void> blockUser(String userIdToBlock) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore.collection('Users').doc(currentUserId).update({
        'blockedUsers': FieldValue.arrayUnion([userIdToBlock]),
      });
    } catch (e) {
      throw Exception('Failed to block user: $e');
    }
  }

  Future<void> sendMessage({
    required String receiverId,
    required String message,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final chatRoomId = _generateChatRoomId(currentUser.uid, receiverId);

      await _firestore
          .collection('Chats')
          .doc(chatRoomId)
          .collection('Messages')
          .add({
            'senderId': currentUser.uid,
            'senderEmail': currentUser.email,
            'receiverId': receiverId,
            'message': message,
            'timestamp': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getMessages(String otherUserId) {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final chatRoomId = _generateChatRoomId(currentUserId, otherUserId);

    return _firestore
        .collection('Chats')
        .doc(chatRoomId)
        .collection('Messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.data()).toList();
        });
  }

  Stream<List<String>> getBlockedUsers() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    return _firestore.collection('Users').doc(currentUserId).snapshots().map((
      snap,
    ) {
      return List<String>.from(snap.data()?['blockedUsers'] ?? []);
    });
  }

  Future<void> unblockUser(String userIdToUnblock) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore.collection('Users').doc(currentUserId).update({
        'blockedUsers': FieldValue.arrayRemove([userIdToUnblock]),
      });
    } catch (e) {
      throw Exception('Failed to unblock user: $e');
    }
  }

  String _generateChatRoomId(String id1, String id2) {
    final ids = [id1, id2]..sort();
    return ids.join('_');
  }

  Future<bool> isUserBlocked(String userId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return false;

    final doc = await _firestore.collection('Users').doc(currentUserId).get();
    final blockedUsers = List<String>.from(doc.data()?['blockedUsers'] ?? []);
    return blockedUsers.contains(userId);
  }

  Future<void> deleteChat(String chatId) async {
    try {
      await _firestore.collection('Chats').doc(chatId).delete();
    } catch (e) {
      throw Exception('Failed to delete chat: $e');
    }
  }
}
