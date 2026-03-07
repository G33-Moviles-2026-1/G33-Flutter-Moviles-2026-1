import '../../domain/entities/auth_user.dart';

class AuthUserModel {
  final String email;
  final String firstSemester;

  const AuthUserModel({
    required this.email,
    required this.firstSemester,
  });

  factory AuthUserModel.fromMeResponse(Map<String, dynamic> json) {
    final activeUser = json['active_user'] as String?;
    final firstSemester = json['first_semester'] as String?;
    if (activeUser == null) {
      throw const FormatException('active_user is missing');
    }
    if (firstSemester == null) {
      throw const FormatException('first_semester is missing');
    }

    return AuthUserModel(
      email: activeUser,
      firstSemester: firstSemester,
    );
  }

  AuthUser toEntity() {
    return AuthUser(
      email: email,
      firstSemester: firstSemester,
    );
  }
}