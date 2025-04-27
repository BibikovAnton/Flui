import 'package:Flui/core/shared/providers/auth_providers.dart';
import 'package:Flui/feature_auth/data/repositories/auth_repository.dart';

import '../feature_auth.dart';

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier(ref.read(authRepositoryProvider));
});

class LoginState {
  final bool isLoading;
  final String? error;

  LoginState({this.isLoading = false, this.error});
}

class LoginNotifier extends StateNotifier<LoginState> {
  final AuthRepository _authRepository;

  LoginNotifier(this._authRepository) : super(LoginState());

  Future<void> login(String email, String password) async {
    state = LoginState(isLoading: true, error: null);

    try {
      await _authRepository.login(email: email, password: password);
      state = LoginState(isLoading: false, error: null);
    } catch (e) {
      state = LoginState(isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    state = LoginState(isLoading: state.isLoading, error: null);
  }
}
