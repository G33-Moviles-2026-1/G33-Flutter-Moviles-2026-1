import 'package:andespace/core/di/auth_providers.dart';
import 'package:andespace/core/error/dio_error_mapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../bookings/presentation/providers/bookings_providers.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import 'auth_state.dart';

class AuthNotifier extends Notifier<AuthState> {
  late final LoginUseCase _loginUseCase;
  late final SignUpUseCase _signUpUseCase;
  late final GetCurrentUserUseCase _getCurrentUserUseCase;
  late final LogoutUseCase _logoutUseCase;

  @override
  AuthState build() {
    _loginUseCase = ref.read(loginUseCaseProvider);
    _signUpUseCase = ref.read(signUpUseCaseProvider);
    _getCurrentUserUseCase = ref.read(getCurrentUserUseCaseProvider);
    _logoutUseCase = ref.read(logoutUseCaseProvider);
    return const AuthState();
  }

  String _extractAuthErrorMessage(Object error, {required String fallbackMessage}) =>
      DioErrorMapper.map(
        error,
        fallback: fallbackMessage,
        onBadResponse: (statusCode, detail) {
          if (statusCode == 400 && detail == 'User already registered') return 'This user already exists.';
          if (statusCode == 401 || statusCode == 403) return 'Incorrect email or password.';
          return fallbackMessage;
        },
      );

  Future<void> loadCurrentUser() async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    try {
      final user = await _getCurrentUserUseCase();
      state = AuthState(isLoading: false, isAuthenticated: user != null, user: user);
    } catch (_) {
      state = const AuthState(isLoading: false, isAuthenticated: false);
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    try {
      await _loginUseCase(email: email, password: password);
      await ref.read(bookingsLocalDataSourceProvider).clear();
      final user = await _getCurrentUserUseCase();
      state = AuthState(isLoading: false, isAuthenticated: user != null, user: user, isSuccess: true);
    } catch (e) {
      state = AuthState(
        isLoading: false,
        isAuthenticated: false,
        error: _extractAuthErrorMessage(e, fallbackMessage: 'Could not log in. Please try again.'),
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
      await _signUpUseCase(email: email, password: password, firstSemester: firstSemester);
      final user = await _getCurrentUserUseCase();
      state = AuthState(isLoading: false, isAuthenticated: user != null, user: user, isSuccess: true);
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
      await _logoutUseCase();
      await ref.read(bookingsLocalDataSourceProvider).clear();
      state = const AuthState(isLoading: false, isAuthenticated: false, user: null, isSuccess: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _extractAuthErrorMessage(e, fallbackMessage: 'Could not log out. Please try again.'),
      );
    }
  }

  void clearState() {
    state = AuthState(isAuthenticated: state.isAuthenticated, user: state.user);
  }
}

final authControllerProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
