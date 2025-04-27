import 'package:Flui/core/errors/failures/auth_failures/auth_failure.dart';
import 'package:Flui/core/services/auth_services.dart';
import 'package:Flui/feature_auth/data/repositories/user_repository.dart';

import '../../feature_auth.dart';

class AuthRepository {
  final UserRepository _userRepository;
  final FirebaseAuthService _authService;

  AuthRepository(this._authService, this._userRepository);

  User? getCurrentUser() => _authService.currentUser;

  Future<Either<AuthFailure, User>> login({
    required String email,
    required String password,
  }) async {
    final result = await _authService
        .signInWithEmailAndPassword(email: email, password: password)
        .then((cred) => Right(cred))
        .catchError((e) => Left(_mapAuthError(e)));

    return result.fold((failure) => Left(failure), (credential) async {
      await _userRepository.updateUserStatus(
        uid: credential.user!.uid,
        email: email,
        isOnline: true,
      );
      return Right(credential.user!);
    });
  }

  Future<Either<AuthFailure, User>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final result = await _authService
        .signUpWithEmailAndPossword(name, email, password)
        .then((cred) => Right(cred))
        .catchError((e) => Left(_mapAuthError(e)));

    return result.fold((failure) => Left(failure), (credential) async {
      await _userRepository.updateUserStatus(
        uid: credential.user!.uid,
        email: email,
        isOnline: true,
      );
      return Right(credential.user!);
    });
  }

  Future<Either<AuthFailure, Unit>> signOut({required String email}) async {
    final user = _authService.currentUser;
    if (user == null) return Right(unit);

    final updateResult = await _userRepository
        .updateUserStatus(email: email, uid: user.uid, isOnline: false)
        .then((_) => Right(unit))
        .catchError((e) => Left(_mapAuthError(e)));

    return updateResult.fold((failure) => Left(failure), (_) async {
      await _authService.rawSignOut();
      return Right(unit);
    });
  }

  AuthFailure _mapAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      return AuthFailure(
        code: error.code,
        message: error.message ?? 'Authentication failed',
      );
    }
    return AuthFailure(code: 'unknown', message: error.toString());
  }
}

///////////2способ///////////////

// class AuthRepository {
//   final UserRepository _userRepository;
//   final FirebaseAuthService _authService;

//   AuthRepository(this._authService, this._userRepository);

//   User? getCurrentUser() => _authService.currentUser;

//   Future<Either<AuthFailure, User>> login({
//     required String email,
//     required String password,
//   }) async {
//     return await _authService
//         .signInWithEmailAndPassword(email: email, password: password)
//         .then((userCredential) async {
//           await _userRepository.updateUserStatus(
//             uid: userCredential.user!.uid,
//             email: email,
//             isOnline: true,
//           );
//           return Right(userCredential.user!);
//         })
//         .catchError((error) {
//           return Left(AuthFailure(message: _mapAuthError(error)));
//         });
//   }

//   Future<Either<AuthFailure, User>> register({
//     required String name,
//     required String email,
//     required String password,
//   }) async {
//     return await _authService
//         .signUpWithEmailAndPassword(name: name, email: email, password: password)
//         .then((userCredential) async {
//           await _userRepository.updateUserStatus(
//             uid: userCredential.user!.uid,
//             email: email,
//             isOnline: true,
//           );
//           return Right(userCredential.user!);
//         })
//         .catchError((error) {
//           return Left(AuthFailure(message: _mapAuthError(error)));
//         });
//   }

//   Future<Either<AuthFailure, Unit>> signOut({required String email}) async {
//     final user = _authService.currentUser;
//     if (user == null) return Right(unit);

//     return await _userRepository
//         .updateUserStatus(email: email, uid: user.uid, isOnline: false)
//         .then((_) async {
//           await _authService.rawSignOut();
//           return Right(unit);
//         })
//         .catchError((error) {
//           return Left(AuthFailure(message: _mapAuthError(error)));
//         });
//   }

//   String _mapAuthError(dynamic error) {
//     if (error is FirebaseAuthException) {
//       return error.message ?? 'Authentication failed';
//     } else if (error is FirebaseException) {
//       return error.message ?? 'Database operation failed';
//     }
//     return 'Unknown error occurred';
//   }
// }
