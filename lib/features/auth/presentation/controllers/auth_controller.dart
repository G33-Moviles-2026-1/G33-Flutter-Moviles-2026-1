import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';

class AuthState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const AuthState({this.isLoading = false, this.error, this.isSuccess = false});

  AuthState copyWith({bool? isLoading, String? error, bool? isSuccess}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;
  final SignUpUseCase signUpUseCase;

  AuthController({required this.loginUseCase, required this.signUpUseCase})
    : super(const AuthState());

  Future<void> login({required String email, required String password}) async {
    state = const AuthState(isLoading: true);

    try {
      await loginUseCase(email: email, password: password);
      state = const AuthState(isSuccess: true);
    } catch (e) {
      state = AuthState(isLoading: false, error: 'No se pudo iniciar sesión');
    }
  }

  Future<void> signup({
    required String email,
    required String password,
    required String firstSemester,
  }) async {
    state = const AuthState(isLoading: true);

    try {
      await signUpUseCase(
        email: email,
        password: password,
        firstSemester: firstSemester,
      );
      state = const AuthState(isSuccess: true);
    } catch (e) {
      debugPrint('SIGNUP ERROR: $e');
      if (e is DioException) {
        debugPrint('STATUS CODE: ${e.response?.statusCode}');
        debugPrint('RESPONSE DATA: ${e.response?.data}');
      }

      state = const AuthState(
        isLoading: false,
        error: 'No se pudo crear la cuenta',
      );
    }
  }

  void clearState() {
    state = const AuthState();
  }
}
