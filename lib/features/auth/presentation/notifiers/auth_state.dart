import '../../domain/entities/auth_user.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final AuthUser? user;
  final String? error;
  final bool isSuccess;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
    this.isSuccess = false,
  });

  bool get hasActiveSession => isAuthenticated && user != null;

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    AuthUser? user,
    bool clearUser = false,
    String? error,
    bool? isSuccess,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: clearUser ? null : (user ?? this.user),
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}