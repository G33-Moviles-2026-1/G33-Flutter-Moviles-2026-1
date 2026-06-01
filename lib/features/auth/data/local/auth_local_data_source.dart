import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/entities/user_status.dart';

class PendingAuthProfileMutation {
  const PendingAuthProfileMutation({
    this.status,
    this.shareSchedule,
    this.username,
  });

  final String? status;
  final bool? shareSchedule;
  final String? username;

  bool get isEmpty =>
      status == null && shareSchedule == null && username == null;
}

abstract class AuthLocalDataSource {
  Future<void> saveSession(AuthUser user);
  Future<AuthUser?> getSavedUser();
  Future<bool> hasSavedSession();
  Future<void> clearSession();
  Future<void> savePendingStatus(String status);
  Future<void> savePendingShareSchedule(bool shareSchedule);
  Future<void> savePendingUsername(String username);
  Future<PendingAuthProfileMutation> getPendingProfileMutation();
  Future<void> clearPendingProfileMutation();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const _keyIsLoggedIn = 'auth_is_logged_in';
  static const _keyEmail = 'auth_user_email';
  static const _keyUsername = 'auth_user_username';
  static const _keyFirstSemester = 'auth_user_first_semester';
  static const _keyStatus = 'auth_user_status';
  static const _keyShareSchedule = 'auth_user_share_schedule';
  static const _keyPendingStatus = 'auth_pending_status';
  static const _keyPendingShareSchedule = 'auth_pending_share_schedule';
  static const _keyPendingUsername = 'auth_pending_username';

  @override
  Future<void> saveSession(AuthUser user) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyEmail, user.email);
    await _setNullableString(prefs, _keyUsername, user.username);
    await _setNullableString(prefs, _keyFirstSemester, user.firstSemester);
    await prefs.setString(_keyStatus, user.status.backendKey);
    await prefs.setBool(_keyShareSchedule, user.shareSchedule);
  }

  @override
  Future<AuthUser?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();

    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    final email = prefs.getString(_keyEmail);

    if (!isLoggedIn || email == null || email.trim().isEmpty) {
      return null;
    }

    return AuthUser(
      email: email,
      username: prefs.getString(_keyUsername),
      firstSemester: prefs.getString(_keyFirstSemester),
      status: UserStatus.fromBackendKey(
        prefs.getString(_keyStatus) ?? UserStatus.incognito.backendKey,
      ),
      shareSchedule: prefs.getBool(_keyShareSchedule) ?? true,
    );
  }

  @override
  Future<bool> hasSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  @override
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyFirstSemester);
    await prefs.remove(_keyStatus);
    await prefs.remove(_keyShareSchedule);
    await clearPendingProfileMutation();
  }

  @override
  Future<void> savePendingStatus(String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPendingStatus, status);
  }

  @override
  Future<void> savePendingShareSchedule(bool shareSchedule) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPendingShareSchedule, shareSchedule);
  }

  @override
  Future<void> savePendingUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPendingUsername, username);
  }

  @override
  Future<PendingAuthProfileMutation> getPendingProfileMutation() async {
    final prefs = await SharedPreferences.getInstance();

    return PendingAuthProfileMutation(
      status: prefs.getString(_keyPendingStatus),
      shareSchedule: prefs.getBool(_keyPendingShareSchedule),
      username: prefs.getString(_keyPendingUsername),
    );
  }

  @override
  Future<void> clearPendingProfileMutation() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_keyPendingStatus);
    await prefs.remove(_keyPendingShareSchedule);
    await prefs.remove(_keyPendingUsername);
  }

  Future<void> _setNullableString(
    SharedPreferences prefs,
    String key,
    String? value,
  ) async {
    if (value == null || value.trim().isEmpty) {
      await prefs.remove(key);
      return;
    }

    await prefs.setString(key, value.trim());
  }
}
