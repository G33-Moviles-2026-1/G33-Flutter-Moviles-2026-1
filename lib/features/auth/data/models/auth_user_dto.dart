import '../../domain/entities/auth_user.dart';
import '../../domain/entities/user_status.dart';

class AuthUserModel {
  final String email;
  final String? firstSemester;
  final String? username;
  final String? status;

  const AuthUserModel({
    required this.email,
    this.firstSemester,
    this.username,
    this.status,
  });

  factory AuthUserModel.fromMeResponse(Map<String, dynamic> json) {
    final email = json['active_user'] as String? ?? json['email'] as String?;
    if (email == null) {
      throw const FormatException('user email is missing');
    }

    return AuthUserModel(
      email: email,
      firstSemester: json['first_semester'] as String?,
      username: json['username'] as String?,
      status: json['status'] as String?,
    );
  }

  AuthUser toEntity() {
    return AuthUser(
      email: email,
      firstSemester: firstSemester,
      username: username,
      status: status != null
          ? UserStatus.fromBackendKey(status!)
          : UserStatus.incognito,
    );
  }
}
