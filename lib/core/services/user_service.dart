// lib/core/services/firestore_user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreUserService {
  final FirebaseFirestore _firestore;

  FirestoreUserService(this._firestore);

  
  Future<void> rawUpdateUserStatus({
    required String uid,
    required String email,
    required bool isOnline,
  }) async {
    await _firestore.collection('Users').doc(uid).set({
      'uid': uid,
      'email': email,
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  
  Stream<DocumentSnapshot> rawUserStatusStream(String uid) {
    return _firestore.collection('Users').doc(uid).snapshots();
  }
}