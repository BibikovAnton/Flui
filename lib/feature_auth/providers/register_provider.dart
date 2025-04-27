// providers/auth/register_provider.dart
import 'package:Flui/core/shared/providers/firebase_providers.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../feature_auth.dart';

final registerProvider = StateNotifierProvider<RegisterNotifier, RegisterState>(
  (ref) {
    return RegisterNotifier(
      ref.read(firebaseAuthProvider),
      ref.read(firestoreProvider),
    );
  },
);

class RegisterState {
  final bool isLoading;
  final String? error;

  RegisterState({this.isLoading = false, this.error});
}

class RegisterNotifier extends StateNotifier<RegisterState> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  RegisterNotifier(this._auth, this._firestore) : super(RegisterState());

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String confirmPassword,
  }) async {
    // Валидация
    if (name.isEmpty) {
      state = RegisterState(isLoading: false, error: 'Введите имя');
      return;
    }

    if (password != confirmPassword) {
      state = RegisterState(isLoading: false, error: 'Пароли не совпадают');
      return;
    }

    state = RegisterState(isLoading: true, error: null);

    //вне
    try {
      // Регистрация
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Сохранение данных пользователя
      await _firestore.collection('Users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email.trim(),
        'name': name.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'lastSeen': FieldValue.serverTimestamp(),
        'isOnline': true,
      });

      state = RegisterState(isLoading: false, error: null);
    } on FirebaseAuthException catch (e) {
      state = RegisterState(
        isLoading: false,
        error: e.message ?? 'Ошибка регистрации',
      );
    } catch (e) {
      state = RegisterState(isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    state = RegisterState(isLoading: state.isLoading, error: null);
  }
}
