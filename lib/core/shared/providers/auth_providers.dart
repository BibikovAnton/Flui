//services
import 'package:Flui/core/services/auth_services.dart';
import 'package:Flui/core/services/user_service.dart';
import 'package:Flui/core/shared/providers/firebase_providers.dart';
import 'package:Flui/feature_auth/data/repositories/auth_repository.dart';
import 'package:Flui/feature_auth/data/repositories/user_repository.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final authServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService(
    ref.read(firebaseAuthProvider),
    ref.read(firestoreProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.read(authServiceProvider),
    ref.read(userRepositoryProvider),
  );
});

final userServiceProvider = Provider<FirestoreUserService>((ref) {
  return FirestoreUserService(ref.read(firestoreProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.read(userServiceProvider));
});
