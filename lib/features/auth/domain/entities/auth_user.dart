import 'user_status.dart';

class AuthUser {
  final String email;
  final String? firstSemester;
  final String? username;
  final UserStatus status;

  const AuthUser({
    required this.email,
    this.firstSemester,
    this.username,
    this.status = UserStatus.incognito,
  });

  AuthUser copyWith({
    String? email,
    String? firstSemester,
    String? username,
    UserStatus? status,
  }) {
    return AuthUser(
      email: email ?? this.email,
      firstSemester: firstSemester ?? this.firstSemester,
      username: username ?? this.username,
      status: status ?? this.status,
    );
  }
}