import 'package:andespace/features/auth/data/local/auth_local_data_source.dart';
import 'package:dio/dio.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/entities/user_status.dart';
import '../../domain/repositories/auth_repository.dart';
import '../cache/auth_session_memory_cache.dart';
import '../models/auth_request_dto.dart';
import '../models/auth_user_dto.dart';
import '../remote/auth_api.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApi api;
  final AuthLocalDataSource localDataSource;
  final AuthSessionMemoryCache memoryCache;

  AuthRepositoryImpl({
    required this.api,
    required this.localDataSource,
    required this.memoryCache,
  });

  @override
  Future<void> login({required String email, required String password}) async {
    await api.login(LoginRequestDto(identifier: email, password: password));

    final user = await getCurrentUser();
    if (user != null) {
      await localDataSource.saveSession(user);
      memoryCache.put(user);
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
      memoryCache.put(user);
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
      memoryCache.clear();
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
      memoryCache.put(user);

      return user;
    } on DioException catch (e) {
      if (e.response == null) {
        final saved = await localDataSource.getSavedUser();
        if (saved != null) memoryCache.put(saved);
        return saved ?? memoryCache.mostRecent;
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
    return _getCachedOrSavedUser();
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
    try {
      await api.updateStatus(status);
      final user = await getCurrentUser();
      if (user != null) await localDataSource.saveSession(user);
    } on DioException catch (e) {
      if (!_isConnectivityError(e)) rethrow;

      await localDataSource.savePendingStatus(status);
      await _updateLocalUser(
        (user) => user.copyWith(status: UserStatus.fromBackendKey(status)),
      );
    }
  }

  @override
  Future<void> updateShareSchedule(bool shareSchedule) async {
    try {
      await api.updateShareSchedule(shareSchedule);
      final user = await getCurrentUser();
      if (user != null) await localDataSource.saveSession(user);
    } on DioException catch (e) {
      if (!_isConnectivityError(e)) rethrow;

      await localDataSource.savePendingShareSchedule(shareSchedule);
      await _updateLocalUser(
        (user) => user.copyWith(shareSchedule: shareSchedule),
      );
    }
  }

  @override
  Future<void> updateUsername(String username) async {
    try {
      await api.updateUsername(username);
      final user = await getCurrentUser();
      if (user != null) await localDataSource.saveSession(user);
    } on DioException catch (e) {
      if (!_isConnectivityError(e)) rethrow;

      await localDataSource.savePendingUsername(username);
      await _updateLocalUser((user) => user.copyWith(username: username));
    }
  }

  @override
  Future<void> syncPendingProfileMutations() async {
    final pending = await localDataSource.getPendingProfileMutation();
    if (pending.isEmpty) return;

    if (pending.status != null) {
      await api.updateStatus(pending.status!);
    }

    if (pending.shareSchedule != null) {
      await api.updateShareSchedule(pending.shareSchedule!);
    }

    if (pending.username != null) {
      await api.updateUsername(pending.username!);
    }

    await localDataSource.clearPendingProfileMutation();

    final user = await getCurrentUser();
    if (user != null) {
      await localDataSource.saveSession(user);
      memoryCache.put(user);
    }
  }

  Future<Map<String, dynamic>?> _readUsernameData() async {
    try {
      return await api.readMyUsername();
    } catch (_) {
      return null;
    }
  }

  Future<AuthUser?> _getCachedOrSavedUser() async {
    final cached = memoryCache.mostRecent;
    if (cached != null) return cached;

    final saved = await localDataSource.getSavedUser();
    if (saved != null) memoryCache.put(saved);
    return saved;
  }

  Future<void> _updateLocalUser(AuthUser Function(AuthUser user) update) async {
    final saved = await localDataSource.getSavedUser();
    if (saved == null) return;

    final updated = update(saved);
    await localDataSource.saveSession(updated);
    memoryCache.put(updated);
  }

  bool _isConnectivityError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.unknown:
        return error.response == null;
      case DioExceptionType.badResponse:
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
        return false;
    }
  }
}
