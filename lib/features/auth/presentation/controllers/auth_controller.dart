import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import 'auth_state.dart';

class AuthController extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;
  final SignUpUseCase signUpUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthController({
    required this.loginUseCase,
    required this.signUpUseCase,
    required this.getCurrentUserUseCase,
  }) : super(const AuthState());

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
      state = const AuthState(
        isLoading: false,
        isAuthenticated: false,
        error: 'No se pudo iniciar sesión',
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
      debugPrint('SIGNUP ERROR: $e');
      if (e is DioException) {
        debugPrint('STATUS CODE: ${e.response?.statusCode}');
        debugPrint('RESPONSE DATA: ${e.response?.data}');
      }

      state = const AuthState(
        isLoading: false,
        isAuthenticated: false,
        error: 'No se pudo crear la cuenta',
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      // agrega LogoutUseCase después si quieres, por ahora podrías llamar repo vía usecase
      state = const AuthState(
        isLoading: false,
        isAuthenticated: false,
        user: null,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'No se pudo cerrar sesión',
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