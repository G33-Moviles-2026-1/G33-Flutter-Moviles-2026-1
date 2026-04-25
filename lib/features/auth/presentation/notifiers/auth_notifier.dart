import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:andespace/core/di/auth_providers.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_and_fetch_current_user_usecase.dart';
import '../../domain/usecases/logout_and_clear_session_data_usecase.dart';
import '../../domain/usecases/signup_and_fetch_current_user_usecase.dart';
import '../mappers/auth_error_message_mapper.dart';
import 'auth_state.dart';

class AuthNotifier extends Notifier<AuthState> {
  late final LoginAndFetchCurrentUserUseCase _loginAndFetchCurrentUserUseCase;
  late final SignUpAndFetchCurrentUserUseCase _signUpAndFetchCurrentUserUseCase;
  late final GetCurrentUserUseCase _getCurrentUserUseCase;
  late final LogoutAndClearSessionDataUseCase _logoutAndClearSessionDataUseCase;

  @override
  AuthState build() {
    _loginAndFetchCurrentUserUseCase = ref.read(
      loginAndFetchCurrentUserUseCaseProvider,
    );
    _signUpAndFetchCurrentUserUseCase = ref.read(
      signUpAndFetchCurrentUserUseCaseProvider,
    );
    _getCurrentUserUseCase = ref.read(getCurrentUserUseCaseProvider);
    _logoutAndClearSessionDataUseCase = ref.read(
      logoutAndClearSessionDataUseCaseProvider,
    );

    return const AuthState();
  }

  Future<void> loadCurrentUser() async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      final user = await _getCurrentUserUseCase();

      state = AuthState(
        isLoading: false,
        isAuthenticated: user != null,
        user: user,
        isSuccess: false,
      );
    } catch (_) {
      state = const AuthState(isLoading: false, isAuthenticated: false);
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      final user = await _loginAndFetchCurrentUserUseCase(
        email: email,
        password: password,
      );

      state = AuthState(
        isLoading: false,
        isAuthenticated: user != null,
        user: user,
        isSuccess: true,
      );
    } catch (error) {
      state = AuthState(
        isLoading: false,
        isAuthenticated: false,
        error: mapAuthErrorMessage(
          error,
          fallbackMessage: 'Could not log in. Please try again.',
        ),
      );
    }
  }

  Future<void> signup({
    required String email,
    required String password,
    required String firstSemester,
  }) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      final user = await _signUpAndFetchCurrentUserUseCase(
        email: email,
        password: password,
        firstSemester: firstSemester,
      );

      state = AuthState(
        isLoading: false,
        isAuthenticated: user != null,
        user: user,
        isSuccess: true,
      );
    } catch (error) {
      state = AuthState(
        isLoading: false,
        isAuthenticated: false,
        error: mapAuthErrorMessage(
          error,
          fallbackMessage:
              'The account could not be created. Please try again.',
        ),
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      await _logoutAndClearSessionDataUseCase();

      state = const AuthState(
        isLoading: false,
        isAuthenticated: false,
        user: null,
        isSuccess: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: mapAuthErrorMessage(
          error,
          fallbackMessage: 'Could not log out. Please try again.',
        ),
      );
    }
  }

  void clearState() {
    state = AuthState(isAuthenticated: state.isAuthenticated, user: state.user);
  }
}

final authControllerProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
