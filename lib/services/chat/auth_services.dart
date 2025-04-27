import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(FirebaseAuth.instance, FirebaseFirestore.instance);
});

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService(this._auth, this._firestore);

  // Получение текущего пользователя
  User? get currentUser => _auth.currentUser;

  // Вход по email и паролю
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _updateUserStatus(userCredential.user!.uid, email, true);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    }
  }

  // Регистрация по email и паролю
  Future<UserCredential> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Сохраняем дополнительную информацию о пользователе
      await _firestore.collection('Users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'name': name,
        'isOnline': true,
        'lastSeen': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    }
  }

  // Выход из системы
  Future<void> signOut() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('Users').doc(user.uid).update({
        'isOnline': false,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    }
    await _auth.signOut();
  }

  // Обновление статуса пользователя
  Future<void> _updateUserStatus(
    String uid,
    String email,
    bool isOnline,
  ) async {
    await _firestore.collection('Users').doc(uid).set({
      'uid': uid,
      'email': email,
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Стрим статуса пользователя
  Stream<DocumentSnapshot> getUserStatusStream(String uid) {
    return _firestore.collection('Users').doc(uid).snapshots();
  }

  // Стрим текущего пользователя
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}

// Кастомное исключение для ошибок аутентификации
class AuthException implements Exception {
  final String code;
  AuthException(this.code);

  @override
  String toString() => code;
}

// Provider для отслеживания состояния аутентификации
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});
