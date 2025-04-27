import 'package:Flui/feature_chat/data/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatService extends StateNotifier<void> {
  final FirebaseFirestore _firebaseFirestore;
  final FirebaseAuth _auth;

  ChatService(this._firebaseFirestore, this._auth) : super(null);

  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firebaseFirestore.collection('Users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  Future<void> sendMessage(String recrveId, String message) async {
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverID: recrveId,
      message: message,
      timestamp: timestamp,
    );

    List<String> ids = [currentUserId, recrveId];
    ids.sort();
    String chatRoomID = ids.join('_');

    await _firebaseFirestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getMessages(String userID, String otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firebaseFirestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  Stream<List<Map<String, dynamic>>> getUsersStreamExcludingBlocked() {
    final currentUser = _auth.currentUser;

    return _firebaseFirestore
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .snapshots()
        .asyncMap((snapshot) async {
          final blockedUserId = snapshot.docs.map((doc) => doc.id).toList();

          final usersSnapshot =
              await _firebaseFirestore.collection('Users').get();

          return usersSnapshot.docs
              .where(
                (doc) =>
                    doc.data()['email'] != currentUser.email &&
                    !blockedUserId.contains(doc.id),
              )
              .map((doc) => doc.data())
              .toList();
        });
  }

  Future<void> reportUser(String messageId, String userId) async {
    final currentUser = _auth.currentUser;
    final report = {
      'reportedBy': currentUser!.uid,
      'messageId': messageId,
      'messageOwnerId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    };
    await _firebaseFirestore.collection('Reports').add(report);
  }

  Future<void> deleteUserData(String userId) async {
    final currentUser = _auth.currentUser;
    await _firebaseFirestore
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('DeleteUsers')
        .doc(userId)
        .delete();
  }

  Future<void> blockUser(String userId) async {
    final currentUser = _auth.currentUser;
    await _firebaseFirestore
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .doc(userId)
        .set({});
  }

  Future<void> unblockUser(String blockedUserId) async {
    final currentUser = _auth.currentUser;
    await _firebaseFirestore
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .doc(blockedUserId)
        .delete();
  }

  Stream<List<Map<String, dynamic>>> getBlockedUserStream(String userId) {
    return _firebaseFirestore
        .collection('Users')
        .doc(userId)
        .collection('BlockedUsers')
        .snapshots()
        .asyncMap((snapshot) async {
          final blockedUserIds = snapshot.docs.map((doc) => doc.id).toList();

          final userDocs = await Future.wait(
            blockedUserIds.map(
              (id) => _firebaseFirestore.collection('Users').doc(id).get(),
            ),
          );
          return userDocs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });
  }

  Future<String?> findChatIdBetweenUsers(String user1, String user2) async {
    final query =
        await _firebaseFirestore
            .collection('chat_rooms')
            .where('members', arrayContainsAny: [user1, user2])
            .limit(1)
            .get();

    return query.docs.isEmpty ? null : query.docs.first.id;
  }

  Future<void> softDeleteChatForUser(String chatId, String userId) async {
    await _firebaseFirestore.collection('chat_rooms').doc(chatId).update({
      'deletedForUsers': FieldValue.arrayUnion([userId]),
    });
  }
}
