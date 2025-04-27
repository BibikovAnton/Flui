import 'package:Flui/core/errors/failures/auth_failures/user_failure.dart';
import 'package:Flui/core/services/user_service.dart';

import '../../feature_auth.dart';

class UserRepository {
  final FirestoreUserService _service;

  UserRepository(this._service);

  Future<Either<UserFailure, Unit>> updateUserStatus({
    required String uid,
    required String email,
    required bool isOnline,
  }) async {
    try {
      await _service.rawUpdateUserStatus(
        uid: uid,
        email: email,
        isOnline: isOnline,
      );
      return right(unit);
    } on FirebaseException catch (e) {
      return left(UserFailure(message: e.message ?? 'Firestore update failed'));
    } catch (e) {
      return left(UserFailure(message: e.toString()));
    }
  }
}
