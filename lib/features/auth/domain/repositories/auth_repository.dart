import 'package:andespace/features/auth/domain/entities/auth_user.dart';

abstract class AuthRepository {
  Future<void> login({required String email, required String password});

  Future<void> signup({
    required String email,
    required String password,
    required String firstSemester,
  });

  Future<void> logout();

  Future<AuthUser?> getCurrentUser();

  Future<AuthUser?> getSavedUser();

  Future<bool> hasSavedSession();

  Future<void> clearSavedSession();

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> updateStatus(String status);

  Future<void> updateShareSchedule(bool shareSchedule);

  Future<void> updateUsername(String username);

  Future<void> syncPendingProfileMutations();
}
