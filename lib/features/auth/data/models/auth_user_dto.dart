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
    final activeUser = json['active_user'] as String?;
    if (activeUser == null) {
      throw const FormatException('active_user is missing');
    }

    return AuthUserModel(
      email: activeUser,
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