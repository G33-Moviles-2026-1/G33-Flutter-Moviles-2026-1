import '../../domain/entities/auth_user.dart';

class AuthUserModel {
  final String email;
  final String? firstSemester;

  const AuthUserModel({
    required this.email,
    this.firstSemester,
  });

  factory AuthUserModel.fromMeResponse(Map<String, dynamic> json) {
    final activeUser = json['active_user'] as String?;
    if (activeUser == null) {
      throw const FormatException('active_user is missing');
    }

    return AuthUserModel(
      email: activeUser,
      firstSemester: json['first_semester'] as String?,
    );
  }

  AuthUser toEntity() {
    return AuthUser(
      email: email,
      firstSemester: firstSemester,
    );
  }
}