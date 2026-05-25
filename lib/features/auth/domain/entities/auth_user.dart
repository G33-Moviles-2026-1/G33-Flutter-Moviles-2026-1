import 'user_status.dart';

class AuthUser {
  final String email;
  final String? firstSemester;
  final String? username;
  final UserStatus status;
  final bool shareSchedule;

  const AuthUser({
    required this.email,
    this.firstSemester,
    this.username,
    this.status = UserStatus.incognito,
    this.shareSchedule = true,
  });

  AuthUser copyWith({
    String? email,
    String? firstSemester,
    String? username,
    UserStatus? status,
    bool? shareSchedule,
  }) {
    return AuthUser(
      email: email ?? this.email,
      firstSemester: firstSemester ?? this.firstSemester,
      username: username ?? this.username,
      status: status ?? this.status,
      shareSchedule: shareSchedule ?? this.shareSchedule,
    );
  }
}
