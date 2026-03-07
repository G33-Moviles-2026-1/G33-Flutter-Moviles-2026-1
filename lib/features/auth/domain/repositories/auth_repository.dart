import 'package:andespace/features/auth/domain/entities/auth_user.dart';

abstract class AuthRepository {
  Future<void> login({
    required String email,
    required String password,
  });

  Future<void> signup({
    required String email,
    required String password,
    required String firstSemester,
  });

  Future<void> logout();

  Future<AuthUser?> getCurrentUser();
}