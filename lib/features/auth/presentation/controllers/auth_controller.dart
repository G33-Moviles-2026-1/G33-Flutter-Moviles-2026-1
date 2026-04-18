import 'package:andespace/core/error/dio_error_mapper.dart';
import 'package:andespace/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import 'auth_state.dart';

class AuthController extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;
  final SignUpUseCase signUpUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final LogoutUseCase logoutUseCase;

  AuthController({
    required this.loginUseCase,
    required this.signUpUseCase,
    required this.getCurrentUserUseCase,
    required this.logoutUseCase,
  }) : super(const AuthState());

  String _extractAuthErrorMessage(Object error, {required String fallbackMessage}) =>
      DioErrorMapper.map(
        error,
        fallback: fallbackMessage,
        onBadResponse: (statusCode, detail) {
          if (statusCode == 400 && detail == 'User already registered') return 'This user already exists.';
          if (statusCode == 401) return 'Incorrect email or password.';
          if (statusCode == 403) return 'You do not have permission to perform this action.';
          return fallbackMessage;
        },
      );

  Future<void> loadCurrentUser() async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      final user = await getCurrentUserUseCase();

      state = AuthState(
        isLoading: false,
        isAuthenticated: user != null,
        user: user,
      );
    } catch (_) {
      state = const AuthState(
        isLoading: false,
        isAuthenticated: false,
      );
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      await loginUseCase(email: email, password: password);
      final user = await getCurrentUserUseCase();

      state = AuthState(
        isLoading: false,
        isAuthenticated: user != null,
        user: user,
        isSuccess: true,
      );
    } catch (e) {
      state = AuthState(
        isLoading: false,
        isAuthenticated: false,
        error: _extractAuthErrorMessage(
          e,
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
      await signUpUseCase(
        email: email,
        password: password,
        firstSemester: firstSemester,
      );

      final user = await getCurrentUserUseCase();

      state = AuthState(
        isLoading: false,
        isAuthenticated: user != null,
        user: user,
        isSuccess: true,
      );
    } catch (e) {
      state = AuthState(
        isLoading: false,
        isAuthenticated: false,
        error: _extractAuthErrorMessage(
          e,
          fallbackMessage: 'The account could not be created. Please try again.',
        ),
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      await logoutUseCase();

      state = const AuthState(
        isLoading: false,
        isAuthenticated: false,
        user: null,
        isSuccess: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _extractAuthErrorMessage(
          e,
          fallbackMessage: 'Could not log out. Please try again.',
        ),
      );
    }
  }

  void clearState() {
    state = AuthState(
      isAuthenticated: state.isAuthenticated,
      user: state.user,
    );
  }
}