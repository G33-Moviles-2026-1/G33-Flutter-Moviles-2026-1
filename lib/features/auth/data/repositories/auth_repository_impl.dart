import 'package:andespace/features/auth/data/local/auth_local_data_source.dart';
import 'package:dio/dio.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/auth_request_dto.dart';
import '../models/auth_user_dto.dart';
import '../remote/auth_api.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApi api;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.api, required this.localDataSource});

  @override
  Future<void> login({required String email, required String password}) async {
    await api.login(LoginRequestDto(identifier: email, password: password));

    final user = await getCurrentUser();
    if (user != null) {
      await localDataSource.saveSession(user);
    }
  }

  @override
  Future<void> signup({
    required String email,
    required String password,
    required String firstSemester,
  }) async {
    await api.signup(
      SignUpRequestDto(
        email: email,
        password: password,
        firstSemester: firstSemester,
      ),
    );

    final user = await getCurrentUser();
    if (user != null) {
      await localDataSource.saveSession(user);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await api.logout();
    } catch (_) {
      // If remote logout fails, still close the local session.
    } finally {
      await localDataSource.clearSession();
    }
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    try {
      final data = await api.me();
      final usernameData = await _readUsernameData();

      final activeUser = data['active_user'];
      if (activeUser == null && usernameData?['email'] == null) {
        await localDataSource.clearSession();
        return null;
      }

      final model = AuthUserModel.fromMeResponse({
        ...data,
        if (usernameData != null) ...usernameData,
      });
      final user = model.toEntity();

      await localDataSource.saveSession(user);

      return user;
    } on DioException catch (e) {
      if (e.response == null) {
        return localDataSource.getSavedUser();
      }

      final statusCode = e.response?.statusCode;

      if (statusCode == 401 || statusCode == 403) {
        await localDataSource.clearSession();
        return null;
      }

      rethrow;
    }
  }

  @override
  Future<AuthUser?> getSavedUser() {
    return localDataSource.getSavedUser();
  }

  @override
  Future<bool> hasSavedSession() {
    return localDataSource.hasSavedSession();
  }

  @override
  Future<void> clearSavedSession() {
    return localDataSource.clearSession();
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) => api.updatePassword(
    currentPassword: currentPassword,
    newPassword: newPassword,
  );

  @override
  Future<void> updateStatus(String status) async {
    await api.updateStatus(status);
    final user = await getCurrentUser();
    if (user != null) await localDataSource.saveSession(user);
  }

  @override
  Future<void> updateUsername(String username) async {
    await api.updateUsername(username);
    final user = await getCurrentUser();
    if (user != null) await localDataSource.saveSession(user);
  }

  Future<Map<String, dynamic>?> _readUsernameData() async {
    try {
      return await api.readMyUsername();
    } catch (_) {
      return null;
    }
  }
}
